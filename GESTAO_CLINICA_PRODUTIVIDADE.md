# Gestão Clínica e Produtividade - Documentação Completa

## 📋 Visão Geral

Este documento descreve as funcionalidades implementadas para Gestão Clínica e Produtividade no Sistema de Gestão Operacional.

---

## 🏥 GESTÃO CLÍNICA

### 1. Prescrição Digital de Medicamentos

#### Funcionalidades
- ✅ Criação de prescrições digitais
- ✅ Múltiplos medicamentos por prescrição
- ✅ Campos detalhados para cada medicamento:
  - Nome do medicamento
  - Dosagem (ex: 500mg)
  - Frequência (ex: 8 em 8 horas)
  - Duração (ex: 7 dias)
  - Observações específicas
- ✅ Observações gerais da prescrição
- ✅ Visualização completa de prescrições
- ✅ Impressão de prescrições em formato profissional
- ✅ Histórico completo de prescrições por paciente

#### Estrutura do Banco de Dados
```sql
CREATE TABLE prescricoes (
  id uuid PRIMARY KEY,
  paciente_id uuid REFERENCES pacientes,
  medico_id uuid REFERENCES medicos,
  consulta_id uuid REFERENCES consultas (nullable),
  data_prescricao date,
  medicamentos jsonb, -- Array de medicamentos
  observacoes text,
  created_at timestamptz,
  updated_at timestamptz
);
```

#### Como Usar
1. Acesse **Prescrições Médicas** no menu
2. Clique em **Nova Prescrição**
3. Selecione o paciente e o médico
4. Adicione medicamentos com o botão **Adicionar Medicamento**
5. Preencha os dados de cada medicamento
6. Adicione observações gerais (opcional)
7. Clique em **Criar Prescrição**

#### Impressão
- Clique no ícone de documento para imprimir
- Formato profissional com cabeçalho
- Tabela organizada de medicamentos
- Informações do médico e paciente

---

### 2. Upload e Visualização de Exames/Imagens

#### Funcionalidades
- ✅ Upload de arquivos de exames
- ✅ Suporte para múltiplos formatos:
  - Imagens: JPEG, PNG, GIF, BMP, TIFF
  - Documentos: PDF
- ✅ Limite de tamanho: 5MB por arquivo
- ✅ Armazenamento seguro no Supabase Storage
- ✅ Organização por paciente
- ✅ Metadados do exame:
  - Tipo de exame
  - Data do exame
  - Resultado/Notas
  - Observações
- ✅ Visualização de exames
- ✅ Download de arquivos
- ✅ Histórico completo por paciente

#### Estrutura do Banco de Dados
```sql
CREATE TABLE exames (
  id uuid PRIMARY KEY,
  paciente_id uuid REFERENCES pacientes,
  medico_id uuid REFERENCES medicos,
  consulta_id uuid REFERENCES consultas (nullable),
  tipo_exame text,
  data_exame date,
  arquivo_url text,
  arquivo_nome text,
  arquivo_tipo text,
  resultado text,
  observacoes text,
  created_at timestamptz,
  updated_at timestamptz
);
```

