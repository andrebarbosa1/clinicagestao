/*
# Create Operational Management System Schema

## 1. New Tables

### `documentos` (Documents)
- `id` (uuid, primary key, default: gen_random_uuid())
- `numero` (text, document number)
- `tipo` (text, document type: 'CT-e', 'MDF-e', 'Coleta', 'Pedido')
- `status` (text, status: 'Pendente', 'Processado', 'Cancelado')
- `data_emissao` (timestamptz, issue date)
- `remetente` (text, sender)
- `destinatario` (text, recipient)
- `valor` (numeric, value)
- `observacoes` (text, notes)
- `created_at` (timestamptz, default: now())
- `updated_at` (timestamptz, default: now())

### `ocorrencias` (Occurrences)
- `id` (uuid, primary key, default: gen_random_uuid())
- `tipo` (text, occurrence type)
- `descricao` (text, description)
- `data_ocorrencia` (timestamptz, occurrence date)
- `status` (text, status: 'Aberta', 'Em Andamento', 'Resolvida', 'Fechada')
- `prioridade` (text, priority: 'Baixa', 'Média', 'Alta', 'Urgente')
- `responsavel` (text, responsible person)
- `created_at` (timestamptz, default: now())
- `updated_at` (timestamptz, default: now())

### `agendamentos` (Schedules)
- `id` (uuid, primary key, default: gen_random_uuid())
- `titulo` (text, title)
- `descricao` (text, description)
- `data_agendamento` (timestamptz, scheduled date)
- `tipo` (text, type: 'Coleta', 'Entrega', 'Manutenção', 'Reunião')
- `status` (text, status: 'Agendado', 'Confirmado', 'Realizado', 'Cancelado')
- `local` (text, location)
- `responsavel` (text, responsible person)
- `created_at` (timestamptz, default: now())
- `updated_at` (timestamptz, default: now())

### `viagens` (Trips)
- `id` (uuid, primary key, default: gen_random_uuid())
- `numero_viagem` (text, trip number)
- `veiculo` (text, vehicle)
- `motorista` (text, driver)
- `origem` (text, origin)
- `destino` (text, destination)
- `data_saida` (timestamptz, departure date)
- `data_chegada_prevista` (timestamptz, expected arrival)
- `data_chegada_real` (timestamptz, actual arrival)
- `status` (text, status: 'Planejada', 'Em Trânsito', 'Concluída', 'Cancelada')
- `km_inicial` (numeric, initial km)
- `km_final` (numeric, final km)
- `observacoes` (text, notes)
- `created_at` (timestamptz, default: now())
- `updated_at` (timestamptz, default: now())

### `equipamentos` (Equipment)
- `id` (uuid, primary key, default: gen_random_uuid())
- `codigo` (text, equipment code)
- `tipo` (text, equipment type)
- `descricao` (text, description)
- `status` (text, status: 'Disponível', 'Em Uso', 'Manutenção', 'Inativo')
- `localizacao` (text, location)
- `data_aquisicao` (date, acquisition date)
- `valor` (numeric, value)
- `created_at` (timestamptz, default: now())
- `updated_at` (timestamptz, default: now())

### `volumes` (Volumes)
- `id` (uuid, primary key, default: gen_random_uuid())
- `codigo` (text, volume code)
- `descricao` (text, description)
- `peso` (numeric, weight in kg)
- `dimensoes` (text, dimensions)
- `status` (text, status: 'Aguardando', 'Em Trânsito', 'Entregue', 'Devolvido')
- `documento_id` (uuid, references documentos)
- `viagem_id` (uuid, references viagens)
- `created_at` (timestamptz, default: now())
- `updated_at` (timestamptz, default: now())

## 2. Security
- No RLS enabled - this is an internal operational system where all authenticated users need full access to operational data
- All tables are public for authenticated users to maximize operational efficiency
- Administrators and operators need full read/write access to manage daily operations

## 3. Indexes
- Create indexes on frequently queried fields for performance optimization
*/

-- Create documentos table
CREATE TABLE IF NOT EXISTS documentos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  numero text NOT NULL,
  tipo text NOT NULL CHECK (tipo IN ('CT-e', 'MDF-e', 'Coleta', 'Pedido')),
  status text NOT NULL DEFAULT 'Pendente' CHECK (status IN ('Pendente', 'Processado', 'Cancelado')),
  data_emissao timestamptz NOT NULL DEFAULT now(),
  remetente text,
  destinatario text,
  valor numeric(10,2),
  observacoes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_documentos_numero ON documentos(numero);
