/*
# Create Complete Clinic System Schema

## 1. Drop Old Tables
- Drop all operational management tables

## 2. New Tables

### `medicos` (Doctors)
- `id` (uuid, primary key, default: gen_random_uuid())
- `nome` (text, doctor name)
- `crm` (text, medical license number)
- `especialidade` (text, specialty)
- `telefone` (text, phone)
- `email` (text, email)
- `status` (text, status: 'Ativo', 'Inativo')
- `created_at` (timestamptz, default: now())
- `updated_at` (timestamptz, default: now())

### `pacientes` (Patients)
- `id` (uuid, primary key, default: gen_random_uuid())
- `nome` (text, patient name)
- `cpf` (text, unique, CPF)
- `data_nascimento` (date, birth date)
- `sexo` (text, gender: 'Masculino', 'Feminino', 'Outro')
- `telefone` (text, phone)
- `email` (text, email)
- `endereco` (text, address)
- `convenio` (text, health insurance)
- `numero_convenio` (text, insurance number)
- `observacoes` (text, notes)
- `created_at` (timestamptz, default: now())
- `updated_at` (timestamptz, default: now())

### `consultas` (Appointments)
- `id` (uuid, primary key, default: gen_random_uuid())
- `paciente_id` (uuid, references pacientes)
- `medico_id` (uuid, references medicos)
- `data_hora` (timestamptz, appointment date/time)
- `tipo` (text, type: 'Consulta', 'Retorno', 'Exame', 'Procedimento')
- `status` (text, status: 'Agendada', 'Confirmada', 'Realizada', 'Cancelada', 'Faltou')
- `motivo` (text, reason for visit)
- `observacoes` (text, notes)
- `valor` (numeric, price)
- `created_at` (timestamptz, default: now())
- `updated_at` (timestamptz, default: now())

### `prontuarios` (Medical Records)
- `id` (uuid, primary key, default: gen_random_uuid())
- `paciente_id` (uuid, references pacientes)
- `consulta_id` (uuid, references consultas)
- `medico_id` (uuid, references medicos)
- `data_atendimento` (timestamptz, service date)
- `queixa_principal` (text, chief complaint)
- `historia_doenca` (text, history of present illness)
- `exame_fisico` (text, physical examination)
- `hipotese_diagnostica` (text, diagnostic hypothesis)
- `conduta` (text, treatment plan)
- `observacoes` (text, notes)
- `created_at` (timestamptz, default: now())
- `updated_at` (timestamptz, default: now())

### `receitas` (Prescriptions)
- `id` (uuid, primary key, default: gen_random_uuid())
- `paciente_id` (uuid, references pacientes)
- `medico_id` (uuid, references medicos)
- `prontuario_id` (uuid, references prontuarios)
- `data_emissao` (timestamptz, issue date)
- `medicamentos` (text, medications)
- `posologia` (text, dosage instructions)
- `observacoes` (text, notes)
- `created_at` (timestamptz, default: now())
- `updated_at` (timestamptz, default: now())

### `procedimentos` (Procedures)
- `id` (uuid, primary key, default: gen_random_uuid())
- `nome` (text, procedure name)
- `codigo` (text, procedure code)
- `descricao` (text, description)
- `valor` (numeric, price)
- `duracao_minutos` (integer, duration in minutes)
- `created_at` (timestamptz, default: now())
- `updated_at` (timestamptz, default: now())

### `pagamentos` (Payments)
- `id` (uuid, primary key, default: gen_random_uuid())
- `consulta_id` (uuid, references consultas)
- `paciente_id` (uuid, references pacientes)
- `data_pagamento` (timestamptz, payment date)
- `valor` (numeric, amount)
- `forma_pagamento` (text, payment method: 'Dinheiro', 'Cartão Débito', 'Cartão Crédito', 'PIX', 'Convênio')
- `status` (text, status: 'Pendente', 'Pago', 'Cancelado')
- `observacoes` (text, notes)
- `created_at` (timestamptz, default: now())
- `updated_at` (timestamptz, default: now())

## 3. Security
- No RLS enabled - internal clinic system where all staff need full access to patient data
- All tables are accessible for authenticated users to maximize operational efficiency
- Medical staff need full read/write access for daily operations

## 4. Indexes
- Create indexes on frequently queried fields for performance optimization
*/

-- Drop old tables
DROP TABLE IF EXISTS volumes CASCADE;
DROP TABLE IF EXISTS viagens CASCADE;
DROP TABLE IF EXISTS equipamentos CASCADE;
DROP TABLE IF EXISTS agendamentos CASCADE;
DROP TABLE IF EXISTS ocorrencias CASCADE;
DROP TABLE IF EXISTS documentos CASCADE;

