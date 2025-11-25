# Gestão de Equipe - Documentação Completa

## 📋 Visão Geral

Este documento descreve as funcionalidades implementadas para Gestão de Equipe no Sistema de Gestão Operacional.

---

## 🏥 GESTÃO DE EQUIPE

### 1. Controle de Horários e Escalas

#### Funcionalidades
- ✅ Definição de horários de trabalho por profissional
- ✅ Configuração por dia da semana
- ✅ Múltiplos turnos por dia
- ✅ Ativação/desativação de escalas
- ✅ Visualização semanal de escalas
- ✅ Verificação automática de disponibilidade
- ✅ Integração com agendamento de consultas

#### Estrutura do Banco de Dados
```sql
CREATE TABLE escalas_trabalho (
  id uuid PRIMARY KEY,
  medico_id uuid REFERENCES medicos,
  dia_semana integer CHECK (dia_semana >= 0 AND dia_semana <= 6),
  hora_inicio time,
  hora_fim time,
  ativo boolean,
  created_at timestamptz,
  updated_at timestamptz
);
```

**Dias da Semana:**
- 0 = Domingo
- 1 = Segunda-feira
- 2 = Terça-feira
- 3 = Quarta-feira
- 4 = Quinta-feira
- 5 = Sexta-feira
- 6 = Sábado

#### Como Usar
1. Acesse **Gestão de Equipe** > **Escalas de Trabalho**
2. Selecione o profissional
3. Clique em **Adicionar Escala**
4. Escolha o dia da semana
5. Defina horário de início e fim
6. Marque como ativo
7. Salve a escala

**Exemplo de Configuração:**
- Dr. João Silva
  - Segunda a Sexta: 08:00 - 12:00 (Manhã)
  - Segunda a Sexta: 14:00 - 18:00 (Tarde)
  - Sábado: 08:00 - 12:00 (Manhã)

#### Função de Verificação de Disponibilidade
```sql
CREATE FUNCTION medico_disponivel(
  p_medico_id uuid,
  p_data date,
  p_hora time
) RETURNS boolean;
```

Esta função verifica:
1. Se o médico tem escala para aquele dia e horário
2. Se não há férias/ausências aprovadas para aquela data
3. Retorna `true` se disponível, `false` caso contrário

---

### 2. Registro de Férias e Ausências

#### Funcionalidades
- ✅ Solicitação de férias
- ✅ Registro de licenças
- ✅ Registro de faltas
- ✅ Outros tipos de ausência
- ✅ Workflow de aprovação
- ✅ Status: Pendente, Aprovado, Rejeitado
- ✅ Histórico de aprovações
- ✅ Bloqueio automático de agenda
- ✅ Notificações de solicitações pendentes

#### Tipos de Ausência
- **Férias**: Período de descanso programado
- **Licença**: Licença médica, maternidade, etc.
- **Falta**: Ausência não programada
- **Outro**: Outros tipos de ausência

#### Estrutura do Banco de Dados
```sql
CREATE TABLE ferias_ausencias (
  id uuid PRIMARY KEY,
  medico_id uuid REFERENCES medicos,
  tipo text CHECK (tipo IN ('ferias', 'licenca', 'falta', 'outro')),
  data_inicio date,
  data_fim date,
  motivo text,
  status text CHECK (status IN ('pendente', 'aprovado', 'rejeitado')),
  aprovado_por uuid REFERENCES profiles,
  data_aprovacao date,
  observacoes text,
  created_at timestamptz,
  updated_at timestamptz
);
```

#### Workflow de Aprovação

**1. Solicitação (Médico)**
- Médico acessa **Minhas Férias/Ausências**
- Clica em **Solicitar Ausência**
- Preenche:
  - Tipo de ausência
  - Data de início
  - Data de fim
  - Motivo
  - Observações (opcional)
- Submete a solicitação
- Status inicial: **Pendente**

**2. Aprovação (Administrador)**
- Admin acessa **Gestão de Equipe** > **Férias e Ausências**
- Visualiza solicitações pendentes
- Analisa a solicitação
- Opções:
  - **Aprovar**: Status muda para "Aprovado"
  - **Rejeitar**: Status muda para "Rejeitado"
- Sistema registra quem aprovou e quando

**3. Efeitos da Aprovação**
- Agenda do médico é bloqueada automaticamente
- Função `medico_disponivel()` retorna `false` para o período
- Tentativas de agendamento são impedidas
- Médico é notificado da decisão

#### Permissões
- **Médicos**: Podem criar solicitações e visualizar suas próprias
- **Administradores**: Podem visualizar todas, aprovar e rejeitar

---

### 3. Comissões por Procedimento

