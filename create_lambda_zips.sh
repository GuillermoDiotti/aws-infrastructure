#!/bin/bash

set -e

echo "📦 Creating Lambda ZIP files..."
echo ""

BASE_DIR="modules/lambda_articulos"
PY_DIR="$BASE_DIR/py"
ZIP_DIR="$BASE_DIR/zip"

if [ ! -d "$PY_DIR" ]; then
    echo "❌ Error: Directory $PY_DIR does not exist"
    echo "Please create the directory structure first:"
    echo "  mkdir -p $PY_DIR/generate_article"
    echo "  mkdir -p $PY_DIR/get_article"
    exit 1
fi

mkdir -p "$ZIP_DIR"

echo "📝 Processing generate_article..."

LAMBDA_NAME="generate_article"
LAMBDA_PY_DIR="$PY_DIR/$LAMBDA_NAME"
ZIP_FILE="$ZIP_DIR/lambda_${LAMBDA_NAME}.zip"

if [ -f "$LAMBDA_PY_DIR/index.py" ]; then
    cd "$LAMBDA_PY_DIR"
    zip -r "../../zip/lambda_${LAMBDA_NAME}.zip" . > /dev/null 2>&1
    cd - > /dev/null

    SIZE=$(ls -lh "$ZIP_FILE" | awk '{print $5}')
    echo "   ✅ Created: lambda_${LAMBDA_NAME}.zip ($SIZE)"
else
    echo "   ❌ Error: $LAMBDA_PY_DIR/index.py not found"
    echo "      Please create the file first"
    exit 1
fi

echo "📝 Processing get_article..."

LAMBDA_NAME="get_article"
LAMBDA_PY_DIR="$PY_DIR/$LAMBDA_NAME"
ZIP_FILE="$ZIP_DIR/lambda_${LAMBDA_NAME}.zip"

if [ -f "$LAMBDA_PY_DIR/index.py" ]; then
    cd "$LAMBDA_PY_DIR"
    zip -r "../../zip/lambda_${LAMBDA_NAME}.zip" . > /dev/null 2>&1
    cd - > /dev/null

    SIZE=$(ls -lh "$ZIP_FILE" | awk '{print $5}')
    echo "   ✅ Created: lambda_${LAMBDA_NAME}.zip ($SIZE)"
else
    echo "   ❌ Error: $LAMBDA_PY_DIR/index.py not found"
    echo "      Please create the file first"
    exit 1
fi

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