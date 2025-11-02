import json
import boto3
import os
import uuid
from datetime import datetime, timedelta

# Clientes AWS
dynamodb = boto3.resource('dynamodb')
bedrock = boto3.client('bedrock-runtime')

TABLE_NAME = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(TABLE_NAME)

def handler(event, context):
    """
    Lambda para generar artículos con IA usando Bedrock

    Event puede venir de:
    1. API Gateway: { "body": {...} }
    2. EventBridge: { "topic": "...", "style": "...", "length": "..." }
    """

    try:
        print(f"📥 Event received: {json.dumps(event)}")

        # Parsear el input
        if 'body' in event:
            # Viene de API Gateway
            body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
            source = 'api_gateway'
        else:
            # Viene de EventBridge
            body = event
            source = event.get('source', 'eventbridge')

        # Parámetros
        topic = body.get('topic', 'technology')
        style = body.get('style', 'informative')
        length = body.get('length', 'medium')

        print(f"📝 Generating article: topic={topic}, style={style}, length={length}")

        # Prompt para Bedrock
        prompt = f"""Escribe un artículo {style} sobre {topic}.
        El artículo debe tener una longitud {length} (aproximadamente 500 palabras para medium).

        Estructura requerida:
        - Empieza con un título claro y atractivo (usando # en markdown)
        - Divide el contenido en secciones con subtítulos (usando ##)
        - Usa un tono profesional pero accesible
        - Incluye ejemplos concretos cuando sea relevante

        Genera solo el artículo, sin introducción ni comentarios adicionales."""

        # Llamar a Bedrock (Claude 3 Haiku)
        print("🤖 Calling Bedrock...")
        response = bedrock.invoke_model(
            modelId='anthropic.claude-3-haiku-20240307-v1:0',
            body=json.dumps({
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": 2000,
                "temperature": 0.7,
                "messages": [
                    {
                        "role": "user",
                        "content": prompt
                    }
                ]
            })
        )

        # Parsear respuesta
        response_body = json.loads(response['body'].read())
        article_content = response_body['content'][0]['text']

        print(f"✅ Article generated: {len(article_content)} characters")

        # Extraer título (primera línea con #)
        lines = article_content.split('\n')
        title = "Sin título"
        content_start = 0

        for i, line in enumerate(lines):
            if line.strip().startswith('#'):
                title = line.replace('#', '').strip()
                content_start = i + 1
                break

        content = '\n'.join(lines[content_start:]).strip()

        # Generar ID y timestamps
        article_id = str(uuid.uuid4())
        created_at = datetime.utcnow().isoformat() + 'Z'
        ttl = int((datetime.utcnow() + timedelta(days=30)).timestamp())

        # Guardar en DynamoDB
        item = {
            'id': article_id,
            'title': title,
            'content': content,
            'topic': topic,
            'style': style,
            'length': length,
            'created_at': created_at,
            'ttl': ttl,
            'source': source,
            'metadata': {
                'word_count': len(content.split()),
                'char_count': len(content),
                'model': 'claude-3-haiku',
                'generated_by': 'bedrock',
                'temperature': 0.7
            }
        }

        print(f"💾 Saving to DynamoDB: {article_id}")
        table.put_item(Item=item)
        print("✅ Article saved successfully")

        # Respuesta
        response_data = {
            'success': True,
            'article_id': article_id,
            'title': title,
            'topic': topic,
            'created_at': created_at,
            'word_count': item['metadata']['word_count'],
            'message': 'Article generated successfully'
        }

        # Si viene de API Gateway, formato específico
        if 'body' in event:
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps(response_data)
            }
        else:
            # Si viene de EventBridge, retorno simple
            return response_data

    except Exception as e:
        print(f"❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()

        error_response = {
            'success': False,
            'error': str(e),
            'error_type': type(e).__name__
        }

        if 'body' in event:
            return {
                'statusCode': 500,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps(error_response)
            }
        else:
            return error_response