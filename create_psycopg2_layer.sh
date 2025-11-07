#!/bin/bash

echo "🔨 Creating psycopg2 Lambda Layer"
echo "=================================="

# Asegurarse de estar en el directorio correcto
cd aws-infrastructure/modules/lambda_comentarios

# Limpiar directorios anteriores
echo "🧹 Cleaning old files..."
rm -rf aws-infrastructure/modules/lambda_comentarios/layers
rm -f layers/psycopg2-layer.zip

# Crear estructura
mkdir -p /modules/lambda_comentarios/layers/python

# Instalar psycopg2-binary
echo "📦 Installing psycopg2-binary..."
pip3 install \
  --platform manylinux2014_x86_64 \
  --target=layers/python \
  --implementation cp \
  --python-version 3.12 \
  --only-binary=:all: \
  --upgrade \
  psycopg2-binary

if [ $? -ne 0 ]; then
    echo "❌ Failed to install psycopg2-binary"
    exit 1
fi

# Crear el zip
echo "🗜️  Creating zip file..."
ce aws-infrastructure/modules/lambda_comentarios/layers
zip -r psycopg2-layer.zip python/ > /dev/null

if [ -f psycopg2-layer.zip ]; then
    SIZE=$(du -h psycopg2-layer.zip | cut -f1)
    echo "✅ Layer created successfully!"
    echo "📍 Location: $(pwd)/psycopg2-layer.zip"
    echo "📦 Size: $SIZE"
else
    echo "❌ Failed to create zip"
    exit 1
fi

cd ../..
echo "✨ Done! Run 'terraform apply' to deploy the layer."