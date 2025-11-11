#!/bin/bash

# Cargar variables del .env
source .env

# Obtener el endpoint de Terraform
ENDPOINT=$(terraform output -raw api_endpoint)

FILE_PATH="src/config.js"

# Contenido del archivo
CONTENT=$(echo "export const apiEndpoint = '$ENDPOINT';" | base64)

# Obtener el SHA actual del archivo (si existe)
SHA=$(curl -s -H "Authorization: token $token_github" \
  "$repository/$FILE_PATH" \
  | jq -r '.sha')

# Actualizar el archivo en GitHub
curl -X PUT \
  -H "Authorization: token $token_github" \
  -H "Content-Type: application/json" \
  "$repository/$FILE_PATH" \
  -d "{
    \"message\": \"Update API endpoint\",
    \"content\": \"$CONTENT\",
    \"sha\": \"$SHA\"
  }" > /dev/null

echo "✅ Endpoint actualizado en GitHub"