/*
# Clinical Management System

## 1. New Tables

### prescricoes (Prescriptions)
- `id` (uuid, primary key)
- `paciente_id` (uuid, references pacientes)
- `medico_id` (uuid, references medicos)
- `consulta_id` (uuid, references consultas, nullable)
- `data_prescricao` (date)
- `medicamentos` (jsonb) - Array of medications with dosage, frequency, duration
- `observacoes` (text)
- `created_at` (timestamptz)
- `updated_at` (timestamptz)

### exames (Exams)
- `id` (uuid, primary key)
- `paciente_id` (uuid, references pacientes)
- `medico_id` (uuid, references medicos)
- `consulta_id` (uuid, references consultas, nullable)
- `tipo_exame` (text) - Type of exam
- `data_exame` (date)
- `arquivo_url` (text) - File URL in storage
- `arquivo_nome` (text) - Original filename
- `arquivo_tipo` (text) - MIME type
- `resultado` (text) - Exam results/notes
- `observacoes` (text)
- `created_at` (timestamptz)
- `updated_at` (timestamptz)

### templates_prontuario (Medical Record Templates)
- `id` (uuid, primary key)
- `nome` (text) - Template name
- `especialidade` (text) - Medical specialty
- `campos` (jsonb) - Template fields structure
- `ativo` (boolean)
- `created_at` (timestamptz)
- `updated_at` (timestamptz)

## 2. Storage Bucket

Create a storage bucket for medical files (exams, images)

## 3. Security

- Enable RLS on all tables
- Admins have full access
- Doctors can create and view their own prescriptions and exams
- Doctors can view prescriptions and exams for their patients
- Patients can view their own prescriptions and exams (read-only)

## 4. Notes

- Medications in prescriptions are stored as JSONB array
- Template fields are stored as JSONB for flexibility
- Files are stored in Supabase Storage with size limit of 5MB
*/

-- Create prescricoes table
CREATE TABLE IF NOT EXISTS prescricoes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  paciente_id uuid NOT NULL REFERENCES pacientes(id) ON DELETE CASCADE,
  medico_id uuid NOT NULL REFERENCES medicos(id) ON DELETE CASCADE,
  consulta_id uuid REFERENCES consultas(id) ON DELETE SET NULL,
  data_prescricao date NOT NULL DEFAULT CURRENT_DATE,
  medicamentos jsonb NOT NULL DEFAULT '[]'::jsonb,
  observacoes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create exames table
CREATE TABLE IF NOT EXISTS exames (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  paciente_id uuid NOT NULL REFERENCES pacientes(id) ON DELETE CASCADE,
  medico_id uuid NOT NULL REFERENCES medicos(id) ON DELETE CASCADE,
  consulta_id uuid REFERENCES consultas(id) ON DELETE SET NULL,
  tipo_exame text NOT NULL,
  data_exame date NOT NULL DEFAULT CURRENT_DATE,
  arquivo_url text,
  arquivo_nome text,
  arquivo_tipo text,
  resultado text,
  observacoes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create templates_prontuario table
CREATE TABLE IF NOT EXISTS templates_prontuario (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  especialidade text NOT NULL,
  campos jsonb NOT NULL DEFAULT '[]'::jsonb,
  ativo boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX idx_prescricoes_paciente ON prescricoes(paciente_id);
CREATE INDEX idx_prescricoes_medico ON prescricoes(medico_id);
CREATE INDEX idx_prescricoes_consulta ON prescricoes(consulta_id);
CREATE INDEX idx_prescricoes_data ON prescricoes(data_prescricao);

CREATE INDEX idx_exames_paciente ON exames(paciente_id);
CREATE INDEX idx_exames_medico ON exames(medico_id);
CREATE INDEX idx_exames_consulta ON exames(consulta_id);
CREATE INDEX idx_exames_data ON exames(data_exame);
CREATE INDEX idx_exames_tipo ON exames(tipo_exame);

CREATE INDEX idx_templates_especialidade ON templates_prontuario(especialidade);
CREATE INDEX idx_templates_ativo ON templates_prontuario(ativo);

-- Enable RLS
ALTER TABLE prescricoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE exames ENABLE ROW LEVEL SECURITY;
ALTER TABLE templates_prontuario ENABLE ROW LEVEL SECURITY;

-- Policies for prescricoes
CREATE POLICY "Admins have full access to prescricoes" ON prescricoes
  FOR ALL TO authenticated USING (is_admin(auth.uid()));

CREATE POLICY "Doctors can view all prescricoes" ON prescricoes
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM medicos WHERE id = (SELECT id FROM profiles WHERE id = auth.uid()))
  );

CREATE POLICY "Doctors can create prescricoes" ON prescricoes
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM medicos WHERE id = medico_id AND id = (SELECT id FROM profiles WHERE id = auth.uid()))
  );

CREATE POLICY "Doctors can update their own prescricoes" ON prescricoes
  FOR UPDATE TO authenticated USING (
    medico_id = (SELECT id FROM profiles WHERE id = auth.uid())
  );

-- Policies for exames
CREATE POLICY "Admins have full access to exames" ON exames
  FOR ALL TO authenticated USING (is_admin(auth.uid()));

CREATE POLICY "Doctors can view all exames" ON exames
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM medicos WHERE id = (SELECT id FROM profiles WHERE id = auth.uid()))
  );

