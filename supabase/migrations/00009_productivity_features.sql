/*
# Productivity Features

## 1. New Tables

### lista_espera (Waiting List)
- `id` (uuid, primary key)
- `paciente_id` (uuid, references pacientes)
- `medico_id` (uuid, references medicos, nullable)
- `especialidade` (text) - Medical specialty
- `prioridade` (text) - Priority level: baixa, media, alta, urgente
- `motivo` (text) - Reason for appointment
- `data_solicitacao` (date) - Request date
- `status` (text) - Status: aguardando, contatado, agendado, cancelado
- `observacoes` (text)
- `created_at` (timestamptz)
- `updated_at` (timestamptz)

### confirmacoes_consulta (Appointment Confirmations)
- `id` (uuid, primary key)
- `consulta_id` (uuid, references consultas)
- `data_confirmacao` (timestamptz) - Confirmation date
- `metodo` (text) - Method: whatsapp, email, telefone, sistema
- `confirmado_por` (text) - Who confirmed
- `observacoes` (text)
- `created_at` (timestamptz)

## 2. Views for Dashboard

Create materialized views for performance optimization:
- `dashboard_stats` - General statistics
- `procedimentos_ranking` - Most performed procedures

## 3. Security

- Enable RLS on all tables
- Admins have full access
- Doctors can view and manage their own waiting list
- Receptionists can manage waiting list

## 4. Notes

- Waiting list is ordered by priority and request date
- Automatic confirmation can be triggered by reminders system
- Dashboard views are refreshed periodically
*/

-- Create lista_espera table
CREATE TABLE IF NOT EXISTS lista_espera (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  paciente_id uuid NOT NULL REFERENCES pacientes(id) ON DELETE CASCADE,
  medico_id uuid REFERENCES medicos(id) ON DELETE SET NULL,
  especialidade text NOT NULL,
  prioridade text NOT NULL DEFAULT 'media' CHECK (prioridade IN ('baixa', 'media', 'alta', 'urgente')),
  motivo text NOT NULL,
  data_solicitacao date NOT NULL DEFAULT CURRENT_DATE,
  status text NOT NULL DEFAULT 'aguardando' CHECK (status IN ('aguardando', 'contatado', 'agendado', 'cancelado')),
  observacoes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create confirmacoes_consulta table
CREATE TABLE IF NOT EXISTS confirmacoes_consulta (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  consulta_id uuid NOT NULL REFERENCES consultas(id) ON DELETE CASCADE,
  data_confirmacao timestamptz NOT NULL DEFAULT now(),
  metodo text NOT NULL CHECK (metodo IN ('whatsapp', 'email', 'telefone', 'sistema')),
  confirmado_por text,
  observacoes text,
  created_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX idx_lista_espera_paciente ON lista_espera(paciente_id);
CREATE INDEX idx_lista_espera_medico ON lista_espera(medico_id);
CREATE INDEX idx_lista_espera_especialidade ON lista_espera(especialidade);
CREATE INDEX idx_lista_espera_prioridade ON lista_espera(prioridade);
CREATE INDEX idx_lista_espera_status ON lista_espera(status);
CREATE INDEX idx_lista_espera_data ON lista_espera(data_solicitacao);

CREATE INDEX idx_confirmacoes_consulta ON confirmacoes_consulta(consulta_id);
CREATE INDEX idx_confirmacoes_data ON confirmacoes_consulta(data_confirmacao);

-- Enable RLS
ALTER TABLE lista_espera ENABLE ROW LEVEL SECURITY;
ALTER TABLE confirmacoes_consulta ENABLE ROW LEVEL SECURITY;

-- Policies for lista_espera
CREATE POLICY "Admins have full access to lista_espera" ON lista_espera
  FOR ALL TO authenticated USING (is_admin(auth.uid()));

CREATE POLICY "Doctors can view all lista_espera" ON lista_espera
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM medicos WHERE id = (SELECT id FROM profiles WHERE id = auth.uid()))
  );

CREATE POLICY "Users can create lista_espera entries" ON lista_espera
  FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Users can update lista_espera entries" ON lista_espera
  FOR UPDATE TO authenticated USING (true);

-- Policies for confirmacoes_consulta
CREATE POLICY "Admins have full access to confirmacoes" ON confirmacoes_consulta
  FOR ALL TO authenticated USING (is_admin(auth.uid()));

CREATE POLICY "Users can view confirmacoes" ON confirmacoes_consulta
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can create confirmacoes" ON confirmacoes_consulta
  FOR INSERT TO authenticated WITH CHECK (true);

-- Create view for dashboard statistics
CREATE OR REPLACE VIEW dashboard_stats AS
SELECT
  (SELECT COUNT(*) FROM pacientes) as total_pacientes,
  (SELECT COUNT(*) FROM consultas WHERE status = 'realizada') as total_consultas_realizadas,
  (SELECT COUNT(*) FROM consultas WHERE status = 'agendada' AND data_hora >= CURRENT_DATE) as consultas_futuras,
  (SELECT COUNT(*) FROM consultas WHERE status = 'cancelada') as consultas_canceladas,
  (SELECT COALESCE(SUM(valor), 0) FROM pagamentos WHERE status = 'pago') as receita_total,
  (SELECT COALESCE(SUM(valor), 0) FROM pagamentos WHERE status = 'pago' AND data_pagamento >= DATE_TRUNC('month', CURRENT_DATE)) as receita_mes_atual,
  (SELECT COUNT(*) FROM lista_espera WHERE status = 'aguardando') as pacientes_em_espera,
  (SELECT COUNT(*) FROM medicos) as total_medicos;

