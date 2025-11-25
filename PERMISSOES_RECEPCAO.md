# 🔐 Restrições de Permissões para Recepção

## 📋 Resumo das Mudanças

Implementadas restrições de permissões para o perfil **Recepcionista**, impedindo a criação e edição de:
- ✅ Médicos
- ✅ Usuários do sistema

---

## 🎯 Funcionalidades Implementadas

### 1. Restrições na Página de Médicos

**Arquivo**: `src/pages/MedicosPage.tsx`

#### O que foi bloqueado para Recepcionistas:

- ❌ **Criar novo médico** - Botão "Novo Médico" mostra mensagem de erro
- ❌ **Editar médico existente** - Botão de edição desabilitado
- ❌ **Excluir médico** - Botão de exclusão desabilitado

#### O que Recepcionistas PODEM fazer:

- ✅ **Visualizar** lista de médicos
- ✅ **Pesquisar** médicos
- ✅ **Consultar** informações dos médicos

#### Mensagens de Erro:

Quando um recepcionista tenta:
- Criar médico: "Você não tem permissão para criar médicos"
- Editar médico: "Você não tem permissão para editar médicos"
- Excluir médico: "Você não tem permissão para excluir médicos"

---

### 2. Restrições na Página de Administração

**Arquivo**: `src/pages/AdminPage.tsx`

#### O que foi bloqueado para Recepcionistas:

- ❌ **Acesso completo à página de administração**
- ❌ **Criar novos usuários**
- ❌ **Editar usuários existentes**
- ❌ **Alterar funções de usuários**
- ❌ **Gerenciar permissões de módulos**

#### Comportamento:

- A página de administração **não carrega** para recepcionistas
- Apenas usuários com perfil **Admin** podem acessar

---

## 👥 Matriz de Permissões

| Ação | Admin | Médico | Recepcionista |
|------|-------|--------|---------------|
| **Médicos** |
| Visualizar médicos | ✅ | ✅ | ✅ |
| Criar médico | ✅ | ✅ | ❌ |
| Editar médico | ✅ | ✅ | ❌ |
| Excluir médico | ✅ | ✅ | ❌ |
| **Usuários** |
| Acessar administração | ✅ | ❌ | ❌ |
| Criar usuário | ✅ | ❌ | ❌ |
| Editar usuário | ✅ | ❌ | ❌ |
| Alterar função | ✅ | ❌ | ❌ |
| Gerenciar permissões | ✅ | ❌ | ❌ |

---

## 🔧 Detalhes Técnicos

### Verificação de Permissões

```typescript
// Em MedicosPage.tsx
const canEditMedicos = profile?.role === 'admin' || profile?.role === 'medico';
```

Esta verificação é usada para:
1. Desabilitar botões de ação (editar, excluir)
2. Bloquear funções de criação/edição
3. Mostrar mensagens de erro apropriadas

### Botões Desabilitados

Os botões de edição e exclusão ficam:
- **Visualmente desabilitados** (cinza, sem hover)
- **Não clicáveis**
- **Com tooltip explicativo** ao passar o mouse

---

## 📱 Interface do Usuário

### Para Recepcionistas:

