#!/bin/bash

echo "=== Monitor de Saúde da Aplicação ==="
echo ""

# Cores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Detecta o ambiente e comando Python correto
PYTHON_CMD=""
if python3 --version &> /dev/null; then
    PYTHON_CMD="python3"
elif python --version &> /dev/null; then
    PYTHON_CMD="python"
elif py --version &> /dev/null; then
    PYTHON_CMD="py"
else
    echo -e "${RED}✗ Python não encontrado${NC}"
    exit 1
fi

# Verifica se a aplicação está respondendo
echo "1. Verificando saúde da aplicação..."
HEALTH=$(curl -s http://localhost:8080/health)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Aplicação está saudável${NC}"
    echo "$HEALTH" | $PYTHON_CMD -m json.tool
else
    echo -e "${RED}✗ Aplicação não está respondendo${NC}"
    exit 1
fi

echo ""
echo "2. Métricas da aplicação..."
METRICS=$(curl -s http://localhost:8080/metrics)
echo "$METRICS" | $PYTHON_CMD -m json.tool

echo ""
echo "3. Verificando taxa de sucesso..."
SUCCESS_RATE=$(echo "$METRICS" | $PYTHON_CMD -c "import sys, json; print(json.load(sys.stdin)['success_rate_percent'])")

# Verifica se conseguiu extrair a taxa
if [ -z "$SUCCESS_RATE" ]; then
    echo -e "${RED}✗ Erro ao extrair taxa de sucesso${NC}"
    exit 1
fi

# Comparação usando bc (Linux) ou awk (fallback para Windows)
if command -v bc &> /dev/null; then
    # Usa bc se disponível (Linux)
    if (( $(echo "$SUCCESS_RATE >= 95.0" | bc -l) )); then
        echo -e "${GREEN}✓ Taxa de sucesso: $SUCCESS_RATE% (OK)${NC}"
    else
        echo -e "${RED}✗ Taxa de sucesso: $SUCCESS_RATE% (BAIXA)${NC}"
    fi
else
    # Fallback para awk (Windows Git Bash)
    if awk "BEGIN {exit !($SUCCESS_RATE >= 95.0)}"; then
        echo -e "${GREEN}✓ Taxa de sucesso: $SUCCESS_RATE% (OK)${NC}"
    else
        echo -e "${RED}✗ Taxa de sucesso: $SUCCESS_RATE% (BAIXA)${NC}"
    fi
fi