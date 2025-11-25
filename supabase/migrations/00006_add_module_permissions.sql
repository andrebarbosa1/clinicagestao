/*
# Add Module Permissions to Profiles

## 1. Table Modifications

### profiles
- Add `modulos_permitidos` (jsonb, default: all modules) - Array of module names the user can access

## 2. Available Modules
- pacientes
- consultas
- medicos
- prontuarios
- receitas
- procedimentos
- pagamentos
- relatorios
- historico

## 3. Security
- Admins always have access to all modules (enforced in application logic)
- Default permissions grant access to all modules for new users
- Module permissions are checked in the frontend navigation and route protection

## 4. Notes
- JSONB array format: ["pacientes", "consultas", "medicos"]
- Empty array means no access to any module
- Null or missing field defaults to all modules for backward compatibility
*/

-- Add module permissions field to profiles
ALTER TABLE profiles 
  ADD COLUMN IF NOT EXISTS modulos_permitidos jsonb DEFAULT '["pacientes", "consultas", "medicos", "prontuarios", "receitas", "procedimentos", "pagamentos", "relatorios", "historico"]'::jsonb;

-- Update existing profiles to have all modules by default
UPDATE profiles 
SET modulos_permitidos = '["pacientes", "consultas", "medicos", "prontuarios", "receitas", "procedimentos", "pagamentos", "relatorios", "historico"]'::jsonb
WHERE modulos_permitidos IS NULL;