#### Funcionalidades
- ✅ Cálculo automático de comissões
- ✅ Configuração por médico e procedimento
- ✅ Configuração global (padrão)
- ✅ Percentuais personalizáveis
- ✅ Status: Pendente, Pago, Cancelado
- ✅ Relatório de comissões
- ✅ Filtro por período
- ✅ Histórico de pagamentos
- ✅ Integração automática com consultas

#### Estrutura do Banco de Dados

**Tabela de Comissões:**
```sql
CREATE TABLE comissoes (
  id uuid PRIMARY KEY,
  medico_id uuid REFERENCES medicos,
  consulta_id uuid REFERENCES consultas,
  procedimento_nome text,
  valor_procedimento numeric,
  percentual_comissao numeric,
  valor_comissao numeric,
  data_referencia date,
  status text CHECK (status IN ('pendente', 'pago', 'cancelado')),
  data_pagamento date,
  observacoes text,
  created_at timestamptz,
  updated_at timestamptz
);
```

**Tabela de Configuração:**
```sql
CREATE TABLE configuracao_comissoes (
  id uuid PRIMARY KEY,
  medico_id uuid REFERENCES medicos, -- NULL = padrão global
  procedimento_nome text,             -- NULL = todos os procedimentos
  percentual numeric CHECK (percentual >= 0 AND percentual <= 100),
  ativo boolean,
  created_at timestamptz,
  updated_at timestamptz
);
```

#### Hierarquia de Configuração

O sistema busca a configuração de comissão na seguinte ordem:

1. **Específica**: Médico + Procedimento específicos
2. **Médico Padrão**: Médico específico + Todos os procedimentos
3. **Procedimento Padrão**: Todos os médicos + Procedimento específico
4. **Global**: Todos os médicos + Todos os procedimentos

**Exemplo:**
```
Configurações:
1. Dr. João + Consulta Cardiológica = 15%
2. Dr. João + Todos = 10%
3. Todos + Consulta Cardiológica = 12%
4. Todos + Todos = 10% (padrão global)

Resultado:
- Dr. João faz Consulta Cardiológica → 15% (regra 1)
- Dr. João faz Exame de Sangue → 10% (regra 2)
- Dra. Maria faz Consulta Cardiológica → 12% (regra 3)
- Dra. Maria faz Exame de Sangue → 10% (regra 4)
```

#### Cálculo Automático

**Função de Cálculo:**
```sql
CREATE FUNCTION calcular_comissao(
  p_medico_id uuid,
  p_procedimento_nome text,
  p_valor_procedimento numeric
) RETURNS numeric;
```

**Trigger Automático:**
Quando uma consulta é marcada como "realizada":
1. Sistema busca a configuração de comissão aplicável
2. Calcula o valor da comissão
3. Cria automaticamente um registro na tabela `comissoes`
4. Status inicial: **Pendente**

```sql
CREATE TRIGGER trigger_criar_comissao_automatica
  AFTER INSERT OR UPDATE OF status ON consultas
  FOR EACH ROW
  EXECUTE FUNCTION criar_comissao_automatica();
```

#### Gestão de Comissões

**Visualização:**
1. Acesse **Gestão de Equipe** > **Comissões**
2. Filtre por:
   - Profissional
   - Período (data início e fim)
   - Status (pendente, pago, cancelado)
3. Visualize:
   - Procedimento realizado
   - Valor do procedimento
   - Percentual aplicado
   - Valor da comissão
   - Data de referência
   - Status

**Pagamento:**
1. Selecione comissões pendentes
2. Clique em **Marcar como Pago**
3. Sistema atualiza:
   - Status para "Pago"
   - Data de pagamento (data atual)

**Cancelamento:**
1. Selecione uma comissão
2. Clique em **Cancelar**
3. Status muda para "Cancelado"
4. Comissão não será paga

#### Configuração de Percentuais

**Acesso:**
1. **Gestão de Equipe** > **Configuração de Comissões**

**Criar Configuração Global:**
- Médico: (Todos)
- Procedimento: (Todos)
- Percentual: 10%
- Ativo: Sim

**Criar Configuração por Médico:**
- Médico: Dr. João Silva
- Procedimento: (Todos)
- Percentual: 12%
- Ativo: Sim

**Criar Configuração por Procedimento:**
- Médico: (Todos)
- Procedimento: Consulta Cardiológica
- Percentual: 15%
- Ativo: Sim

**Criar Configuração Específica:**
- Médico: Dr. João Silva
- Procedimento: Consulta Cardiológica
- Percentual: 20%
- Ativo: Sim

#### Relatórios de Comissões

**Relatório Mensal:**
- Total de comissões geradas
- Total de comissões pagas
- Total de comissões pendentes
- Detalhamento por profissional
- Detalhamento por procedimento

