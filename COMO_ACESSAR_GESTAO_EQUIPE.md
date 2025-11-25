# Como Acessar a Gestão de Equipe

## 📍 Localização no Sistema

A funcionalidade **Gestão de Equipe** está disponível na barra de navegação superior do sistema.

### Passo a Passo:

1. **Faça login** no sistema como **Administrador**
   - Apenas usuários com perfil de administrador têm acesso à Gestão de Equipe

2. **Localize o menu** na barra superior
   - Você verá um botão chamado **"Gestão de Equipe"** com uma seta para baixo (▼)

3. **Clique no menu** "Gestão de Equipe"
   - Um menu suspenso será exibido com 3 opções:

## 📋 Opções Disponíveis

### 1. **Escalas de Trabalho**
- **Caminho**: Gestão de Equipe → Escalas de Trabalho
- **URL**: `/equipe/escalas`
- **Funcionalidades**:
  - Criar escalas de trabalho por dia da semana
  - Definir horários de início e fim
  - Ativar/desativar escalas
  - Visualizar escalas agrupadas por profissional

### 2. **Férias e Ausências**
- **Caminho**: Gestão de Equipe → Férias e Ausências
- **URL**: `/equipe/ferias-ausencias`
- **Funcionalidades**:
  - Criar solicitações de férias/ausências
  - Aprovar ou rejeitar solicitações
  - Visualizar histórico de ausências
  - Filtrar por status (Pendente, Aprovado, Rejeitado)

### 3. **Comissões**
- **Caminho**: Gestão de Equipe → Comissões
- **URL**: `/equipe/comissoes`
- **Funcionalidades**:
  - Visualizar comissões geradas automaticamente
  - Marcar comissões como pagas
  - Cancelar comissões
  - Filtrar por profissional e período
  - Ver totais (Pendente, Pago, Geral)

## 🎯 Exemplo Visual

```
┌─────────────────────────────────────────────────────────────────┐
│ Recepção | Agenda | Pacientes | ... | [Gestão de Equipe ▼]    │
│                                           │                       │
│                                           ├─ Escalas de Trabalho │
│                                           ├─ Férias e Ausências  │
│                                           └─ Comissões           │
└─────────────────────────────────────────────────────────────────┘
```

## ⚠️ Requisitos

- **Perfil necessário**: Administrador
- **Status**: Logado no sistema
- **Navegador**: Qualquer navegador moderno (Chrome, Firefox, Edge, Safari)

## 🔧 Recursos Implementados

✅ **Backend completo**:
- Tabelas no banco de dados
- APIs REST para todas as operações
- Cálculo automático de comissões
- Verificação de disponibilidade de médicos

✅ **Frontend completo**:
- Interface de usuário moderna e responsiva
- Formulários de criação e edição
- Filtros e buscas
- Notificações de sucesso/erro

## 📞 Suporte

Se você não conseguir visualizar o menu "Gestão de Equipe":
1. Verifique se está logado como **Administrador**
2. Atualize a página (F5)
3. Limpe o cache do navegador
4. Verifique se há erros no console do navegador (F12)

---

**Data**: 22/11/2025  
**Versão**: 1.0  
**Status**: ✅ Implementado e Funcional
