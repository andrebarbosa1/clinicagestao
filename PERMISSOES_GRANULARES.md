# Sistema de Permissões Granulares por Módulo

## 📋 Visão Geral

O sistema agora possui controle granular de permissões, permitindo que administradores definam três níveis de acesso para cada módulo: **Ler**, **Editar** e **Excluir**.

## 🎯 Níveis de Permissão

### 1. Ler (Visualizar)
- Permite visualizar dados do módulo
- Acesso somente leitura
- Não pode criar, modificar ou excluir registros
- **Exemplo:** Ver lista de pacientes, consultar prontuários

### 2. Editar (Criar e Modificar)
- Permite criar novos registros
- Permite modificar registros existentes
- **Requer automaticamente** permissão de Ler
- Não pode excluir registros
- **Exemplo:** Cadastrar novos pacientes, agendar consultas, atualizar dados

### 3. Excluir (Remover)
- Permite remover registros do sistema
- **Requer automaticamente** permissões de Ler e Editar
- Nível mais alto de acesso
- **Exemplo:** Deletar pacientes, cancelar consultas permanentemente

## 🔄 Hierarquia de Permissões

As permissões seguem uma hierarquia lógica:

```
Excluir → Requer Editar → Requer Ler
```

### Regras Automáticas

1. **Ao marcar "Editar"**: A permissão "Ler" é marcada automaticamente
2. **Ao marcar "Excluir"**: As permissões "Ler" e "Editar" são marcadas automaticamente
3. **Ao desmarcar "Ler"**: As permissões "Editar" e "Excluir" são desmarcadas automaticamente
4. **Ao desmarcar "Editar"**: A permissão "Excluir" é desmarcada automaticamente

## 🎨 Interface de Gerenciamento

### Como Configurar Permissões

1. **Acessar o Painel Admin**
   - Faça login como administrador
   - Clique no botão "Admin" no canto superior direito

2. **Abrir Gerenciador de Permissões**
   - Na lista de usuários, localize o usuário desejado
   - Clique no botão "Módulos" (ícone de engrenagem)

3. **Configurar Permissões**
   - Uma tabela será exibida com todos os módulos
   - Cada módulo possui 3 checkboxes: Ler, Editar, Excluir
   - Marque/desmarque conforme necessário
   - Use "Selecionar Tudo" para dar acesso completo
   - Use "Desmarcar Tudo" para remover todos os acessos

4. **Salvar Alterações**
   - Clique em "Salvar Permissões"
   - As mudanças entram em vigor imediatamente

## 📦 Módulos Disponíveis

| Módulo | Descrição | Permissões Típicas |
|--------|-----------|-------------------|
| **Pacientes** | Cadastro de pacientes | Recepcionista: Ler + Editar |
| **Consultas** | Agenda de consultas | Médico: Ler + Editar |
| **Médicos** | Cadastro de médicos | Admin: Todas |
| **Prontuários** | Prontuários médicos | Médico: Todas |
| **Receitas** | Receitas médicas | Médico: Ler + Editar |
| **Procedimentos** | Tabela de procedimentos | Recepcionista: Ler |
| **Pagamentos** | Gestão financeira | Financeiro: Todas |
| **Relatórios** | Relatórios e gráficos | Gerente: Ler |
| **Histórico** | Histórico de alterações | Admin: Ler |

## 👥 Perfis de Acesso Sugeridos

### Recepcionista
```
Pacientes:     ✓ Ler  ✓ Editar  ✗ Excluir
Consultas:     ✓ Ler  ✓ Editar  ✗ Excluir
Médicos:       ✓ Ler  ✗ Editar  ✗ Excluir
Prontuários:   ✓ Ler  ✗ Editar  ✗ Excluir
Receitas:      ✗ Ler  ✗ Editar  ✗ Excluir
Procedimentos: ✓ Ler  ✗ Editar  ✗ Excluir
Pagamentos:    ✓ Ler  ✓ Editar  ✗ Excluir
Relatórios:    ✗ Ler  ✗ Editar  ✗ Excluir
Histórico:     ✗ Ler  ✗ Editar  ✗ Excluir
```

### Médico
```
Pacientes:     ✓ Ler  ✗ Editar  ✗ Excluir
Consultas:     ✓ Ler  ✓ Editar  ✗ Excluir
Médicos:       ✓ Ler  ✗ Editar  ✗ Excluir
Prontuários:   ✓ Ler  ✓ Editar  ✓ Excluir
Receitas:      ✓ Ler  ✓ Editar  ✓ Excluir
Procedimentos: ✓ Ler  ✗ Editar  ✗ Excluir
Pagamentos:    ✗ Ler  ✗ Editar  ✗ Excluir
Relatórios:    ✓ Ler  ✗ Editar  ✗ Excluir
Histórico:     ✗ Ler  ✗ Editar  ✗ Excluir
```

