/*
# Granular Module Permissions

## 1. Table Modifications

### profiles
- Update `modulos_permitidos` structure to include read/edit/delete permissions for each module

## 2. New Permission Structure
Each module now has three permission flags:
- `ler` (read) - Can view the module
- `editar` (edit) - Can create and modify records
- `excluir` (delete) - Can delete records

Example:
```json
{
  "pacientes": { "ler": true, "editar": true, "excluir": false },
  "consultas": { "ler": true, "editar": false, "excluir": false }
}
```

## 3. Available Modules
- pacientes
- consultas
- medicos
- prontuarios
- receitas
- procedimentos
- pagamentos
- relatorios
- historico

## 4. Security
- Admins always have full permissions (read/edit/delete) for all modules
- Default permissions grant full access (read/edit/delete) to all modules for new users
- If a module is not in the permissions object, it means no access
- Module permissions are checked throughout the application

## 5. Migration Strategy
- Convert existing array format to new object format
- Preserve existing user permissions during migration
*/

-- Update existing profiles to use new granular permission structure
UPDATE profiles 
SET modulos_permitidos = jsonb_build_object(
  'pacientes', jsonb_build_object('ler', true, 'editar', true, 'excluir', true),
  'consultas', jsonb_build_object('ler', true, 'editar', true, 'excluir', true),
  'medicos', jsonb_build_object('ler', true, 'editar', true, 'excluir', true),
  'prontuarios', jsonb_build_object('ler', true, 'editar', true, 'excluir', true),
  'receitas', jsonb_build_object('ler', true, 'editar', true, 'excluir', true),
  'procedimentos', jsonb_build_object('ler', true, 'editar', true, 'excluir', true),
  'pagamentos', jsonb_build_object('ler', true, 'editar', true, 'excluir', true),
  'relatorios', jsonb_build_object('ler', true, 'editar', true, 'excluir', true),
  'historico', jsonb_build_object('ler', true, 'editar', true, 'excluir', true)
)
WHERE modulos_permitidos IS NOT NULL;

-- Set default for new profiles
ALTER TABLE profiles 
  ALTER COLUMN modulos_permitidos SET DEFAULT jsonb_build_object(
    'pacientes', jsonb_build_object('ler', true, 'editar', true, 'excluir', true),
    'consultas', jsonb_build_object('ler', true, 'editar', true, 'excluir', true),
    'medicos', jsonb_build_object('ler', true, 'editar', true, 'excluir', true),
    'prontuarios', jsonb_build_object('ler', true, 'editar', true, 'excluir', true),
    'receitas', jsonb_build_object('ler', true, 'editar', true, 'excluir', true),
    'procedimentos', jsonb_build_object('ler', true, 'editar', true, 'excluir', true),
    'pagamentos', jsonb_build_object('ler', true, 'editar', true, 'excluir', true),
    'relatorios', jsonb_build_object('ler', true, 'editar', true, 'excluir', true),
    'historico', jsonb_build_object('ler', true, 'editar', true, 'excluir', true)
  );
