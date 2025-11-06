import json
import boto3
import psycopg2
import os
from datetime import datetime

# Clientes AWS
secretsmanager = boto3.client('secretsmanager')

def get_db_credentials():
    """Obtener credenciales de la base de datos desde Secrets Manager"""
    secret_name = os.environ['DB_SECRET_NAME']

    try:
        response = secretsmanager.get_secret_value(SecretId=secret_name)
        return json.loads(response['SecretString'])
    except Exception as e:
        print(f"Error getting credentials: {e}")
        raise

def get_db_connection():
    """Establecer conexión con PostgreSQL"""
    creds = get_db_credentials()

    try:
        conn = psycopg2.connect(
            host=creds['host'],
            port=creds['port'],
            database=creds['dbname'],
            user=creds['username'],
            password=creds['password']
        )
        return conn
    except Exception as e:
        print(f"Error connecting to database: {e}")
        raise

def init_database():
    """Crear tabla si no existe"""
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS comentarios (
                id SERIAL PRIMARY KEY,
                nombre VARCHAR(100) NOT NULL,
                email VARCHAR(255) NOT NULL,
                comentario TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)

        # Crear índice para ordenar por fecha
        cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_comentarios_created_at
            ON comentarios(created_at DESC)
        """)

        conn.commit()
        print("✅ Database initialized successfully")
    except Exception as e:
        conn.rollback()
        print(f"Error initializing database: {e}")
        raise
    finally:
        cursor.close()
        conn.close()

def validate_comentario(data):
    """Validar datos del comentario"""
    errors = []

    if not data.get('nombre') or len(data['nombre'].strip()) < 2:
        errors.append('Nombre debe tener al menos 2 caracteres')

    if not data.get('email') or '@' not in data['email']:
        errors.append('Email inválido')

    if not data.get('comentario') or len(data['comentario'].strip()) < 10:
        errors.append('Comentario debe tener al menos 10 caracteres')

    return errors

def handler(event, context):
    """Lambda handler para crear comentarios"""

    print(f"📥 Event received: {json.dumps(event)}")

    try:
        # Inicializar DB (crear tabla si no existe)
        init_database()

        # Parsear body
        if 'body' in event:
            body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
        else:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'success': False,
                    'error': 'Missing body'
                })
            }

        # Validar datos
        errors = validate_comentario(body)
        if errors:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'success': False,
                    'errors': errors
                })
            }

        # Insertar en base de datos
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
            'created_at': int(result[4] * 1000)  # Convertir a milisegundos
        }

        print(f"✅ Comentario created: {comentario['id']}")

        cursor.close()
        conn.close()

        return {
            'statusCode': 201,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'success': True,
                'data': comentario,
                'message': 'Comentario creado exitosamente'
            })
        }

    except Exception as e:
        print(f"❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()

        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'success': False,
                'error': 'Error al crear comentario',
                'details': str(e)
            })
        }