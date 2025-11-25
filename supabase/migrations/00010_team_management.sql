/*
# Team Management System

## 1. New Tables

### escalas_trabalho (Work Schedules)
- `id` (uuid, primary key)
- `medico_id` (uuid, references medicos)
- `dia_semana` (integer) - Day of week (0=Sunday, 6=Saturday)
- `hora_inicio` (time) - Start time
- `hora_fim` (time) - End time
- `ativo` (boolean) - Active schedule
- `created_at` (timestamptz)
- `updated_at` (timestamptz)

### ferias_ausencias (Vacations and Absences)
- `id` (uuid, primary key)
- `medico_id` (uuid, references medicos)
- `tipo` (text) - Type: ferias, licenca, falta, outro
- `data_inicio` (date) - Start date
- `data_fim` (date) - End date
- `motivo` (text) - Reason
- `status` (text) - Status: pendente, aprovado, rejeitado
- `aprovado_por` (uuid, references profiles, nullable)
- `data_aprovacao` (date, nullable)
- `observacoes` (text)
- `created_at` (timestamptz)
- `updated_at` (timestamptz)

### comissoes (Commissions)
- `id` (uuid, primary key)
- `medico_id` (uuid, references medicos)
- `consulta_id` (uuid, references consultas, nullable)
- `procedimento_nome` (text) - Procedure name
- `valor_procedimento` (numeric) - Procedure value
- `percentual_comissao` (numeric) - Commission percentage
- `valor_comissao` (numeric) - Commission value
- `data_referencia` (date) - Reference date
- `status` (text) - Status: pendente, pago, cancelado
- `data_pagamento` (date, nullable)
- `observacoes` (text)
- `created_at` (timestamptz)
- `updated_at` (timestamptz)

### configuracao_comissoes (Commission Configuration)
- `id` (uuid, primary key)
- `medico_id` (uuid, references medicos, nullable) - Null = default for all
- `procedimento_nome` (text, nullable) - Null = applies to all procedures
- `percentual` (numeric) - Commission percentage
- `ativo` (boolean)
- `created_at` (timestamptz)
- `updated_at` (timestamptz)

## 2. Security

- Enable RLS on all tables
- Admins have full access
- Doctors can view their own schedules, vacations, and commissions
- Doctors can request vacations/absences
- Only admins can approve vacations/absences

## 3. Notes

- Work schedules define regular working hours
- Vacations/absences override regular schedules
- Commissions are calculated automatically based on configuration
- Commission status tracks payment lifecycle
*/