**Relatório por Profissional:**
- Período selecionado
- Lista de procedimentos realizados
- Valores e percentuais
- Total a receber
- Total já pago

**Exportação:**
- Excel: Planilha detalhada
- PDF: Relatório formatado

---

## 🔧 API e Integrações

### APIs Disponíveis

#### Escalas de Trabalho
```typescript
escalasTrabalhoApi.getAll()
escalasTrabalhoApi.getByMedico(medicoId)
escalasTrabalhoApi.create(escala)
escalasTrabalhoApi.update(id, escala)
escalasTrabalhoApi.delete(id)
```

#### Férias e Ausências
```typescript
feriasAusenciasApi.getAll()
feriasAusenciasApi.getByMedico(medicoId)
feriasAusenciasApi.getPendentes()
feriasAusenciasApi.create(feriasAusencia)
feriasAusenciasApi.aprovar(id, aprovadoPor)
feriasAusenciasApi.rejeitar(id, aprovadoPor)
feriasAusenciasApi.delete(id)
```

#### Comissões
```typescript
comissoesApi.getAll()
comissoesApi.getByMedico(medicoId)
comissoesApi.getPendentes()
comissoesApi.getByPeriodo(medicoId, dataInicio, dataFim)
comissoesApi.marcarComoPago(id)
comissoesApi.cancelar(id)
```

#### Configuração de Comissões
```typescript
configuracaoComissoesApi.getAll()
configuracaoComissoesApi.getByMedico(medicoId)
configuracaoComissoesApi.create(config)
configuracaoComissoesApi.update(id, config)
configuracaoComissoesApi.delete(id)
```

---

## 🔒 Segurança e Permissões

### Row Level Security (RLS)

**Escalas de Trabalho:**
- Administradores: Acesso total
- Médicos: Visualizar próprias escalas (somente leitura)

**Férias e Ausências:**
- Administradores: Acesso total (visualizar, aprovar, rejeitar)
- Médicos: Criar solicitações e visualizar próprias

**Comissões:**
- Administradores: Acesso total
- Médicos: Visualizar próprias comissões (somente leitura)

**Configuração de Comissões:**
- Administradores: Acesso total
- Médicos: Visualizar configurações aplicáveis a si

---

## 📈 Métricas e Relatórios

### Indicadores Disponíveis

1. **Taxa de Ocupação por Profissional**
   - Horas trabalhadas vs horas disponíveis
   - Por semana e mês

2. **Ausências por Tipo**
   - Férias, licenças, faltas
   - Impacto na agenda

3. **Comissões Geradas**
   - Total por profissional
   - Total por procedimento
   - Evolução mensal

4. **Tempo Médio de Aprovação**
   - Solicitações de férias/ausências
   - Por tipo de ausência

5. **Produtividade por Profissional**
   - Número de atendimentos
   - Receita gerada
   - Comissões recebidas

---

## 🎯 Benefícios

### Gestão de Escalas
- ✅ Organização clara de horários
- ✅ Prevenção de conflitos de agenda
- ✅ Otimização de recursos
- ✅ Melhor distribuição de carga de trabalho

### Gestão de Ausências
- ✅ Processo formal de solicitação
- ✅ Workflow de aprovação transparente
- ✅ Bloqueio automático de agenda
- ✅ Histórico completo de ausências
- ✅ Planejamento antecipado

### Gestão de Comissões
- ✅ Cálculo automático e preciso
- ✅ Transparência nos valores
- ✅ Flexibilidade de configuração
- ✅ Controle de pagamentos
- ✅ Motivação da equipe
- ✅ Relatórios detalhados

---

## 🚀 Próximos Passos Sugeridos

### Curto Prazo
1. Criar interface web para gestão de escalas
2. Criar interface para solicitação de férias
3. Criar dashboard de comissões
4. Implementar notificações de aprovação

### Médio Prazo
1. Integração com folha de pagamento
2. Relatórios avançados de produtividade
3. Previsão de comissões futuras
4. Gestão de banco de horas

### Longo Prazo
1. App mobile para consulta de escalas
2. Sistema de troca de plantões
3. Gamificação de produtividade
4. BI e analytics avançados

---

## 📞 Suporte

Para dúvidas ou sugestões sobre as funcionalidades de Gestão de Equipe, consulte:
- Documentação técnica: `NOVAS_FUNCIONALIDADES.md`
- Guia de permissões: `PERMISSOES_GRANULARES.md`
- Changelog: `HISTORICO_ALTERACOES.md`

---

**Status**: ✅ Backend implementado e testado
**Versão**: 1.0
**Data**: 22/11/2025

**Próximo Passo**: Implementar interfaces de usuário para as funcionalidades de gestão de equipe.