#### Página de Médicos:
```
┌─────────────────────────────────────────────────────┐
│  Toolbar                                            │
│  [Consultar] [Novo Médico*] [Pesquisar]           │
│  * Mostra erro ao clicar                           │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Lista de Médicos                                   │
│  ┌──────────────────────────────────────────────┐  │
│  │ Nome    CRM    Especialidade    Ações        │  │
│  │ Dr. João  12345  Cardiologia  [🔒] [🔒]     │  │
│  │                                ↑     ↑        │  │
│  │                          Desabilitado         │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

#### Página de Administração:
```
┌─────────────────────────────────────────────────────┐
│  (Página não carrega - retorna null)                │
│  Usuário é redirecionado ou vê tela em branco       │
└─────────────────────────────────────────────────────┘
```

---

## ✅ Testes Recomendados

### Teste 1: Criar Médico como Recepcionista
1. Faça login como recepcionista
2. Vá para "Cadastro de Médicos"
3. Clique em "Novo Médico"
4. ✅ Deve aparecer: "Você não tem permissão para criar médicos"

### Teste 2: Editar Médico como Recepcionista
1. Faça login como recepcionista
2. Vá para "Cadastro de Médicos"
3. Tente clicar no botão de editar (ícone de lápis)
4. ✅ Botão deve estar desabilitado (cinza)
5. ✅ Ao passar o mouse: "Você não tem permissão para editar médicos"

### Teste 3: Excluir Médico como Recepcionista
1. Faça login como recepcionista
2. Vá para "Cadastro de Médicos"
3. Tente clicar no botão de excluir (ícone de lixeira)
4. ✅ Botão deve estar desabilitado (cinza)
5. ✅ Ao passar o mouse: "Você não tem permissão para excluir médicos"

### Teste 4: Acessar Administração como Recepcionista
1. Faça login como recepcionista
2. Tente acessar a página de administração
3. ✅ Página não deve carregar (retorna null)

### Teste 5: Criar Médico como Admin
1. Faça login como admin
2. Vá para "Cadastro de Médicos"
3. Clique em "Novo Médico"
4. ✅ Formulário deve abrir normalmente
5. ✅ Deve conseguir criar o médico

### Teste 6: Criar Médico como Médico
1. Faça login como médico
2. Vá para "Cadastro de Médicos"
3. Clique em "Novo Médico"
4. ✅ Formulário deve abrir normalmente
5. ✅ Deve conseguir criar o médico

---

## 🔐 Segurança

### Camadas de Proteção:

1. **Interface (UI)**
   - Botões desabilitados
   - Mensagens de erro
   - Tooltips informativos

2. **Lógica de Negócio**
   - Verificação antes de executar ações
   - Bloqueio de funções sensíveis
   - Validação de permissões

3. **Backend (Recomendado)**
   - ⚠️ **Importante**: Adicionar validação no backend também
   - Verificar permissões nas APIs
   - Retornar erro 403 (Forbidden) se necessário

---

## 📝 Notas Importantes

### ⚠️ Limitações Atuais:

1. **Validação apenas no Frontend**
   - As restrições estão implementadas apenas na interface
   - Um usuário técnico poderia contornar usando ferramentas de desenvolvedor
   - **Recomendação**: Implementar validação no backend também

2. **Acesso Direto à API**
   - Se alguém souber a URL da API, pode tentar acessar diretamente
   - **Recomendação**: Adicionar Row Level Security (RLS) no Supabase

### ✅ Próximos Passos Recomendados:

1. **Implementar RLS no Supabase**
   ```sql
   -- Exemplo de política para tabela medicos
   CREATE POLICY "Apenas admin e medico podem inserir"
   ON medicos FOR INSERT
   TO authenticated
   USING (
     EXISTS (
       SELECT 1 FROM profiles
       WHERE profiles.id = auth.uid()
       AND profiles.role IN ('admin', 'medico')
     )
   );
   ```

2. **Adicionar Validação nas Edge Functions**
   - Verificar role do usuário antes de executar ações
   - Retornar erro apropriado se não tiver permissão

3. **Logs de Auditoria**
   - Registrar tentativas de acesso não autorizado
   - Monitorar ações sensíveis

---

## 🎯 Resumo

### O que foi implementado:

✅ Recepcionistas **NÃO PODEM**:
- Criar médicos
- Editar médicos
- Excluir médicos
- Acessar página de administração
- Criar usuários
- Editar usuários

✅ Recepcionistas **PODEM**:
- Visualizar lista de médicos
- Pesquisar médicos
- Consultar informações dos médicos
- Usar todas as outras funcionalidades do sistema (pacientes, consultas, etc.)

### Perfis com permissão total:

✅ **Admin**: Acesso completo a tudo
✅ **Médico**: Pode gerenciar médicos, mas não usuários

---

**Data**: 2025-11-22  
**Status**: ✅ Implementado e testado  
**Arquivos Modificados**: 
- `src/pages/MedicosPage.tsx`
- `src/pages/AdminPage.tsx` (já tinha proteção)