-- Create medicos table
CREATE TABLE IF NOT EXISTS medicos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  crm text NOT NULL UNIQUE,
  especialidade text NOT NULL,
  telefone text,
  email text,
  status text NOT NULL DEFAULT 'Ativo' CHECK (status IN ('Ativo', 'Inativo')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_medicos_nome ON medicos(nome);
CREATE INDEX idx_medicos_crm ON medicos(crm);
CREATE INDEX idx_medicos_status ON medicos(status);

-- Create pacientes table
CREATE TABLE IF NOT EXISTS pacientes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  cpf text UNIQUE,
  data_nascimento date,
  sexo text CHECK (sexo IN ('Masculino', 'Feminino', 'Outro')),
  telefone text,
  email text,
  endereco text,
  convenio text,
  numero_convenio text,
  observacoes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_pacientes_nome ON pacientes(nome);
CREATE INDEX idx_pacientes_cpf ON pacientes(cpf);
CREATE INDEX idx_pacientes_telefone ON pacientes(telefone);

-- Create consultas table
CREATE TABLE IF NOT EXISTS consultas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  paciente_id uuid REFERENCES pacientes(id) ON DELETE CASCADE,
  medico_id uuid REFERENCES medicos(id) ON DELETE SET NULL,
  data_hora timestamptz NOT NULL,
  tipo text NOT NULL CHECK (tipo IN ('Consulta', 'Retorno', 'Exame', 'Procedimento')),
  status text NOT NULL DEFAULT 'Agendada' CHECK (status IN ('Agendada', 'Confirmada', 'Realizada', 'Cancelada', 'Faltou')),
  motivo text,
  observacoes text,
  valor numeric(10,2),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_consultas_paciente ON consultas(paciente_id);
CREATE INDEX idx_consultas_medico ON consultas(medico_id);
CREATE INDEX idx_consultas_data ON consultas(data_hora);
CREATE INDEX idx_consultas_status ON consultas(status);

-- Create prontuarios table
CREATE TABLE IF NOT EXISTS prontuarios (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  paciente_id uuid REFERENCES pacientes(id) ON DELETE CASCADE,
  consulta_id uuid REFERENCES consultas(id) ON DELETE SET NULL,
  medico_id uuid REFERENCES medicos(id) ON DELETE SET NULL,
  data_atendimento timestamptz NOT NULL DEFAULT now(),
  queixa_principal text,
  historia_doenca text,
  exame_fisico text,
  hipotese_diagnostica text,
  conduta text,
  observacoes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_prontuarios_paciente ON prontuarios(paciente_id);
CREATE INDEX idx_prontuarios_consulta ON prontuarios(consulta_id);
CREATE INDEX idx_prontuarios_medico ON prontuarios(medico_id);
CREATE INDEX idx_prontuarios_data ON prontuarios(data_atendimento);

-- Create receitas table
CREATE TABLE IF NOT EXISTS receitas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  paciente_id uuid REFERENCES pacientes(id) ON DELETE CASCADE,
  medico_id uuid REFERENCES medicos(id) ON DELETE SET NULL,
  prontuario_id uuid REFERENCES prontuarios(id) ON DELETE SET NULL,
  data_emissao timestamptz NOT NULL DEFAULT now(),
  medicamentos text NOT NULL,
  posologia text NOT NULL,
  observacoes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_receitas_paciente ON receitas(paciente_id);
CREATE INDEX idx_receitas_medico ON receitas(medico_id);
CREATE INDEX idx_receitas_prontuario ON receitas(prontuario_id);
CREATE INDEX idx_receitas_data ON receitas(data_emissao);

-- Create procedimentos table
CREATE TABLE IF NOT EXISTS procedimentos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  codigo text UNIQUE,
  descricao text,
  valor numeric(10,2),
  duracao_minutos integer,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_procedimentos_nome ON procedimentos(nome);
CREATE INDEX idx_procedimentos_codigo ON procedimentos(codigo);

-- Create pagamentos table
CREATE TABLE IF NOT EXISTS pagamentos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  consulta_id uuid REFERENCES consultas(id) ON DELETE SET NULL,
  paciente_id uuid REFERENCES pacientes(id) ON DELETE CASCADE,
  data_pagamento timestamptz NOT NULL DEFAULT now(),
  valor numeric(10,2) NOT NULL,
  forma_pagamento text NOT NULL CHECK (forma_pagamento IN ('Dinheiro', 'Cartão Débito', 'Cartão Crédito', 'PIX', 'Convênio')),
  status text NOT NULL DEFAULT 'Pendente' CHECK (status IN ('Pendente', 'Pago', 'Cancelado')),
  observacoes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_pagamentos_consulta ON pagamentos(consulta_id);
CREATE INDEX idx_pagamentos_paciente ON pagamentos(paciente_id);
CREATE INDEX idx_pagamentos_data ON pagamentos(data_pagamento);
CREATE INDEX idx_pagamentos_status ON pagamentos(status);

-- Apply triggers to all tables
CREATE TRIGGER update_medicos_updated_at BEFORE UPDATE ON medicos
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pacientes_updated_at BEFORE UPDATE ON pacientes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_consultas_updated_at BEFORE UPDATE ON consultas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_prontuarios_updated_at BEFORE UPDATE ON prontuarios
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_receitas_updated_at BEFORE UPDATE ON receitas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_procedimentos_updated_at BEFORE UPDATE ON procedimentos
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pagamentos_updated_at BEFORE UPDATE ON pagamentos
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();