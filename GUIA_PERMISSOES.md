# 🔐 Guia Rápido - Permissões de Recepção

## ✅ O QUE FOI FEITO

Recepcionistas agora **NÃO PODEM** criar ou editar:
- ❌ Médicos
- ❌ Usuários do sistema

---

## 🎯 COMO FUNCIONA

### Página de Médicos

#### Para Recepcionistas:
```
Botões DESABILITADOS:
├─ ❌ Novo Médico (mostra erro ao clicar)
├─ ❌ Editar (ícone de lápis cinza)
└─ ❌ Excluir (ícone de lixeira cinza)

Botões HABILITADOS:
├─ ✅ Consultar (atualizar lista)
├─ ✅ Pesquisar (buscar médicos)
└─ ✅ Visualizar (ver informações)
```

#### Para Admin e Médico:
```
Todos os botões HABILITADOS:
├─ ✅ Novo Médico
├─ ✅ Editar
├─ ✅ Excluir
├─ ✅ Consultar
└─ ✅ Pesquisar
```

---

### Página de Administração

#### Para Recepcionistas:
```
❌ ACESSO BLOQUEADO
   Página não carrega
```

#### Para Admin:
```
✅ ACESSO TOTAL
   Gerenciar usuários e permissões
```

---

## 📊 MATRIZ DE PERMISSÕES

### Gestão de Médicos

| Ação | Admin | Médico | Recepcionista |
|------|:-----:|:------:|:-------------:|
| Ver lista | ✅ | ✅ | ✅ |
| Pesquisar | ✅ | ✅ | ✅ |
| Criar | ✅ | ✅ | ❌ |
| Editar | ✅ | ✅ | ❌ |
| Excluir | ✅ | ✅ | ❌ |

### Gestão de Usuários

| Ação | Admin | Médico | Recepcionista |
|------|:-----:|:------:|:-------------:|
| Ver página | ✅ | ❌ | ❌ |
| Criar usuário | ✅ | ❌ | ❌ |
| Editar usuário | ✅ | ❌ | ❌ |
| Alterar função | ✅ | ❌ | ❌ |
| Gerenciar permissões | ✅ | ❌ | ❌ |

---

## 🧪 COMO TESTAR

### Teste Rápido:

1. **Faça login como recepcionista**
2. **Vá para "Cadastro de Médicos"**
3. **Tente clicar em "Novo Médico"**
   - ✅ Deve aparecer: "Você não tem permissão para criar médicos"
4. **Olhe para os botões de editar/excluir**
   - ✅ Devem estar cinza (desabilitados)
5. **Passe o mouse sobre os botões**
   - ✅ Deve mostrar: "Você não tem permissão..."

---

## 💡 MENSAGENS DE ERRO

Quando um recepcionista tenta executar ações bloqueadas:

### Criar Médico:
```
🔴 Acesso Negado
Você não tem permissão para criar médicos
```

### Editar Médico:
```
🔴 Acesso Negado
Você não tem permissão para editar médicos
```

### Excluir Médico:
```
🔴 Acesso Negado
Você não tem permissão para excluir médicos
```

---

## 🎨 APARÊNCIA VISUAL

### Botões Desabilitados:

```
┌─────────────────────────────────────┐
│  Ações                              │
│  [🔒 Editar]  [🔒 Excluir]         │
│   ↑ Cinza      ↑ Cinza             │
│   Não clica    Não clica           │
└─────────────────────────────────────┘
```

### Botões Habilitados:

```
┌─────────────────────────────────────┐
│  Ações                              │
│  [✏️ Editar]  [🗑️ Excluir]          │
│   ↑ Azul       ↑ Vermelho          │
│   Clicável     Clicável            │
└─────────────────────────────────────┘
```

---

## ✅ CHECKLIST DE VERIFICAÇÃO

Após implementação, verifique:

- [ ] Recepcionista NÃO consegue criar médico
- [ ] Recepcionista NÃO consegue editar médico
- [ ] Recepcionista NÃO consegue excluir médico
- [ ] Recepcionista CONSEGUE ver lista de médicos
- [ ] Recepcionista CONSEGUE pesquisar médicos
- [ ] Recepcionista NÃO acessa página de administração
- [ ] Admin CONSEGUE fazer tudo
- [ ] Médico CONSEGUE gerenciar médicos
- [ ] Mensagens de erro aparecem corretamente
- [ ] Botões ficam desabilitados visualmente

---

## 🔧 ARQUIVOS MODIFICADOS

```
src/pages/MedicosPage.tsx
├─ Adicionado: useAuth hook
├─ Adicionado: canEditMedicos verificação
├─ Modificado: handleSubmit (verifica permissão)
├─ Modificado: handleEdit (verifica permissão)
├─ Modificado: handleDelete (verifica permissão)
├─ Modificado: handleNewMedico (verifica permissão)
└─ Modificado: Botões de ação (disabled + title)
```

---

## 📝 NOTAS IMPORTANTES

### ⚠️ Segurança:

1. **Frontend apenas**
   - Proteção está na interface
   - Recomendado: Adicionar no backend também

2. **Próximos passos**
   - Implementar RLS no Supabase
   - Adicionar validação nas APIs
   - Criar logs de auditoria

### ✅ Funcionalidades mantidas:

- Recepcionistas ainda podem:
  - ✅ Gerenciar pacientes
  - ✅ Agendar consultas
  - ✅ Registrar pagamentos
  - ✅ Ver relatórios (se tiver permissão)
  - ✅ Todas as outras funções do sistema

---

## 🎯 RESUMO EXECUTIVO

| Item | Status |
|------|--------|
| **Restrição de Criar Médicos** | ✅ Implementado |
| **Restrição de Editar Médicos** | ✅ Implementado |
| **Restrição de Excluir Médicos** | ✅ Implementado |
| **Restrição de Administração** | ✅ Já existia |
| **Mensagens de Erro** | ✅ Implementado |
| **Botões Desabilitados** | ✅ Implementado |
| **Tooltips Informativos** | ✅ Implementado |
| **Testes** | ✅ Documentado |

---

**Status**: ✅ Concluído  
**Data**: 2025-11-22  
**Perfis Afetados**: Recepcionista  
**Perfis com Acesso Total**: Admin, Médico