CREATE INDEX idx_documentos_tipo ON documentos(tipo);
CREATE INDEX idx_documentos_status ON documentos(status);
CREATE INDEX idx_documentos_data_emissao ON documentos(data_emissao);

-- Create ocorrencias table
CREATE TABLE IF NOT EXISTS ocorrencias (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo text NOT NULL,
  descricao text NOT NULL,
  data_ocorrencia timestamptz NOT NULL DEFAULT now(),
  status text NOT NULL DEFAULT 'Aberta' CHECK (status IN ('Aberta', 'Em Andamento', 'Resolvida', 'Fechada')),
  prioridade text NOT NULL DEFAULT 'Média' CHECK (prioridade IN ('Baixa', 'Média', 'Alta', 'Urgente')),
  responsavel text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_ocorrencias_status ON ocorrencias(status);
CREATE INDEX idx_ocorrencias_prioridade ON ocorrencias(prioridade);
CREATE INDEX idx_ocorrencias_data ON ocorrencias(data_ocorrencia);

-- Create agendamentos table
CREATE TABLE IF NOT EXISTS agendamentos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  titulo text NOT NULL,
  descricao text,
  data_agendamento timestamptz NOT NULL,
  tipo text NOT NULL CHECK (tipo IN ('Coleta', 'Entrega', 'Manutenção', 'Reunião')),
  status text NOT NULL DEFAULT 'Agendado' CHECK (status IN ('Agendado', 'Confirmado', 'Realizado', 'Cancelado')),
  local text,
  responsavel text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_agendamentos_data ON agendamentos(data_agendamento);
CREATE INDEX idx_agendamentos_status ON agendamentos(status);
CREATE INDEX idx_agendamentos_tipo ON agendamentos(tipo);

-- Create viagens table
CREATE TABLE IF NOT EXISTS viagens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  numero_viagem text NOT NULL UNIQUE,
  veiculo text NOT NULL,
  motorista text NOT NULL,
  origem text NOT NULL,
  destino text NOT NULL,
  data_saida timestamptz NOT NULL,
  data_chegada_prevista timestamptz NOT NULL,
  data_chegada_real timestamptz,
  status text NOT NULL DEFAULT 'Planejada' CHECK (status IN ('Planejada', 'Em Trânsito', 'Concluída', 'Cancelada')),
  km_inicial numeric(10,2),
  km_final numeric(10,2),
  observacoes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_viagens_numero ON viagens(numero_viagem);
CREATE INDEX idx_viagens_status ON viagens(status);
CREATE INDEX idx_viagens_data_saida ON viagens(data_saida);

-- Create equipamentos table
CREATE TABLE IF NOT EXISTS equipamentos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo text NOT NULL UNIQUE,
  tipo text NOT NULL,
  descricao text,
  status text NOT NULL DEFAULT 'Disponível' CHECK (status IN ('Disponível', 'Em Uso', 'Manutenção', 'Inativo')),
  localizacao text,
  data_aquisicao date,
  valor numeric(10,2),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_equipamentos_codigo ON equipamentos(codigo);
CREATE INDEX idx_equipamentos_status ON equipamentos(status);
CREATE INDEX idx_equipamentos_tipo ON equipamentos(tipo);

-- Create volumes table
CREATE TABLE IF NOT EXISTS volumes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo text NOT NULL,
  descricao text,
  peso numeric(10,2),
  dimensoes text,
  status text NOT NULL DEFAULT 'Aguardando' CHECK (status IN ('Aguardando', 'Em Trânsito', 'Entregue', 'Devolvido')),
  documento_id uuid REFERENCES documentos(id) ON DELETE SET NULL,
  viagem_id uuid REFERENCES viagens(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_volumes_codigo ON volumes(codigo);
CREATE INDEX idx_volumes_status ON volumes(status);
CREATE INDEX idx_volumes_documento ON volumes(documento_id);
CREATE INDEX idx_volumes_viagem ON volumes(viagem_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to all tables
CREATE TRIGGER update_documentos_updated_at BEFORE UPDATE ON documentos
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ocorrencias_updated_at BEFORE UPDATE ON ocorrencias
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agendamentos_updated_at BEFORE UPDATE ON agendamentos
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_viagens_updated_at BEFORE UPDATE ON viagens
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_equipamentos_updated_at BEFORE UPDATE ON equipamentos
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_volumes_updated_at BEFORE UPDATE ON volumes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();