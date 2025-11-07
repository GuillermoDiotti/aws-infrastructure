#!/bin/bash

set -e

echo "🔨 Building psycopg2 Lambda Layer (Python 3.12)"
echo "================================================"

# Directory setup - ASEGURAR que esté en el lugar correcto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📍 Script directory: $SCRIPT_DIR"

LAYER_DIR="$SCRIPT_DIR/layers"
PYTHON_DIR="$LAYER_DIR/python"

echo "📂 Layer directory: $LAYER_DIR"

# Clean old files
echo "🧹 Cleaning old files..."
rm -rf "$PYTHON_DIR"
rm -f "$LAYER_DIR/psycopg2-layer.zip"

# Create directory structure
mkdir -p "$PYTHON_DIR"

# Install psycopg2-binary
echo "📦 Installing psycopg2-binary for AWS Lambda Python 3.12..."

pip3 install \
  --platform manylinux2014_x86_64 \
  --target="$PYTHON_DIR" \
  --implementation cp \
  --python-version 3.12 \
  --only-binary=:all: \
  --upgrade \
  psycopg2-binary==2.9.9

if [ $? -ne 0 ]; then
    echo "❌ Failed to install psycopg2-binary"
    exit 1
fi

# Verify installation
echo ""
echo "📋 Verifying installation..."
if [ -d "$PYTHON_DIR/psycopg2" ]; then
    echo "✅ psycopg2 directory found"
    ls -lh "$PYTHON_DIR/psycopg2/" | head -5
else
    echo "❌ psycopg2 directory NOT found"
    exit 1
fi

# Create zip file IN THE CORRECT LOCATION
echo ""
echo "🗜️  Creating zip file..."
cd "$LAYER_DIR"
zip -r psycopg2-layer.zip python/ -q

if [ -f "$LAYER_DIR/psycopg2-layer.zip" ]; then
    SIZE=$(du -h "$LAYER_DIR/psycopg2-layer.zip" | cut -f1)
    echo "✅ Layer created successfully!"
    echo "📍 Location: $LAYER_DIR/psycopg2-layer.zip"
    echo "📦 Size: $SIZE"
    ls -lh "$LAYER_DIR/psycopg2-layer.zip"
else
    echo "❌ Failed to create zip"
    exit 1
fi

cd "$SCRIPT_DIR"

echo ""
echo "✨ Done! Now run 'terraform apply' to deploy the layer."