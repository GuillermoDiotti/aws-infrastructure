import json
import boto3
import psycopg2
import os

secretsmanager = boto3.client('secretsmanager')

def get_db_credentials():
    secret_name = os.environ['DB_SECRET_NAME']
    try:
        response = secretsmanager.get_secret_value(SecretId=secret_name)
        return json.loads(response['SecretString'])
    except Exception as e:
        print(f"Error getting credentials: {e}")
        raise

def get_db_connection():
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

def handler(event, context):
    print(f"📥 Event received: {json.dumps(event)}")

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Crear tabla si no existe
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS comentarios (
                id SERIAL PRIMARY KEY,
                nombre VARCHAR(100) NOT NULL,
                email VARCHAR(255) NOT NULL,
                comentario TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        conn.commit()

        # Obtener comentarios ordenados por fecha
        cursor.execute("""
            SELECT id, nombre, email, comentario,
                   EXTRACT(EPOCH FROM created_at) * 1000 as created_at
            FROM comentarios
            ORDER BY created_at DESC
            LIMIT 50
        """)

        rows = cursor.fetchall()

        comentarios = [{
            'id': row[0],
            'nombre': row[1],
            'email': row[2],
            'comentario': row[3],
            'created_at': int(row[4])
        } for row in rows]

        cursor.close()
        conn.close()

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET,OPTIONS'
            },
            'body': json.dumps({
                'success': True,
                'items': comentarios,
                'count': len(comentarios)
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
                'error': 'Error al obtener comentarios',
                'details': str(e)
            })
        }