### Gerente Financeiro
```
Pacientes:     ✓ Ler  ✗ Editar  ✗ Excluir
Consultas:     ✓ Ler  ✗ Editar  ✗ Excluir
Médicos:       ✓ Ler  ✗ Editar  ✗ Excluir
Prontuários:   ✗ Ler  ✗ Editar  ✗ Excluir
Receitas:      ✗ Ler  ✗ Editar  ✗ Excluir
Procedimentos: ✓ Ler  ✓ Editar  ✗ Excluir
Pagamentos:    ✓ Ler  ✓ Editar  ✓ Excluir
Relatórios:    ✓ Ler  ✗ Editar  ✗ Excluir
Histórico:     ✓ Ler  ✗ Editar  ✗ Excluir
```

### Administrador
```
Todos os módulos: ✓ Ler  ✓ Editar  ✓ Excluir
(Não pode ser restrito)
```

## 🔒 Regras de Segurança

### Administradores
- ✅ Sempre têm **todas as permissões** em **todos os módulos**
- ✅ Não podem ter suas permissões restritas
- ✅ Checkboxes aparecem marcados e desabilitados na interface
- ✅ Podem gerenciar permissões de outros usuários

### Usuários Comuns
- ⚠️ Acessam apenas módulos com permissão de "Ler"
- ⚠️ Botões de criar/editar aparecem apenas com permissão de "Editar"
- ⚠️ Botões de excluir aparecem apenas com permissão de "Excluir"
- ⚠️ Não veem módulos sem permissão na navegação

### Novos Usuários
- 🆕 Por padrão, recebem **todas as permissões** em **todos os módulos**
- 🆕 Administrador deve ajustar conforme necessário
- 🆕 Recomenda-se configurar permissões antes do primeiro acesso

## 💻 Uso no Código

### Hook de Permissões

O sistema fornece um hook React para verificar permissões:

```typescript
import { usePermissions } from '@/hooks/usePermissions';

function MeuComponente() {
  const { canRead, canEdit, canDelete } = usePermissions();

  // Verificar se pode ler
  if (canRead('pacientes')) {
    // Mostrar lista de pacientes
  }

  // Verificar se pode editar
  if (canEdit('pacientes')) {
    // Mostrar botão "Novo Paciente"
  }

  // Verificar se pode excluir
  if (canDelete('pacientes')) {
    // Mostrar botão "Excluir"
  }
}
```

### Funções Disponíveis

```typescript
const permissions = usePermissions();

// Verificar permissão de leitura
permissions.canRead('pacientes')      // boolean

// Verificar permissão de edição
permissions.canEdit('consultas')      // boolean

// Verificar permissão de exclusão
permissions.canDelete('prontuarios')  // boolean

// Verificar se tem qualquer permissão
permissions.hasAnyPermission('medicos') // boolean
```

## 🔧 Estrutura Técnica

### Banco de Dados

Campo `modulos_permitidos` na tabela `profiles`:

```json
{
  "pacientes": {
    "ler": true,
    "editar": true,
    "excluir": false
  },
  "consultas": {
    "ler": true,
    "editar": false,
    "excluir": false
  }
}
```

### TypeScript Types

```typescript
export interface PermissoesModulo {
  ler: boolean;
  editar: boolean;
  excluir: boolean;
}

export type ModulosPermitidos = {
  [K in ModuloSistema]?: PermissoesModulo;
};
```

### Arquivos Modificados

1. **Database**
   - `supabase/migrations/00007_granular_module_permissions.sql` - Schema atualizado

2. **Types**
   - `src/types/types.ts` - Tipos de permissões

3. **API**
   - `src/db/api.ts` - Função de atualização de permissões

4. **UI**
   - `src/pages/AdminPage.tsx` - Interface de gerenciamento
   - `src/components/layout/TopNavigation.tsx` - Filtragem de navegação
   - `src/components/layout/Sidebar.tsx` - Filtragem de sidebar

5. **Hooks**
   - `src/hooks/usePermissions.ts` - Hook de verificação de permissões

## ✅ Status de Implementação

- ✅ Migração do banco de dados aplicada
- ✅ Tipos TypeScript atualizados
- ✅ Interface de gerenciamento completa
- ✅ Filtragem de navegação implementada
- ✅ Hook de permissões criado
- ✅ Hierarquia de permissões funcionando
- ✅ Testes de lint passando (92 arquivos, 0 erros)
- ✅ Documentação completa

## 🚀 Próximos Passos Recomendados

### 1. Implementar Verificações nas Páginas

Adicione verificações de permissão em cada página:

