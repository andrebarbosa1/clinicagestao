/*
# Add Audit Log and Appointment Reminders

## 1. New Tables

### audit_log
- `id` (uuid, primary key, default: gen_random_uuid())
- `table_name` (text, not null) - Name of the table that was modified
- `record_id` (uuid, not null) - ID of the record that was modified
- `action` (text, not null) - Type of action: 'INSERT', 'UPDATE', 'DELETE'
- `old_data` (jsonb) - Previous data (for UPDATE and DELETE)
- `new_data` (jsonb) - New data (for INSERT and UPDATE)
- `user_id` (uuid, references auth.users) - User who made the change
- `user_email` (text) - Email of the user who made the change
- `created_at` (timestamptz, default: now())

## 2. Table Modifications

### consultas (appointments)
- Add `lembrete_ativo` (boolean, default: false) - Whether reminder is active
- Add `lembrete_enviado` (boolean, default: false) - Whether reminder was sent
- Add `lembrete_data` (timestamptz) - When to send the reminder
- Add `lembrete_whatsapp` (boolean, default: false) - Send via WhatsApp
- Add `lembrete_email` (boolean, default: false) - Send via email

## 3. Security
- Enable RLS on `audit_log` table
- Only authenticated users can view audit logs
- Admins have full access to audit logs
- Create function to log changes automatically

## 4. Triggers
- Create triggers for all main tables to automatically log changes
- Triggers fire on INSERT, UPDATE, DELETE operations

## 5. Notes
- Audit log captures all data changes for compliance and tracking
- Reminders can be sent via WhatsApp or email
- Reminder date is calculated based on appointment date
*/

-- Create audit log table
CREATE TABLE IF NOT EXISTS audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name text NOT NULL,
  record_id uuid NOT NULL,
  action text NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
  old_data jsonb,
  new_data jsonb,
  user_id uuid REFERENCES auth.users(id),
  user_email text,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS on audit_log
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated users can view audit logs
CREATE POLICY "Authenticated users can view audit logs" ON audit_log
  FOR SELECT TO authenticated USING (true);

-- Policy: Admins have full access to audit logs
CREATE POLICY "Admins have full access to audit logs" ON audit_log
  FOR ALL TO authenticated USING (is_admin(auth.uid()));

-- Add reminder fields to consultas table
ALTER TABLE consultas 
  ADD COLUMN IF NOT EXISTS lembrete_ativo boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS lembrete_enviado boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS lembrete_data timestamptz,
  ADD COLUMN IF NOT EXISTS lembrete_whatsapp boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS lembrete_email boolean DEFAULT false;

-- Create function to log changes
CREATE OR REPLACE FUNCTION log_changes()
RETURNS TRIGGER AS $$
DECLARE
  user_email_val text;
BEGIN
  -- Get user email if user_id is available
  IF auth.uid() IS NOT NULL THEN
    SELECT email INTO user_email_val FROM auth.users WHERE id = auth.uid();
  END IF;

  -- Log the change
  IF TG_OP = 'DELETE' THEN
    INSERT INTO audit_log (table_name, record_id, action, old_data, user_id, user_email)
    VALUES (TG_TABLE_NAME, OLD.id, TG_OP, row_to_json(OLD), auth.uid(), user_email_val);
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_log (table_name, record_id, action, old_data, new_data, user_id, user_email)
    VALUES (TG_TABLE_NAME, NEW.id, TG_OP, row_to_json(OLD), row_to_json(NEW), auth.uid(), user_email_val);
    RETURN NEW;
  ELSIF TG_OP = 'INSERT' THEN
    INSERT INTO audit_log (table_name, record_id, action, new_data, user_id, user_email)
    VALUES (TG_TABLE_NAME, NEW.id, TG_OP, row_to_json(NEW), auth.uid(), user_email_val);
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create triggers for main tables
CREATE TRIGGER pacientes_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON pacientes
  FOR EACH ROW EXECUTE FUNCTION log_changes();

CREATE TRIGGER medicos_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON medicos
  FOR EACH ROW EXECUTE FUNCTION log_changes();

CREATE TRIGGER consultas_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON consultas
  FOR EACH ROW EXECUTE FUNCTION log_changes();

CREATE TRIGGER prontuarios_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON prontuarios
  FOR EACH ROW EXECUTE FUNCTION log_changes();

CREATE TRIGGER receitas_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON receitas
  FOR EACH ROW EXECUTE FUNCTION log_changes();

CREATE TRIGGER exames_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON exames
  FOR EACH ROW EXECUTE FUNCTION log_changes();

CREATE TRIGGER pagamentos_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON pagamentos
  FOR EACH ROW EXECUTE FUNCTION log_changes();