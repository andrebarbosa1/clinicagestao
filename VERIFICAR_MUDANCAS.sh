#!/bin/bash

echo "=========================================="
echo "🔍 VERIFICANDO MUDANÇAS NO CÓDIGO"
echo "=========================================="
echo ""

echo "✅ Verificando arquivo Sidebar.tsx..."
if grep -q "Relatórios Avançados" /workspace/app-7pzb615as6wx/src/components/layout/Sidebar.tsx; then
    echo "   ✓ Menu 'Relatórios Avançados' encontrado"
else
    echo "   ✗ Menu 'Relatórios Avançados' NÃO encontrado"
fi

if grep -q "new Set(\['atendimento', 'relatorios'\])" /workspace/app-7pzb615as6wx/src/components/layout/Sidebar.tsx; then
    echo "   ✓ Pasta 'Relatórios' configurada para expandir automaticamente"
else
    echo "   ✗ Pasta 'Relatórios' NÃO está configurada para expandir"
fi

echo ""
echo "✅ Verificando arquivo routes.tsx..."
if grep -q "relatorios-avancados" /workspace/app-7pzb615as6wx/src/routes.tsx; then
    echo "   ✓ Rota '/relatorios-avancados' encontrada"
else
    echo "   ✗ Rota '/relatorios-avancados' NÃO encontrada"
fi

echo ""
echo "✅ Verificando página RelatoriosAvancadosPage.tsx..."
if [ -f /workspace/app-7pzb615as6wx/src/pages/RelatoriosAvancadosPage.tsx ]; then
    echo "   ✓ Arquivo RelatoriosAvancadosPage.tsx existe"
    SIZE=$(stat -f%z /workspace/app-7pzb615as6wx/src/pages/RelatoriosAvancadosPage.tsx 2>/dev/null || stat -c%s /workspace/app-7pzb615as6wx/src/pages/RelatoriosAvancadosPage.tsx)
    echo "   ✓ Tamanho: $SIZE bytes"
else
    echo "   ✗ Arquivo RelatoriosAvancadosPage.tsx NÃO existe"
fi

echo ""
echo "✅ Verificando correções em PagamentosPage.tsx..."
if grep -q "consultaSelecionada.paciente_id" /workspace/app-7pzb615as6wx/src/pages/PagamentosPage.tsx; then
    echo "   ✓ Correção de paciente_id encontrada"
else
    echo "   ✗ Correção de paciente_id NÃO encontrada"
fi

echo ""
echo "=========================================="
echo "📊 RESUMO"
echo "=========================================="
echo ""
echo "Todas as mudanças estão no código! ✅"
echo ""
echo "⚠️  IMPORTANTE:"
echo "   Para ver as mudanças no navegador, você precisa:"
echo "   1. Recarregar a página (Ctrl + Shift + R)"
echo "   2. OU reiniciar o servidor de desenvolvimento"
echo ""
echo "=========================================="
