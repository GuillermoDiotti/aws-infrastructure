#!/bin/bash

set -e

echo "🔨 Creando Lambda Layer para psycopg2..."
echo ""

LAYER_DIR="modules/lambda_comentarios/layers"
BUILD_DIR="$LAYER_DIR/python"
ZIP_FILE="$LAYER_DIR/psycopg2-layer.zip"

# Limpiar directorio anterior
rm -rf "$BUILD_DIR"
rm -f "$ZIP_FILE"

# Crear estructura
mkdir -p "$BUILD_DIR"

echo "📦 Instalando psycopg2-binary..."
pip install psycopg2-binary -t "$BUILD_DIR" --platform manylinux2014_x86_64 --only-binary=:all:

echo "📦 Creando ZIP..."
# Comprimir desde el directorio layers, incluyendo la carpeta python/
(cd "$LAYER_DIR" && zip -r psycopg2-layer.zip python > /dev/null)

echo "✅ Layer creado exitosamente"
echo ""
ls -lh "$ZIP_FILE"

# Limpiar carpeta de build
rm -rf "$BUILD_DIR"

echo ""
echo "📍 Ruta completa: $(pwd)/$ZIP_FILE"
echo ""
echo "🎉 ¡Listo! Ahora puedes ejecutar 'terraform apply'"