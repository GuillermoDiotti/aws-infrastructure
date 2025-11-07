import json
import boto3
import os
import sys
from datetime import datetime

print(f"Python version: {sys.version}")
print(f"Python path: {sys.path}")

# Try importing psycopg2
try:
    import psycopg2
    print(f"✅ psycopg2 imported successfully: {psycopg2.__version__}")
except ImportError as e:
    print(f"❌ Failed to import psycopg2: {e}")
    print(f"Available packages: {sys.modules.keys()}")

# AWS Clients
secretsmanager = boto3.client('secretsmanager')
sns = boto3.client('sns')
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN')

# CORS headers
CORS_HEADERS = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
}

def get_db_credentials():
    """Get database credentials from Secrets Manager"""
    secret_name = os.environ.get('DB_SECRET_NAME')

    if not secret_name:
        raise ValueError("DB_SECRET_NAME environment variable not set")

    print(f"Fetching secret: {secret_name}")

    try:
        response = secretsmanager.get_secret_value(SecretId=secret_name)
        credentials = json.loads(response['SecretString'])
        print(f"✅ Credentials retrieved for host: {credentials.get('host', 'unknown')}")
        return credentials
    except Exception as e:
        print(f"❌ Error getting credentials: {e}")
        raise

def get_db_connection():
    """Establish PostgreSQL connection"""
    creds = get_db_credentials()

    print(f"Connecting to: {creds['host']}:{creds['port']}/{creds['dbname']}")

    try:
        conn = psycopg2.connect(
            host=creds['host'],
            port=creds['port'],
            database=creds['dbname'],
            user=creds['username'],
            password=creds['password'],
            connect_timeout=10
        )
        print("✅ Database connection established")
        return conn
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        raise

def init_database():
    """Create table if not exists"""
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        print("Creating table if not exists...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS comentarios (
                id SERIAL PRIMARY KEY,
                nombre VARCHAR(100) NOT NULL,
                email VARCHAR(255) NOT NULL,
                comentario TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)

        cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_comentarios_created_at
            ON comentarios(created_at DESC)
        """)

        conn.commit()
        print("✅ Database initialized successfully")
    except Exception as e:
        conn.rollback()
        print(f"❌ Error initializing database: {e}")
        raise
    finally:
        cursor.close()
        conn.close()

def validate_comentario(data):
    """Validate comment data"""
    errors = []

    if not data.get('nombre') or len(data['nombre'].strip()) < 2:
        errors.append('Nombre debe tener al menos 2 caracteres')

    if not data.get('email') or '@' not in data['email']:
        errors.append('Email inválido')

    if not data.get('comentario') or len(data['comentario'].strip()) < 10:
        errors.append('Comentario debe tener al menos 10 caracteres')

    return errors

def handler(event, context):
    """Lambda handler for creating comments"""

    print(f"📥 Event received: {json.dumps(event, default=str)}")
    print(f"Environment variables: {dict(os.environ)}")

    try:
        # Initialize database
        init_database()

        # Parse body
        if 'body' in event:
            body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
        else:
            return {
                'statusCode': 400,
                'headers': CORS_HEADERS,
                'body': json.dumps({
                    'success': False,
                    'error': 'Missing body'
                })
            }

        print(f"Parsed body: {body}")

        # Validate data
        errors = validate_comentario(body)
        if errors:
            return {
                'statusCode': 400,
                'headers': CORS_HEADERS,
                'body': json.dumps({
                    'success': False,
                    'errors': errors
                })
            }

        # Insert into database
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO comentarios (nombre, email, comentario)
            VALUES (%s, %s, %s)
            RETURNING id, nombre, email, comentario,
                     EXTRACT(EPOCH FROM created_at) as created_at
        """, (
            body['nombre'].strip(),
            body['email'].strip(),
            body['comentario'].strip()
        ))

        result = cursor.fetchone()
        conn.commit()

        comentario = {
            'id': result[0],
            'nombre': result[1],
            'email': result[2],
            'comentario': result[3],
            'created_at': int(result[4] * 1000)
        }

        print(f"✅ Comment created with ID: {comentario['id']}")

        if SNS_TOPIC_ARN:
            send_sns_notification(comentario)

        cursor.close()
        conn.close()

        return {
            'statusCode': 201,
            'headers': CORS_HEADERS,
            'body': json.dumps({
                'success': True,
                'data': comentario,
                'message': 'Comentario creado exitosamente'
            })
        }

    except psycopg2.OperationalError as e:
        print(f"❌ Database operational error: {str(e)}")
        return {
            'statusCode': 503,
            'headers': CORS_HEADERS,
            'body': json.dumps({
                'success': False,
                'error': 'Database connection error',
                'details': 'Unable to connect to database. Please try again later.'
            })
        }

    except Exception as e:
        print(f"❌ Unexpected error: {str(e)}")
        import traceback
        traceback.print_exc()

        return {
            'statusCode': 500,
            'headers': CORS_HEADERS,
            'body': json.dumps({
                'success': False,
                'error': 'Internal server error',
                'details': str(e) if os.environ.get('DEBUG') == 'true' else 'An error occurred'
            })
        }

def send_sns_notification(comentario):
    try:
        print("🔔 Sending SNS notification...")

        formatted_message = f"""
        ===========================================================
                     🤖 NUEVO COMENTARIO PUBLICADO
        ===========================================================

        📊 INFORMACIÓN:

        📌 ID: {comentario['id']}

        • nombre: {comentario['topic']}
        • email: {comentario['style']}
        • created_at: {comentario['metadata']['word_count']}

        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        • comentario: {comentario['length']}

        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        💡 Este comentario fue publicado por el usuario mencionado.
           El mismo se captura en una base de datos RDS
        """

        response = sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject=f"🤖 Nuevo Comentario: {comentario['id'][:50]}",
            Message=formatted_message,
            MessageAttributes={
                'event_type': {
                    'DataType': 'String',
                    'StringValue': 'acomment_created'
                }
            }
        )

        print(f"✅ SNS notification sent: MessageId={response['MessageId']}")
        return True

    except Exception as e:
        print(f"⚠️ Error sending SNS notification: {str(e)}")
        # No fallar si SNS falla - solo registrar error
        return False