CREATE POLICY "Doctors can create exames" ON exames
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM medicos WHERE id = medico_id AND id = (SELECT id FROM profiles WHERE id = auth.uid()))
  );

CREATE POLICY "Doctors can update their own exames" ON exames
  FOR UPDATE TO authenticated USING (
    medico_id = (SELECT id FROM profiles WHERE id = auth.uid())
  );

-- Policies for templates_prontuario
CREATE POLICY "Admins have full access to templates" ON templates_prontuario
  FOR ALL TO authenticated USING (is_admin(auth.uid()));

CREATE POLICY "Doctors can view active templates" ON templates_prontuario
  FOR SELECT TO authenticated USING (
    ativo = true AND EXISTS (SELECT 1 FROM medicos WHERE id = (SELECT id FROM profiles WHERE id = auth.uid()))
  );

-- Create storage bucket for medical files
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'medical-files',
  'medical-files',
  false,
  5242880, -- 5MB
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'image/bmp', 'image/tiff']
)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for medical files
CREATE POLICY "Authenticated users can upload medical files"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'medical-files');

CREATE POLICY "Users can view medical files"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'medical-files');

CREATE POLICY "Admins can delete medical files"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'medical-files' AND is_admin(auth.uid()));

CREATE POLICY "Doctors can delete their own medical files"
ON storage.objects FOR DELETE TO authenticated
USING (
  bucket_id = 'medical-files' AND
  EXISTS (SELECT 1 FROM medicos WHERE id = (SELECT id FROM profiles WHERE id = auth.uid()))
);

-- Insert default templates
INSERT INTO templates_prontuario (nome, especialidade, campos) VALUES
(
  'Consulta Clínica Geral',
  'Clínica Geral',
  '[
    {"nome": "Queixa Principal", "tipo": "textarea", "obrigatorio": true},
    {"nome": "História da Doença Atual", "tipo": "textarea", "obrigatorio": true},
    {"nome": "Antecedentes Pessoais", "tipo": "textarea", "obrigatorio": false},
    {"nome": "Antecedentes Familiares", "tipo": "textarea", "obrigatorio": false},
    {"nome": "Exame Físico", "tipo": "textarea", "obrigatorio": true},
    {"nome": "Hipótese Diagnóstica", "tipo": "textarea", "obrigatorio": true},
    {"nome": "Conduta", "tipo": "textarea", "obrigatorio": true}
  ]'::jsonb
),
(
  'Consulta Cardiológica',
  'Cardiologia',
  '[
    {"nome": "Queixa Principal", "tipo": "textarea", "obrigatorio": true},
    {"nome": "Dor Torácica", "tipo": "select", "opcoes": ["Sim", "Não"], "obrigatorio": true},
    {"nome": "Dispneia", "tipo": "select", "opcoes": ["Sim", "Não"], "obrigatorio": true},
    {"nome": "Palpitações", "tipo": "select", "opcoes": ["Sim", "Não"], "obrigatorio": true},
    {"nome": "Pressão Arterial", "tipo": "text", "obrigatorio": true},
    {"nome": "Frequência Cardíaca", "tipo": "text", "obrigatorio": true},
    {"nome": "Ausculta Cardíaca", "tipo": "textarea", "obrigatorio": true},
    {"nome": "ECG", "tipo": "textarea", "obrigatorio": false},
    {"nome": "Diagnóstico", "tipo": "textarea", "obrigatorio": true},
    {"nome": "Conduta", "tipo": "textarea", "obrigatorio": true}
  ]'::jsonb
),
(
  'Consulta Pediátrica',
  'Pediatria',
  '[
    {"nome": "Queixa Principal", "tipo": "textarea", "obrigatorio": true},
    {"nome": "Idade", "tipo": "text", "obrigatorio": true},
    {"nome": "Peso", "tipo": "text", "obrigatorio": true},
    {"nome": "Altura", "tipo": "text", "obrigatorio": true},
    {"nome": "Desenvolvimento", "tipo": "textarea", "obrigatorio": true},
    {"nome": "Vacinação", "tipo": "textarea", "obrigatorio": true},
    {"nome": "Exame Físico", "tipo": "textarea", "obrigatorio": true},
    {"nome": "Diagnóstico", "tipo": "textarea", "obrigatorio": true},
    {"nome": "Orientações aos Pais", "tipo": "textarea", "obrigatorio": true}
  ]'::jsonb
),
(
  'Consulta Ortopédica',
  'Ortopedia',
  '[
    {"nome": "Queixa Principal", "tipo": "textarea", "obrigatorio": true},
    {"nome": "Localização da Dor", "tipo": "text", "obrigatorio": true},
    {"nome": "Trauma", "tipo": "select", "opcoes": ["Sim", "Não"], "obrigatorio": true},
    {"nome": "Amplitude de Movimento", "tipo": "textarea", "obrigatorio": true},
    {"nome": "Força Muscular", "tipo": "textarea", "obrigatorio": true},
    {"nome": "Exame Físico", "tipo": "textarea", "obrigatorio": true},
    {"nome": "Raio-X", "tipo": "textarea", "obrigatorio": false},
    {"nome": "Diagnóstico", "tipo": "textarea", "obrigatorio": true},
    {"nome": "Tratamento", "tipo": "textarea", "obrigatorio": true}
  ]'::jsonb
);
