#!/bin/bash

set -e

echo "📦 Creating Lambda ZIP files..."
echo ""

# Directorio base
BASE_DIR="modules/lambda/functions"
PY_DIR="$BASE_DIR/py"
ZIP_DIR="$BASE_DIR/zip"

# Verificar que existe el directorio py
if [ ! -d "$PY_DIR" ]; then
    echo "❌ Error: Directory $PY_DIR does not exist"
    echo "Please create the directory structure first:"
    echo "  mkdir -p $PY_DIR/generate_article"
    echo "  mkdir -p $PY_DIR/get_article"
    exit 1
fi

# Crear directorio zip si no existe
mkdir -p "$ZIP_DIR"

# ============================================
# Generate Article Lambda
# ============================================

echo "📝 Processing generate_article..."

LAMBDA_NAME="generate_article"
LAMBDA_PY_DIR="$PY_DIR/$LAMBDA_NAME"
ZIP_FILE="$ZIP_DIR/lambda_${LAMBDA_NAME}.zip"

if [ -f "$LAMBDA_PY_DIR/index.py" ]; then
    # Ir al directorio de la lambda
    cd "$LAMBDA_PY_DIR"

    # Crear ZIP
    zip -r "../../../zip/lambda_${LAMBDA_NAME}.zip" . > /dev/null 2>&1

    # Volver al directorio original
    cd - > /dev/null

    # Verificar tamaño
    SIZE=$(ls -lh "$ZIP_FILE" | awk '{print $5}')
    echo "   ✅ Created: lambda_${LAMBDA_NAME}.zip ($SIZE)"
else
    echo "   ❌ Error: $LAMBDA_PY_DIR/index.py not found"
    echo "      Please create the file first"
    exit 1
fi

# ============================================
# Get Article Lambda
# ============================================

echo "📝 Processing get_article..."

LAMBDA_NAME="get_article"
LAMBDA_PY_DIR="$PY_DIR/$LAMBDA_NAME"
ZIP_FILE="$ZIP_DIR/lambda_${LAMBDA_NAME}.zip"

if [ -f "$LAMBDA_PY_DIR/index.py" ]; then
    # Ir al directorio de la lambda
    cd "$LAMBDA_PY_DIR"

    # Crear ZIP
    zip -r "../../../zip/lambda_${LAMBDA_NAME}.zip" . > /dev/null 2>&1

    # Volver al directorio original
    cd - > /dev/null

    # Verificar tamaño
    SIZE=$(ls -lh "$ZIP_FILE" | awk '{print $5}')
    echo "   ✅ Created: lambda_${LAMBDA_NAME}.zip ($SIZE)"
else
    echo "   ❌ Error: $LAMBDA_PY_DIR/index.py not found"
    echo "      Please create the file first"
    exit 1
fi

# ============================================
# Summary
# ============================================

echo ""
echo "📊 Summary:"
echo "==========="

if [ -d "$ZIP_DIR" ]; then
    ls -lh "$ZIP_DIR"/*.zip 2>/dev/null || echo "No ZIP files found"
    echo ""
    echo "Total ZIPs created: $(ls -1 "$ZIP_DIR"/*.zip 2>/dev/null | wc -l)"
else
    echo "ZIP directory not found"
fi

echo ""
echo "✅ Done! Lambda ZIPs are ready in: $ZIP_DIR"
echo ""
echo "Next steps:"
echo "  1. terraform init"
echo "  2. terraform plan"
echo "  3. terraform apply"