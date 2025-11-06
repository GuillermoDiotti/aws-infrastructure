import json
import boto3
import os
import uuid
from datetime import datetime, timedelta
from decimal import Decimal
import time
import random
from utils.constants import ARTICLE_TOPICS, ARTICLE_STYLES, ARTICLE_LENGTHS, ARTICLE_LENGTH_GUIDE
from utils.articles_config import master_prompt

dynamodb = boto3.resource('dynamodb')
bedrock = boto3.client('bedrock-runtime')

TABLE_NAME = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(TABLE_NAME)

def handler(event, context):
    try:
        print(f"📥 Event received: {json.dumps(event)}")

        source = 'eventbridge'
        topic = random.choice(ARTICLE_TOPICS)
        style = random.choice(ARTICLE_STYLES)
        length = random.choice(ARTICLE_LENGTHS)
        words = ARTICLE_LENGTH_GUIDE.get(length, '500')

        print(f"📝 Generating article: topic={topic}, style={style}, length={length}")

        prompt = master_prompt(topic, style, length, words)

        print("🤖 Calling Bedrock...")
        response = bedrock.invoke_model(
            modelId='us.meta.llama3-1-8b-instruct-v1:0',
            body=json.dumps({
                "prompt": f"<|begin_of_text|><|start_header_id|>user<|end_header_id|>\n\n{prompt}<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n",
                "max_gen_len": 2000,
                "temperature": 0.7,
                "top_p": 0.9
            })
        )

        # Parsear respuesta
        response_body = json.loads(response['body'].read())
        article_content = response_body['generation'].strip()

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
        created_at = Decimal(str(int(time.time())))
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
                'model': 'llama3-1-8b',
                'generated_by': 'bedrock',
                'temperature': Decimal('0.7')
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