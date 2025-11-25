# TODO - Melhorias nos Módulos Existentes

## 1. Dashboard de Produtividade ✅
- [x] Criar página dedicada de Dashboard de Produtividade
  - [x] Métricas de produtividade por médico
  - [x] Taxa de ocupação da agenda
  - [x] Tempo médio de atendimento
  - [x] Número de atendimentos por período
  - [x] Receita gerada por profissional
  - [x] Gráficos de tendência de produtividade
  - [x] Comparativo mensal/anual
  - [x] Ranking de produtividade

## 2. Relatórios Personalizados ✅
- [x] Expandir página de Relatórios
  - [x] Relatório de Pacientes
    - [x] Novos pacientes por período
    - [x] Pacientes ativos vs inativos
    - [x] Distribuição por faixa etária
    - [x] Distribuição geográfica
  - [x] Relatório Financeiro Detalhado
    - [x] Receita por tipo de procedimento
    - [x] Análise de inadimplência
    - [x] Previsão de receita
    - [x] Fluxo de caixa
  - [x] Relatório de Comissões
    - [x] Comissões por profissional
    - [x] Comissões por período
    - [x] Análise de performance
  - [x] Relatório de Ausências
    - [x] Histórico de férias
    - [x] Taxa de absenteísmo
    - [x] Impacto na agenda
  - [x] Exportação de Relatórios
    - [x] Exportar para CSV (Excel compatível)
    - [x] Filtros por período
    - [x] Relatórios separados por categoria

## 3. Gestão Clínica Expandida ⏳
- [ ] Melhorar Prontuários
  - [ ] Templates de prontuário por especialidade
  - [ ] Histórico completo do paciente
  - [ ] Anexar arquivos (exames, imagens)
  - [ ] Assinatura digital
  - [ ] Busca avançada em prontuários
- [ ] Melhorar Receitas
  - [ ] Banco de medicamentos
  - [ ] Posologia padrão
  - [ ] Interações medicamentosas
  - [ ] Histórico de prescrições do paciente
  - [ ] Impressão em formato padrão
- [ ] Adicionar Exames
  - [ ] Cadastro de exames solicitados
  - [ ] Acompanhamento de resultados
  - [ ] Integração com laboratórios
  - [ ] Alertas de exames pendentes
- [ ] Adicionar Atestados
  - [ ] Geração de atestados médicos
  - [ ] Templates personalizáveis
  - [ ] Controle de numeração
  - [ ] Histórico de atestados emitidos

## 4. Integração com WhatsApp ⏳
- [ ] Configurar integração WhatsApp Business API
  - [ ] Configurar credenciais da API
  - [ ] Criar templates de mensagens
  - [ ] Sistema de envio de mensagens
- [ ] Notificações Automáticas
  - [ ] Confirmação de agendamento
  - [ ] Lembrete de consulta (24h antes)
  - [ ] Lembrete de consulta (1h antes)
  - [ ] Confirmação de cancelamento
  - [ ] Aviso de reagendamento
- [ ] Mensagens Personalizadas
  - [ ] Envio manual de mensagens
  - [ ] Histórico de mensagens enviadas
  - [ ] Status de entrega
  - [ ] Respostas dos pacientes
- [ ] Campanhas
  - [ ] Envio em massa para grupos
  - [ ] Campanhas de retorno
  - [ ] Lembretes de check-up
  - [ ] Avisos importantes

## Prioridades

### Alta Prioridade (Fazer Primeiro)
1. Dashboard de Produtividade
2. Relatórios Financeiros Detalhados
3. Melhorias em Prontuários

### Média Prioridade
1. Relatórios de Comissões
2. Sistema de Exames
3. Notificações WhatsApp Básicas

### Baixa Prioridade
1. Campanhas WhatsApp
2. Relatórios Avançados
3. Integrações com Laboratórios

## Notas de Implementação

### Dashboard de Produtividade
- Usar gráficos do recharts
- Calcular métricas em tempo real
- Cache de dados para performance
- Filtros por período e profissional

### Relatórios
- Usar biblioteca xlsx para Excel
- Usar jsPDF para PDF
- Implementar paginação para grandes volumes
- Adicionar filtros avançados

### WhatsApp
- Usar API oficial do WhatsApp Business
- Armazenar templates no banco
- Log de todas as mensagens enviadas
- Respeitar limites de taxa da API

### Gestão Clínica
- Manter histórico completo
- Implementar versionamento de documentos
- Backup automático de arquivos
- Criptografia de dados sensíveis

## Status Atual
- ✅ Backend de Gestão de Equipe implementado
- ✅ Frontend de Gestão de Equipe implementado
- ⏳ Melhorias nos módulos existentes (em planejamento)

## Próximos Passos
1. Criar Dashboard de Produtividade
2. Expandir Relatórios
3. Melhorar Gestão Clínica
4. Implementar WhatsApp