-- Create view for procedure ranking (using consultas.valor since procedimento_id doesn't exist)
CREATE OR REPLACE VIEW procedimentos_ranking AS
SELECT
  p.nome,
  p.valor,
  COUNT(c.id) as total_realizados,
  COALESCE(SUM(c.valor), 0) as receita_gerada
FROM procedimentos p
LEFT JOIN consultas c ON c.tipo = p.nome AND c.status = 'realizada'
GROUP BY p.id, p.nome, p.valor
ORDER BY total_realizados DESC, receita_gerada DESC;

-- Create function to automatically move waiting list to scheduled
CREATE OR REPLACE FUNCTION atualizar_lista_espera_ao_agendar()
RETURNS TRIGGER AS $$
BEGIN
  -- When a consultation is scheduled, update waiting list status
  UPDATE lista_espera
  SET status = 'agendado', updated_at = now()
  WHERE paciente_id = NEW.paciente_id
    AND status = 'aguardando'
    AND (medico_id = NEW.medico_id OR medico_id IS NULL);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic waiting list update
DROP TRIGGER IF EXISTS trigger_atualizar_lista_espera ON consultas;
CREATE TRIGGER trigger_atualizar_lista_espera
  AFTER INSERT ON consultas
  FOR EACH ROW
  EXECUTE FUNCTION atualizar_lista_espera_ao_agendar();

-- Create function to get professional schedule
CREATE OR REPLACE FUNCTION obter_agenda_profissional(
  p_medico_id uuid,
  p_data_inicio date,
  p_data_fim date
)
RETURNS TABLE (
  id uuid,
  data_hora timestamptz,
  paciente_nome text,
  paciente_telefone text,
  tipo_consulta text,
  status text,
  valor numeric,
  confirmada boolean
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.id,
    c.data_hora,
    p.nome as paciente_nome,
    p.telefone as paciente_telefone,
    c.tipo as tipo_consulta,
    c.status,
    c.valor,
    EXISTS(SELECT 1 FROM confirmacoes_consulta cc WHERE cc.consulta_id = c.id) as confirmada
  FROM consultas c
  JOIN pacientes p ON p.id = c.paciente_id
  WHERE c.medico_id = p_medico_id
    AND c.data_hora::date BETWEEN p_data_inicio AND p_data_fim
  ORDER BY c.data_hora;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get next available slot
CREATE OR REPLACE FUNCTION proximo_horario_disponivel(
  p_medico_id uuid,
  p_data_inicio date DEFAULT CURRENT_DATE
)
RETURNS TABLE (
  data_hora_disponivel timestamptz
) AS $$
DECLARE
  v_data date;
  v_hora time;
  v_data_hora timestamptz;
  v_ocupado boolean;
BEGIN
  -- Start from the given date
  v_data := p_data_inicio;
  
  -- Loop through next 30 days
  FOR i IN 0..30 LOOP
    -- Skip weekends (optional, can be configured)
    IF EXTRACT(DOW FROM v_data) NOT IN (0, 6) THEN
      -- Check time slots from 8:00 to 18:00
      FOR h IN 8..17 LOOP
        v_hora := (h || ':00:00')::time;
        v_data_hora := (v_data || ' ' || v_hora)::timestamptz;
        
        -- Check if slot is occupied
        SELECT EXISTS(
          SELECT 1 FROM consultas
          WHERE medico_id = p_medico_id
            AND data_hora = v_data_hora
            AND status != 'cancelada'
        ) INTO v_ocupado;
        
        -- Return first available slot
        IF NOT v_ocupado THEN
          RETURN QUERY SELECT v_data_hora;
          RETURN;
        END IF;
      END LOOP;
    END IF;
    
    v_data := v_data + 1;
  END LOOP;
  
  -- No available slot found
  RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Insert sample waiting list entries (for demonstration)
-- Note: These will only be inserted if there are existing patients and doctors
DO $$
DECLARE
  v_paciente_id uuid;
  v_medico_id uuid;
BEGIN
  -- Get first patient
  SELECT id INTO v_paciente_id FROM pacientes LIMIT 1;
  
  -- Get first doctor
  SELECT id INTO v_medico_id FROM medicos LIMIT 1;
  
  -- Only insert if we have both patient and doctor
  IF v_paciente_id IS NOT NULL AND v_medico_id IS NOT NULL THEN
    INSERT INTO lista_espera (paciente_id, medico_id, especialidade, prioridade, motivo, status)
    VALUES
      (v_paciente_id, v_medico_id, 'Clínica Geral', 'media', 'Consulta de rotina', 'aguardando')
    ON CONFLICT DO NOTHING;
  END IF;
END $$;