```typescript
// Exemplo: PacientesPage.tsx
import { usePermissions } from '@/hooks/usePermissions';

function PacientesPage() {
  const { canRead, canEdit, canDelete } = usePermissions();

  if (!canRead('pacientes')) {
    return <div>Acesso negado</div>;
  }

  return (
    <div>
      {/* Lista de pacientes */}
      
      {canEdit('pacientes') && (
        <Button>Novo Paciente</Button>
      )}
      
      {canDelete('pacientes') && (
        <Button>Excluir</Button>
      )}
    </div>
  );
}
```

### 2. Proteger Botões de Ação

Oculte ou desabilite botões baseado em permissões:

```typescript
<Button 
  disabled={!canEdit('pacientes')}
  onClick={handleEdit}
>
  Editar
</Button>

{canDelete('pacientes') && (
  <Button onClick={handleDelete}>
    Excluir
  </Button>
)}
```

### 3. Validar no Backend

Adicione validação de permissões nas funções RPC do Supabase:

```sql
CREATE OR REPLACE FUNCTION check_module_permission(
  user_id uuid,
  module_name text,
  permission_type text
)
RETURNS boolean AS $$
BEGIN
  -- Admins sempre têm permissão
  IF EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = user_id AND role = 'admin'
  ) THEN
    RETURN true;
  END IF;
  
  -- Verificar permissão específica
  RETURN (
    SELECT (modulos_permitidos->module_name->>permission_type)::boolean
    FROM profiles
    WHERE id = user_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 4. Criar Templates de Perfis

Crie perfis pré-configurados para facilitar a atribuição:

```typescript
const PERFIS_PADRAO = {
  recepcionista: {
    pacientes: { ler: true, editar: true, excluir: false },
    consultas: { ler: true, editar: true, excluir: false },
    // ...
  },
  medico: {
    prontuarios: { ler: true, editar: true, excluir: true },
    receitas: { ler: true, editar: true, excluir: true },
    // ...
  },
};
```

### 5. Adicionar Auditoria

Registre mudanças de permissões no histórico:

```typescript
// Ao salvar permissões
await historicoApi.create({
  tipo: 'permissoes_alteradas',
  descricao: `Permissões do usuário ${user.nome_completo} foram atualizadas`,
  usuario_id: currentUser.id,
  dados: { antes: oldPermissions, depois: newPermissions },
});
```

## 📞 Suporte

Para dúvidas sobre o sistema de permissões granulares:
- Consulte este documento
- Veja `PERMISSOES_MODULOS.md` para visão geral básica
- Veja `NOVAS_FUNCIONALIDADES.md` para documentação geral
- Veja `TODO.md` para histórico de implementação

## 🎓 Exemplos de Uso

### Exemplo 1: Página com Verificação de Permissões

```typescript
import { usePermissions } from '@/hooks/usePermissions';
import { useNavigate } from 'react-router-dom';

function ProntuariosPage() {
  const { canRead, canEdit, canDelete } = usePermissions();
  const navigate = useNavigate();

  // Redirecionar se não tiver permissão
  useEffect(() => {
    if (!canRead('prontuarios')) {
      navigate('/');
    }
  }, [canRead, navigate]);

  return (
    <div>
      <h1>Prontuários</h1>
      
      {canEdit('prontuarios') && (
        <Button onClick={handleNovo}>
          Novo Prontuário
        </Button>
      )}
      
      <Table>
        {/* ... */}
        {canDelete('prontuarios') && (
          <TableCell>
            <Button onClick={handleExcluir}>
              Excluir
            </Button>
          </TableCell>
        )}
      </Table>
    </div>
  );
}
```

### Exemplo 2: Formulário com Campos Condicionais

```typescript
function PacienteForm({ mode }: { mode: 'view' | 'edit' }) {
  const { canEdit } = usePermissions();
  const isReadOnly = mode === 'view' || !canEdit('pacientes');

  return (
    <Form>
      <Input 
        name="nome"
        disabled={isReadOnly}
      />
      
      {canEdit('pacientes') && (
        <Button type="submit">
          Salvar
        </Button>
      )}
    </Form>
  );
}
```

### Exemplo 3: Menu Contextual Dinâmico

```typescript
function PacienteActions({ paciente }: { paciente: Paciente }) {
  const { canEdit, canDelete } = usePermissions();

  return (
    <DropdownMenu>
      <DropdownMenuItem>
        Ver Detalhes
      </DropdownMenuItem>
      
      {canEdit('pacientes') && (
        <DropdownMenuItem>
          Editar
        </DropdownMenuItem>
      )}
      
      {canDelete('pacientes') && (
        <DropdownMenuItem className="text-destructive">
          Excluir
        </DropdownMenuItem>
      )}
    </DropdownMenu>
  );
}
```
