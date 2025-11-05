import json
import boto3
import os
from boto3.dynamodb.conditions import Key
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(TABLE_NAME)

class DecimalEncoder(json.JSONEncoder):
    """Helper para serializar Decimals de DynamoDB"""
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)

def handler(event, context):
    """
    Lambda para leer artículos de DynamoDB

    Soporta:
    - GET /articles -> Lista todos
    - GET /articles/{id} -> Obtiene uno específico
    """

    try:
        print(f"📥 Event received: {json.dumps(event)}")

        # Determinar si es una consulta específica o lista
        path_parameters = event.get('pathParameters', {})
        article_id = path_parameters.get('id') if path_parameters else None

        if article_id:
            # GET /articles/{id}
            print(f"🔍 Fetching article: {article_id}")
            result = get_article_by_id(article_id)
        else:
            # GET /articles
            print("📋 Fetching all articles")
            result = list_articles(event)

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET,OPTIONS'
            },
            'body': json.dumps(result, cls=DecimalEncoder)
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
                'error': str(e),
                'error_type': type(e).__name__
            })
        }

def get_article_by_id(article_id):
    """Obtener un artículo específico por ID"""
    try:
        response = table.get_item(Key={'id': article_id})

        if 'Item' not in response:
            return {
                'success': False,
                'error': 'Article not found',
                'article_id': article_id
            }

        return {
            'success': True,
            'data': response['Item']
        }

    except Exception as e:
        print(f"❌ Error getting article {article_id}: {e}")
        raise

def list_articles(event):
    """Listar artículos (con paginación opcional)"""
    try:
        # Parámetros de query opcionales
        query_params = event.get('queryStringParameters') or {}
        limit = int(query_params.get('limit', 50))

        # Scan con límite
        scan_params = {
            'Limit': min(limit, 100)  # Máximo 100
        }

        # Si hay token de paginación
        last_key = query_params.get('lastKey')
        if last_key:
            scan_params['ExclusiveStartKey'] = {'id': last_key}

        response = table.scan(**scan_params)

        items = response.get('Items', [])

        # Ordenar por created_at descendente (más recientes primero)
        items_sorted = sorted(
            items,
            key=lambda x: x.get('created_at', ''),
            reverse=True
        )

        result = {
            'success': True,
            'items': items_sorted,
            'count': len(items_sorted)
        }

        # Agregar token de paginación si hay más
        if 'LastEvaluatedKey' in response:
            result['lastKey'] = response['LastEvaluatedKey']['id']

        return result

    except Exception as e:
        print(f"❌ Error listing articles: {e}")
        raise