-- Create escalas_trabalho table
CREATE TABLE IF NOT EXISTS escalas_trabalho (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  medico_id uuid NOT NULL REFERENCES medicos(id) ON DELETE CASCADE,
  dia_semana integer NOT NULL CHECK (dia_semana >= 0 AND dia_semana <= 6),
  hora_inicio time NOT NULL,
  hora_fim time NOT NULL,
  ativo boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create ferias_ausencias table
CREATE TABLE IF NOT EXISTS ferias_ausencias (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  medico_id uuid NOT NULL REFERENCES medicos(id) ON DELETE CASCADE,
  tipo text NOT NULL CHECK (tipo IN ('ferias', 'licenca', 'falta', 'outro')),
  data_inicio date NOT NULL,
  data_fim date NOT NULL,
  motivo text NOT NULL,
  status text NOT NULL DEFAULT 'pendente' CHECK (status IN ('pendente', 'aprovado', 'rejeitado')),
  aprovado_por uuid REFERENCES profiles(id),
  data_aprovacao date,
  observacoes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT data_fim_maior_que_inicio CHECK (data_fim >= data_inicio)
);

-- Create comissoes table
CREATE TABLE IF NOT EXISTS comissoes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  medico_id uuid NOT NULL REFERENCES medicos(id) ON DELETE CASCADE,
  consulta_id uuid REFERENCES consultas(id) ON DELETE SET NULL,
  procedimento_nome text NOT NULL,
  valor_procedimento numeric NOT NULL,
  percentual_comissao numeric NOT NULL,
  valor_comissao numeric NOT NULL,
  data_referencia date NOT NULL,
  status text NOT NULL DEFAULT 'pendente' CHECK (status IN ('pendente', 'pago', 'cancelado')),
  data_pagamento date,
  observacoes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create configuracao_comissoes table
CREATE TABLE IF NOT EXISTS configuracao_comissoes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  medico_id uuid REFERENCES medicos(id) ON DELETE CASCADE,
  procedimento_nome text,
  percentual numeric NOT NULL CHECK (percentual >= 0 AND percentual <= 100),
  ativo boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX idx_escalas_medico ON escalas_trabalho(medico_id);
CREATE INDEX idx_escalas_dia ON escalas_trabalho(dia_semana);
CREATE INDEX idx_escalas_ativo ON escalas_trabalho(ativo);

CREATE INDEX idx_ferias_medico ON ferias_ausencias(medico_id);
CREATE INDEX idx_ferias_status ON ferias_ausencias(status);
CREATE INDEX idx_ferias_datas ON ferias_ausencias(data_inicio, data_fim);

CREATE INDEX idx_comissoes_medico ON comissoes(medico_id);
CREATE INDEX idx_comissoes_consulta ON comissoes(consulta_id);
CREATE INDEX idx_comissoes_status ON comissoes(status);
CREATE INDEX idx_comissoes_data ON comissoes(data_referencia);

CREATE INDEX idx_config_comissoes_medico ON configuracao_comissoes(medico_id);
CREATE INDEX idx_config_comissoes_procedimento ON configuracao_comissoes(procedimento_nome);
CREATE INDEX idx_config_comissoes_ativo ON configuracao_comissoes(ativo);

-- Enable RLS
ALTER TABLE escalas_trabalho ENABLE ROW LEVEL SECURITY;
ALTER TABLE ferias_ausencias ENABLE ROW LEVEL SECURITY;
ALTER TABLE comissoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE configuracao_comissoes ENABLE ROW LEVEL SECURITY;

-- Policies for escalas_trabalho
CREATE POLICY "Admins have full access to escalas" ON escalas_trabalho
  FOR ALL TO authenticated USING (is_admin(auth.uid()));

CREATE POLICY "Doctors can view their own escalas" ON escalas_trabalho
  FOR SELECT TO authenticated USING (
    medico_id = (SELECT id FROM profiles WHERE id = auth.uid())
  );

-- Policies for ferias_ausencias
CREATE POLICY "Admins have full access to ferias_ausencias" ON ferias_ausencias
  FOR ALL TO authenticated USING (is_admin(auth.uid()));

CREATE POLICY "Doctors can view their own ferias_ausencias" ON ferias_ausencias
  FOR SELECT TO authenticated USING (
    medico_id = (SELECT id FROM profiles WHERE id = auth.uid())
  );

CREATE POLICY "Doctors can create ferias_ausencias requests" ON ferias_ausencias
  FOR INSERT TO authenticated WITH CHECK (
    medico_id = (SELECT id FROM profiles WHERE id = auth.uid())
  );

-- Policies for comissoes
CREATE POLICY "Admins have full access to comissoes" ON comissoes
  FOR ALL TO authenticated USING (is_admin(auth.uid()));

CREATE POLICY "Doctors can view their own comissoes" ON comissoes
  FOR SELECT TO authenticated USING (
    medico_id = (SELECT id FROM profiles WHERE id = auth.uid())
  );

-- Policies for configuracao_comissoes
CREATE POLICY "Admins have full access to configuracao_comissoes" ON configuracao_comissoes
  FOR ALL TO authenticated USING (is_admin(auth.uid()));

CREATE POLICY "Doctors can view their own configuracao_comissoes" ON configuracao_comissoes
  FOR SELECT TO authenticated USING (
    medico_id = (SELECT id FROM profiles WHERE id = auth.uid()) OR medico_id IS NULL
  );

-- Function to calculate commission
CREATE OR REPLACE FUNCTION calcular_comissao(
  p_medico_id uuid,
  p_procedimento_nome text,
  p_valor_procedimento numeric
)
RETURNS numeric AS $$
DECLARE
  v_percentual numeric;
BEGIN
  -- Try to find specific configuration for doctor and procedure
  SELECT percentual INTO v_percentual
  FROM configuracao_comissoes
  WHERE medico_id = p_medico_id
    AND procedimento_nome = p_procedimento_nome
    AND ativo = true
  LIMIT 1;
  
  -- If not found, try doctor-specific default (null procedure)
  IF v_percentual IS NULL THEN
    SELECT percentual INTO v_percentual
    FROM configuracao_comissoes
    WHERE medico_id = p_medico_id
      AND procedimento_nome IS NULL
      AND ativo = true
    LIMIT 1;
  END IF;
  
  -- If still not found, try global default for procedure
  IF v_percentual IS NULL THEN
    SELECT percentual INTO v_percentual
    FROM configuracao_comissoes
    WHERE medico_id IS NULL
      AND procedimento_nome = p_procedimento_nome
      AND ativo = true
    LIMIT 1;
  END IF;
  
  -- If still not found, try global default (null doctor, null procedure)
  IF v_percentual IS NULL THEN
    SELECT percentual INTO v_percentual
    FROM configuracao_comissoes
    WHERE medico_id IS NULL
      AND procedimento_nome IS NULL
      AND ativo = true
    LIMIT 1;
  END IF;
  
  -- If no configuration found, return 0
  IF v_percentual IS NULL THEN
    RETURN 0;
  END IF;
  
  -- Calculate commission
  RETURN ROUND((p_valor_procedimento * v_percentual / 100), 2);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to automatically create commission when consultation is completed
CREATE OR REPLACE FUNCTION criar_comissao_automatica()
RETURNS TRIGGER AS $$
DECLARE
  v_percentual numeric;
  v_valor_comissao numeric;
BEGIN
  -- Only create commission if consultation is marked as 'realizada' and has a value
  IF NEW.status = 'realizada' AND NEW.valor > 0 THEN
    -- Calculate commission
    v_valor_comissao := calcular_comissao(NEW.medico_id, NEW.tipo, NEW.valor);
    
    -- Get percentage used
    SELECT percentual INTO v_percentual
    FROM configuracao_comissoes
    WHERE (medico_id = NEW.medico_id OR medico_id IS NULL)
      AND (procedimento_nome = NEW.tipo OR procedimento_nome IS NULL)
      AND ativo = true
    ORDER BY 
      CASE WHEN medico_id IS NOT NULL AND procedimento_nome IS NOT NULL THEN 1
           WHEN medico_id IS NOT NULL AND procedimento_nome IS NULL THEN 2
           WHEN medico_id IS NULL AND procedimento_nome IS NOT NULL THEN 3
           ELSE 4 END
    LIMIT 1;
    
    -- Create commission record if percentage found
    IF v_percentual IS NOT NULL AND v_valor_comissao > 0 THEN
      INSERT INTO comissoes (
        medico_id,
        consulta_id,
        procedimento_nome,
        valor_procedimento,
        percentual_comissao,
        valor_comissao,
        data_referencia,
        status
      ) VALUES (
        NEW.medico_id,
        NEW.id,
        NEW.tipo,
        NEW.valor,
        v_percentual,
        v_valor_comissao,
        NEW.data_hora::date,
        'pendente'
      );
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic commission creation
DROP TRIGGER IF EXISTS trigger_criar_comissao_automatica ON consultas;
CREATE TRIGGER trigger_criar_comissao_automatica
  AFTER INSERT OR UPDATE OF status ON consultas
  FOR EACH ROW
  EXECUTE FUNCTION criar_comissao_automatica();

-- Function to check if doctor is available
CREATE OR REPLACE FUNCTION medico_disponivel(
  p_medico_id uuid,
  p_data date,
  p_hora time
)
RETURNS boolean AS $$
DECLARE
  v_dia_semana integer;
  v_tem_escala boolean;
  v_tem_ausencia boolean;
BEGIN
  -- Get day of week (0=Sunday, 6=Saturday)
  v_dia_semana := EXTRACT(DOW FROM p_data);
  
  -- Check if doctor has a schedule for this day and time
  SELECT EXISTS(
    SELECT 1 FROM escalas_trabalho
    WHERE medico_id = p_medico_id
      AND dia_semana = v_dia_semana
      AND hora_inicio <= p_hora
      AND hora_fim >= p_hora
      AND ativo = true
  ) INTO v_tem_escala;
  
  -- If no schedule, doctor is not available
  IF NOT v_tem_escala THEN
    RETURN false;
  END IF;
  
  -- Check if doctor has vacation/absence on this date
  SELECT EXISTS(
    SELECT 1 FROM ferias_ausencias
    WHERE medico_id = p_medico_id
      AND data_inicio <= p_data
      AND data_fim >= p_data
      AND status = 'aprovado'
  ) INTO v_tem_ausencia;
  
  -- Doctor is available if has schedule and no absence
  RETURN NOT v_tem_ausencia;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Insert default commission configuration (10% for all procedures)
INSERT INTO configuracao_comissoes (medico_id, procedimento_nome, percentual, ativo)
VALUES (NULL, NULL, 10, true)
ON CONFLICT DO NOTHING;
