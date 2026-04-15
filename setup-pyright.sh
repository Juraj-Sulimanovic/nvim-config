#!/bin/bash

# Script to set up Pyright configuration for Python projects
# Usage: ./setup-pyright.sh [project-directory]

PROJECT_DIR=${1:-.}
TEMPLATE_FILE="$HOME/.config/nvim/pyright-template.json"

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: Template file not found at $TEMPLATE_FILE"
    exit 1
fi

if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: Directory $PROJECT_DIR does not exist"
    exit 1
fi

cd "$PROJECT_DIR"

# Copy template to project root
cp "$TEMPLATE_FILE" "pyrightconfig.json"
echo "✅ Created pyrightconfig.json in $(pwd)"

# Detect project type and show setup instructions
if [ -f "pyproject.toml" ]; then
    echo "📦 Poetry project detected"
    echo "💡 Run 'poetry install' to install dependencies"
elif [ -f "Pipfile" ]; then
    echo "🐍 Pipenv project detected"
    echo "💡 Run 'pipenv install' to install dependencies"
elif [ -f "requirements.txt" ]; then
    echo "📋 Requirements.txt detected"
    echo "💡 Consider creating a virtual environment:"
    echo "   python3 -m venv venv"
    echo "   source venv/bin/activate"
    echo "   pip install -r requirements.txt"
else
    echo "🔍 No specific Python project structure detected"
    echo "💡 Consider creating a virtual environment:"
    echo "   python3 -m venv venv"
    echo "   source venv/bin/activate"
fi

echo ""
echo "🎉 Pyright configuration is ready!"
echo "📝 You may need to restart your LSP server in Neovim"