#### Storage Bucket
- **Nome**: `medical-files`
- **Tamanho máximo**: 5MB
- **Tipos permitidos**: image/*, application/pdf
- **Organização**: `{paciente_id}/{timestamp}.{ext}`

#### Como Usar
1. Acesse **Exames** no menu
2. Clique em **Novo Exame**
3. Selecione o paciente e o médico
4. Escolha o tipo de exame
5. Faça upload do arquivo
6. Adicione resultado e observações
7. Clique em **Salvar Exame**

---

### 3. Templates de Prontuários por Especialidade

#### Funcionalidades
- ✅ Templates pré-configurados por especialidade
- ✅ Campos dinâmicos configuráveis
- ✅ Tipos de campos suportados:
  - Texto simples
  - Área de texto
  - Seleção (dropdown)
  - Checkbox
  - Data
  - Número
- ✅ Campos obrigatórios e opcionais
- ✅ Templates ativos/inativos
- ✅ Criação de novos templates
- ✅ Edição de templates existentes

#### Templates Padrão Incluídos

**1. Consulta Clínica Geral**
- Queixa Principal *
- História da Doença Atual *
- Antecedentes Pessoais
- Antecedentes Familiares
- Exame Físico *
- Hipótese Diagnóstica *
- Conduta *

**2. Consulta Cardiológica**
- Queixa Principal *
- Dor Torácica (Sim/Não) *
- Dispneia (Sim/Não) *
- Palpitações (Sim/Não) *
- Pressão Arterial *
- Frequência Cardíaca *
- Ausculta Cardíaca *
- ECG
- Diagnóstico *
- Conduta *

**3. Consulta Pediátrica**
- Queixa Principal *
- Idade *
- Peso *
- Altura *
- Desenvolvimento *
- Vacinação *
- Exame Físico *
- Diagnóstico *
- Orientações aos Pais *

**4. Consulta Ortopédica**
- Queixa Principal *
- Localização da Dor *
- Trauma (Sim/Não) *
- Amplitude de Movimento *
- Força Muscular *
- Exame Físico *
- Raio-X
- Diagnóstico *
- Tratamento *

#### Estrutura do Banco de Dados
```sql
CREATE TABLE templates_prontuario (
  id uuid PRIMARY KEY,
  nome text,
  especialidade text,
  campos jsonb, -- Array de campos configuráveis
  ativo boolean,
  created_at timestamptz,
  updated_at timestamptz
);
```

#### Como Usar
1. Ao criar um prontuário, selecione a especialidade
2. Escolha o template desejado
3. Preencha os campos do template
4. Campos obrigatórios são marcados com *
5. Salve o prontuário

---

### 4. Histórico Médico Completo do Paciente

#### Funcionalidades
- ✅ Visualização unificada de todo histórico
- ✅ Linha do tempo cronológica
- ✅ Filtros por tipo de registro:
  - Consultas
  - Prontuários
  - Prescrições
  - Exames
  - Receitas
  - Procedimentos
  - Pagamentos
- ✅ Busca por data
- ✅ Exportação de histórico
- ✅ Acesso rápido a detalhes

#### Como Acessar
1. Vá para **Pacientes**
2. Clique em um paciente
3. Acesse a aba **Histórico Médico**
4. Use os filtros para refinar a visualização

---

## 📊 PRODUTIVIDADE

### 1. Dashboard com Indicadores

#### KPIs Principais
- **Total de Pacientes**: Contagem total de pacientes cadastrados
- **Consultas Realizadas**: Total de consultas concluídas
- **Consultas Futuras**: Agendamentos pendentes
- **Consultas Canceladas**: Total de cancelamentos
- **Receita Total**: Soma de todos os pagamentos recebidos
- **Receita do Mês**: Receita do mês atual
- **Pacientes em Espera**: Quantidade na lista de espera
- **Total de Médicos**: Profissionais cadastrados

#### Gráficos e Visualizações
- **Procedimentos Mais Realizados**: Ranking com quantidade e receita
- **Evolução de Receita**: Gráfico de linha mensal
- **Taxa de Ocupação**: Percentual de horários preenchidos
- **Status de Consultas**: Distribuição por status

#### Estrutura do Banco de Dados
```sql
CREATE VIEW dashboard_stats AS
SELECT
  (SELECT COUNT(*) FROM pacientes) as total_pacientes,
  (SELECT COUNT(*) FROM consultas WHERE status = 'realizada') as total_consultas_realizadas,
  (SELECT COUNT(*) FROM consultas WHERE status = 'agendada' AND data_hora >= CURRENT_DATE) as consultas_futuras,
  (SELECT COUNT(*) FROM consultas WHERE status = 'cancelada') as consultas_canceladas,
  (SELECT COALESCE(SUM(valor), 0) FROM pagamentos WHERE status = 'pago') as receita_total,
  (SELECT COALESCE(SUM(valor), 0) FROM pagamentos WHERE status = 'pago' AND data_pagamento >= DATE_TRUNC('month', CURRENT_DATE)) as receita_mes_atual,
  (SELECT COUNT(*) FROM lista_espera WHERE status = 'aguardando') as pacientes_em_espera,
  (SELECT COUNT(*) FROM medicos) as total_medicos;

CREATE VIEW procedimentos_ranking AS
SELECT
  p.nome,
  p.valor,
  COUNT(c.id) as total_realizados,
  COALESCE(SUM(c.valor), 0) as receita_gerada
FROM procedimentos p
LEFT JOIN consultas c ON c.tipo = p.nome AND c.status = 'realizada'
GROUP BY p.id, p.nome, p.valor
ORDER BY total_realizados DESC, receita_gerada DESC;
```

#### Como Usar
1. Acesse **Dashboard** no menu principal
2. Visualize os indicadores em tempo real
3. Analise os gráficos de tendências
4. Use os filtros de período para análises específicas

---

### 2. Agenda com Visualização por Profissional

#### Funcionalidades
- ✅ Visualização de agenda por médico
- ✅ Filtro por período (dia, semana, mês)
- ✅ Indicador de consultas confirmadas
- ✅ Status visual de cada consulta:
  - Agendada (azul)
  - Realizada (verde)
  - Cancelada (vermelho)
  - Confirmada (ícone de check)
- ✅ Informações rápidas:
  - Nome do paciente
  - Telefone
  - Tipo de consulta
  - Valor
- ✅ Busca de próximo horário disponível
- ✅ Exportação de agenda

#### Função do Banco de Dados
```sql
CREATE FUNCTION obter_agenda_profissional(
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
);
```

#### Como Usar
1. Acesse **Agenda Profissional**
2. Selecione o médico
3. Escolha o período (dia, semana, mês)
4. Visualize os agendamentos
5. Clique em uma consulta para ver detalhes
6. Use o botão "Próximo Disponível" para encontrar horários livres

---

### 3. Lista de Espera Automatizada

#### Funcionalidades
- ✅ Cadastro de pacientes na lista de espera
- ✅ Níveis de prioridade:
  - **Urgente**: Atendimento imediato
  - **Alta**: Prioridade alta
  - **Média**: Prioridade normal
  - **Baixa**: Pode aguardar
- ✅ Status do registro:
  - **Aguardando**: Na fila
  - **Contatado**: Paciente foi contatado
  - **Agendado**: Consulta marcada
  - **Cancelado**: Desistiu ou não compareceu
- ✅ Atualização automática ao agendar
- ✅ Filtros por especialidade
- ✅ Filtros por médico
- ✅ Ordenação automática por prioridade e data
- ✅ Notificações de vaga disponível

#### Estrutura do Banco de Dados
```sql
CREATE TABLE lista_espera (
  id uuid PRIMARY KEY,
  paciente_id uuid REFERENCES pacientes,
  medico_id uuid REFERENCES medicos (nullable),
  especialidade text,
  prioridade text CHECK (prioridade IN ('baixa', 'media', 'alta', 'urgente')),
  motivo text,
  data_solicitacao date,
  status text CHECK (status IN ('aguardando', 'contatado', 'agendado', 'cancelado')),
  observacoes text,
  created_at timestamptz,
  updated_at timestamptz
);
```

#### Automação
Quando uma consulta é agendada, o sistema automaticamente:
1. Busca registros na lista de espera do paciente
2. Atualiza o status para "agendado"
3. Registra a data de atualização

```sql
CREATE TRIGGER trigger_atualizar_lista_espera
  AFTER INSERT ON consultas
  FOR EACH ROW
  EXECUTE FUNCTION atualizar_lista_espera_ao_agendar();
```

#### Como Usar
1. Acesse **Lista de Espera**
2. Clique em **Adicionar à Lista**
3. Selecione o paciente
4. Escolha a especialidade e/ou médico
5. Defina a prioridade
6. Adicione o motivo
7. Salve o registro

**Gerenciamento:**
- Filtre por status "Aguardando" para ver quem está na fila
- Ordene por prioridade para atender casos urgentes
- Atualize o status para "Contatado" após ligar para o paciente
- O sistema atualiza automaticamente para "Agendado" ao marcar consulta

---

### 4. Confirmação Automática de Consultas

#### Funcionalidades
- ✅ Registro de confirmações
- ✅ Múltiplos métodos de confirmação:
  - WhatsApp
  - E-mail
  - Telefone
  - Sistema (confirmação online)
- ✅ Histórico de confirmações
- ✅ Indicador visual na agenda
- ✅ Integração com sistema de lembretes
- ✅ Relatório de taxa de confirmação

#### Estrutura do Banco de Dados
```sql
CREATE TABLE confirmacoes_consulta (
  id uuid PRIMARY KEY,
  consulta_id uuid REFERENCES consultas,
  data_confirmacao timestamptz,
  metodo text CHECK (metodo IN ('whatsapp', 'email', 'telefone', 'sistema')),
  confirmado_por text,
  observacoes text,
  created_at timestamptz
);
```

#### Fluxo de Confirmação

**Manual:**
1. Acesse a agenda do profissional
2. Clique em uma consulta não confirmada
3. Clique em **Confirmar Consulta**
4. Selecione o método de confirmação
5. Adicione observações (opcional)
6. Salve a confirmação

**Automática (via Lembretes):**
1. Sistema envia lembrete automático
2. Paciente responde confirmando
3. Sistema registra a confirmação automaticamente
4. Atualiza o status na agenda

#### Integração com Lembretes
- Lembretes enviados 24h antes da consulta
- Paciente pode confirmar via link no WhatsApp/E-mail
- Confirmação é registrada automaticamente
- Médico visualiza status atualizado na agenda

---

## 🔧 API e Integrações

### APIs Disponíveis

#### Prescrições
```typescript
prescricoesApi.getAll()
prescricoesApi.getByPaciente(pacienteId)
prescricoesApi.getById(id)
prescricoesApi.create(prescricao)
prescricoesApi.update(id, prescricao)
prescricoesApi.delete(id)
```

#### Exames
```typescript
examesApi.getAll()
examesApi.getByPaciente(pacienteId)
examesApi.getById(id)
examesApi.create(exame)
examesApi.update(id, exame)
examesApi.delete(id)
examesApi.uploadFile(file, pacienteId)
examesApi.deleteFile(fileUrl)
```

#### Templates
```typescript
templatesProntuarioApi.getAll()
templatesProntuarioApi.getAtivos()
templatesProntuarioApi.getByEspecialidade(especialidade)
templatesProntuarioApi.getById(id)
templatesProntuarioApi.create(template)
templatesProntuarioApi.update(id, template)
templatesProntuarioApi.delete(id)
```

#### Lista de Espera
```typescript
listaEsperaApi.getAll()
listaEsperaApi.getAguardando()
listaEsperaApi.getByPaciente(pacienteId)
listaEsperaApi.getById(id)
listaEsperaApi.create(listaEspera)
listaEsperaApi.update(id, listaEspera)
listaEsperaApi.delete(id)
```

#### Confirmações
```typescript
confirmacoesConsultaApi.getByConsulta(consultaId)
confirmacoesConsultaApi.create(confirmacao)
confirmacoesConsultaApi.isConfirmed(consultaId)
```

#### Dashboard
```typescript
dashboardApi.getStats()
dashboardApi.getProcedimentosRanking()
```

#### Agenda Profissional
```typescript
agendaProfissionalApi.getAgenda(medicoId, dataInicio, dataFim)
```

---

## 🔒 Segurança e Permissões

### Row Level Security (RLS)

**Prescrições:**
- Administradores: Acesso total
- Médicos: Visualizar todas, criar/editar próprias
- Pacientes: Visualizar próprias (somente leitura)

**Exames:**
- Administradores: Acesso total
- Médicos: Visualizar todos, criar/editar próprios
- Pacientes: Visualizar próprios (somente leitura)

**Templates:**
- Administradores: Acesso total
- Médicos: Visualizar templates ativos

**Lista de Espera:**
- Administradores: Acesso total
- Médicos: Visualizar todos
- Recepcionistas: Criar e atualizar

**Confirmações:**
- Administradores: Acesso total
- Usuários autenticados: Visualizar e criar

### Storage Security

**Bucket medical-files:**
- Upload: Apenas usuários autenticados
- Visualização: Apenas usuários autenticados
- Exclusão: Administradores e médicos (próprios arquivos)
- Tamanho máximo: 5MB
- Tipos permitidos: Imagens e PDF

---

## 📈 Métricas e Relatórios

### Indicadores Disponíveis

1. **Taxa de Ocupação**
   - Horários preenchidos vs disponíveis
   - Por médico e período

2. **Taxa de Confirmação**
   - Consultas confirmadas vs agendadas
   - Por método de confirmação

3. **Tempo Médio de Espera**
   - Tempo entre solicitação e agendamento
   - Por especialidade e prioridade

4. **Procedimentos Mais Realizados**
   - Ranking por quantidade
   - Receita gerada por procedimento

5. **Receita por Período**
   - Diária, semanal, mensal, anual
   - Comparação com períodos anteriores

6. **Taxa de Cancelamento**
   - Percentual de consultas canceladas
   - Motivos de cancelamento

---

## 🎯 Benefícios

### Gestão Clínica
- ✅ Prescrições digitais profissionais
- ✅ Armazenamento seguro de exames
- ✅ Padronização de prontuários
- ✅ Histórico completo e organizado
- ✅ Redução de erros médicos
- ✅ Conformidade com regulamentações

### Produtividade
- ✅ Visão clara de indicadores
- ✅ Otimização de agenda
- ✅ Redução de faltas
- ✅ Gestão eficiente de espera
- ✅ Aumento de receita
- ✅ Melhor experiência do paciente

---

## 🚀 Próximos Passos Sugeridos

### Curto Prazo
1. Implementar assinatura digital em prescrições
2. Adicionar visualizador de imagens médicas (DICOM)
3. Criar relatórios personalizáveis
4. Implementar notificações push

### Médio Prazo
1. Integração com laboratórios
2. Telemedicina integrada
3. Prontuário eletrônico completo (PEP)
4. BI e analytics avançados

### Longo Prazo
1. Inteligência artificial para diagnóstico
2. Integração com wearables
3. Plataforma de segunda opinião
4. Marketplace de serviços médicos

---

## 📞 Suporte

Para dúvidas ou sugestões sobre as funcionalidades de Gestão Clínica e Produtividade, consulte:
- Documentação técnica: `NOVAS_FUNCIONALIDADES.md`
- Guia de permissões: `PERMISSOES_GRANULARES.md`
- Changelog: `HISTORICO_ALTERACOES.md`

---

**Status**: ✅ Todas as funcionalidades implementadas e testadas
**Versão**: 2.0
**Data**: 22/11/2025
