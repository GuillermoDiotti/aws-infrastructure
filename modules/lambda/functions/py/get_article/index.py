import json
import boto3
import os
from boto3.dynamodb.conditions import Key
from decimal import Decimal

# Cliente DynamoDB
dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(TABLE_NAME)

# Helper para convertir Decimal a tipos JSON serializables
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj) if obj % 1 == 0 else float(obj)
        return super(DecimalEncoder, self).default(obj)

def handler(event, context):
    """
    Lambda para obtener artículos de DynamoDB

    Rutas:
    - GET /articles/{id} - Obtener un artículo específico
    - GET /articles - Listar todos los artículos (con paginación)
    """

    try:
        print(f"📥 Event received: {json.dumps(event)}")

        # Obtener parámetros del path
        path_parameters = event.get('pathParameters', {})
        query_parameters = event.get('queryStringParameters') or {}

        # Si hay ID, obtener artículo específico
        if path_parameters and 'id' in path_parameters:
            article_id = path_parameters['id']

            print(f"🔍 Getting article by ID: {article_id}")
            response = table.get_item(Key={'id': article_id})

            if 'Item' not in response:
                print(f"❌ Article not found: {article_id}")
                return {
                    'statusCode': 404,
                    'headers': {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    'body': json.dumps({
                        'success': False,
                        'error': 'Article not found',
                        'article_id': article_id
                    })
                }

            print(f"✅ Article found: {article_id}")
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'success': True,
                    'article': response['Item']
                }, cls=DecimalEncoder)
            }

        # Si no hay ID, listar artículos
        else:
            # Parámetros de paginación y filtrado
            limit = int(query_parameters.get('limit', 20))
            topic = query_parameters.get('topic')

            print(f"📋 Listing articles: limit={limit}, topic={topic}")

            scan_params = {
                'Limit': limit
            }

            # Si hay un token de paginación
            if 'lastKey' in query_parameters:
                try:
                    scan_params['ExclusiveStartKey'] = json.loads(query_parameters['lastKey'])
                except:
                    pass

            # Si se filtra por topic, usar GSI
            if topic:
                print(f"🔎 Querying by topic: {topic}")
                response = table.query(
                    IndexName='TopicIndex',
                    KeyConditionExpression=Key('topic').eq(topic),
                    Limit=limit,
                    ScanIndexForward=False  # Orden descendente por created_at
                )
            else:
                # Scan completo
                response = table.scan(**scan_params)

            # Ordenar por fecha de creación (más recientes primero)
            articles = response.get('Items', [])

            if not topic:  # Solo si no usamos GSI con ordenamiento
                articles = sorted(
                    articles,
                    key=lambda x: x.get('created_at', ''),
                    reverse=True
                )

            result = {
                'success': True,
                'articles': articles,
                'count': len(articles)
            }

            # Agregar token de paginación si hay más resultados
            if 'LastEvaluatedKey' in response:
                result['lastKey'] = json.dumps(response['LastEvaluatedKey'], cls=DecimalEncoder)
                result['hasMore'] = True
            else:
                result['hasMore'] = False

            print(f"✅ Found {len(articles)} articles")

            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
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