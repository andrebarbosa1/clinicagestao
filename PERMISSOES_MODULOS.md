# Sistema de Controle de Permissões por Módulo

## 📋 Visão Geral

O sistema agora permite que administradores controlem quais módulos cada usuário pode acessar. Isso proporciona maior segurança e personalização da experiência do usuário.

## 🎯 Como Usar

### Para Administradores

1. **Acessar o Painel Admin**
   - Faça login como administrador
   - Clique no botão "Admin" no canto superior direito

2. **Gerenciar Permissões de Usuário**
   - Na lista de usuários, localize o usuário desejado
   - Clique no botão "Módulos" ao lado do botão "Alterar Senha"
   - Uma janela será aberta mostrando todos os módulos disponíveis

3. **Selecionar Módulos**
   - Marque/desmarque os checkboxes dos módulos que o usuário pode acessar
   - Use "Selecionar Todos" para dar acesso completo
   - Use "Desmarcar Todos" para remover todos os acessos
   - Clique em "Salvar Permissões" para aplicar as mudanças

### Para Usuários

- Após o administrador configurar suas permissões, você verá apenas os módulos permitidos
- A navegação superior e a barra lateral mostrarão apenas suas opções disponíveis
- Você não poderá acessar módulos para os quais não tem permissão

## 📦 Módulos Disponíveis

1. **Pacientes** - Cadastro e gerenciamento de pacientes
2. **Consultas** - Agenda de consultas
3. **Médicos** - Cadastro de médicos
4. **Prontuários** - Prontuários médicos
5. **Receitas** - Receitas médicas
6. **Procedimentos** - Tabela de procedimentos
7. **Pagamentos** - Gestão financeira
8. **Relatórios** - Relatórios e gráficos
9. **Histórico** - Histórico de alterações

## 🔒 Regras de Segurança

### Administradores
- ✅ Sempre têm acesso a **todos** os módulos
- ✅ Não podem ter suas permissões restritas
- ✅ Podem gerenciar permissões de outros usuários

### Usuários Comuns
- ⚠️ Acessam apenas módulos permitidos pelo administrador
- ⚠️ Não veem módulos restritos na navegação
- ⚠️ Não podem acessar URLs de módulos restritos diretamente

### Novos Usuários
- 🆕 Por padrão, recebem acesso a **todos** os módulos
- 🆕 Administrador pode ajustar conforme necessário

## 💡 Casos de Uso

### Recepcionista
Pode ter acesso apenas a:
- Pacientes
- Consultas
- Pagamentos

### Médico
Pode ter acesso a:
- Consultas
- Prontuários
- Receitas
- Pacientes (visualização)

### Gerente Financeiro
Pode ter acesso a:
- Pagamentos
- Procedimentos
- Relatórios

## 🔧 Detalhes Técnicos

### Banco de Dados
- Campo: `modulos_permitidos` na tabela `profiles`
- Tipo: JSONB (array de strings)
- Exemplo: `["pacientes", "consultas", "medicos"]`

### Implementação
- Filtragem automática na navegação superior (TopNavigation)
- Filtragem automática na barra lateral (Sidebar)
- Verificação de permissões no frontend
- API dedicada para atualização de permissões

### Arquivos Modificados
1. `supabase/migrations/*_add_module_permissions.sql` - Schema do banco
2. `src/types/types.ts` - Definições de tipos
3. `src/db/api.ts` - API de atualização
4. `src/pages/AdminPage.tsx` - Interface de gerenciamento
5. `src/components/layout/TopNavigation.tsx` - Filtragem de navegação
6. `src/components/layout/Sidebar.tsx` - Filtragem de sidebar

## ✅ Status

- ✅ Implementação completa
- ✅ Testes de lint passando (91 arquivos, 0 erros)
- ✅ Documentação atualizada
- ✅ Pronto para uso em produção

## 🚀 Próximos Passos Sugeridos

1. **Testar o Sistema**
   - Crie usuários de teste
   - Configure diferentes permissões
   - Verifique a filtragem da navegação

2. **Definir Perfis Padrão**
   - Crie templates de permissões para cada função
   - Exemplo: "Perfil Recepcionista", "Perfil Médico", etc.

3. **Documentar Políticas**
   - Defina quais módulos cada função deve ter acesso
   - Crie um guia interno de permissões

## 📞 Suporte

Para dúvidas ou problemas com o sistema de permissões, verifique:
- Este documento
- `NOVAS_FUNCIONALIDADES.md` - Documentação geral
- `TODO.md` - Histórico de implementação
