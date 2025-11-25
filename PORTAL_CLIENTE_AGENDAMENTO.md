# 🌐 Portal do Cliente - Agendamento Online

## 📋 Visão Geral

Sistema de agendamento online que permite aos clientes agendar consultas diretamente através de um portal web. Os agendamentos aparecem automaticamente no sistema administrativo.

---

## ✨ Funcionalidades

### Para o Cliente:

1. **Formulário de Agendamento Simplificado**
   - Nome completo
   - Telefone/WhatsApp
   - Email (opcional)
   - Seleção de médico
   - Data e horário desejados
   - Tipo de atendimento
   - Motivo da consulta (opcional)

2. **Seleção de Médico**
   - Lista completa de médicos disponíveis
   - Exibição de especialidade
   - Interface intuitiva

3. **Confirmação Visual**
   - Tela de sucesso com todos os detalhes
   - Resumo do agendamento
   - Instruções importantes
   - Opção de fazer novo agendamento

### Para o Sistema:

1. **Integração Automática**
   - Agendamentos aparecem instantaneamente em "Consultas"
   - Status: "Agendada"
   - Médico já associado
   - Dados do cliente nas observações

2. **Informações Completas**
   - Nome do cliente
   - Telefone para contato
   - Email (se fornecido)
   - Motivo da consulta
   - Data e hora selecionadas

3. **Lembretes Automáticos**
   - Lembrete via WhatsApp ativado
   - Lembrete via email (se fornecido)

---

## 🔗 Como Acessar

### URL do Portal:
```
https://seu-dominio.com/portal-cliente
```

### Compartilhamento:
- Link direto para clientes
- QR Code para divulgação
- Redes sociais
- WhatsApp Business
- Site institucional

---

## 📱 Interface do Cliente

### Passo 1: Formulário de Dados

```
┌─────────────────────────────────────────┐
│     Agendar Consulta                    │
├─────────────────────────────────────────┤
│                                         │
│  Seus Dados                             │
│  ├─ Nome Completo *                     │
│  ├─ Telefone/WhatsApp *                 │
│  └─ Email (opcional)                    │
│                                         │
│  Dados da Consulta                      │
│  ├─ Médico *                            │
│  ├─ Data *                              │
│  ├─ Horário *                           │
│  ├─ Tipo de Atendimento *               │
│  └─ Motivo (opcional)                   │
│                                         │
│  [Cancelar]  [Confirmar Agendamento]   │
└─────────────────────────────────────────┘
```

### Passo 2: Confirmação

```
┌─────────────────────────────────────────┐
│     ✓ Agendamento Confirmado!           │
├─────────────────────────────────────────┤
│                                         │
│  Paciente: João Silva                   │
│  Médico: Dr(a). Maria Santos            │
│  Data: 25/11/2025                       │
│  Horário: 14:00                         │
│  Telefone: (11) 98765-4321              │
│                                         │
│  ⚠️ Importante:                         │
│  • Chegue com 15 min de antecedência    │
│  • Traga documentos e exames            │
│  • Avise em caso de cancelamento        │
│  • Você receberá confirmação via WhatsApp│
│                                         │
│  [Novo Agendamento]  [Fechar]           │
└─────────────────────────────────────────┘
```

---

## 💻 Como Aparece no Sistema

### Na Página de Consultas:

```
┌─────────────────────────────────────────────────────────────┐
│  Consultas                                                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Data/Hora          Paciente         Médico        Status  │
│  ─────────────────────────────────────────────────────────  │
│  25/11/2025 14:00   [Novo Cliente]   Dr. Maria    Agendada │
│                                                             │
│  Observações:                                               │
│  Cliente: João Silva                                        │
│  Telefone: (11) 98765-4321                                  │
│  Email: joao@email.com                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Detalhes da Consulta:

- **Paciente ID**: null (cliente ainda não cadastrado)
- **Médico**: Selecionado pelo cliente
- **Data/Hora**: Escolhida pelo cliente
- **Tipo**: Consulta, Retorno, Exame ou Procedimento
- **Status**: Agendada
- **Motivo**: Texto fornecido pelo cliente
- **Observações**: Nome, telefone e email do cliente
- **Lembretes**: Ativados automaticamente

---

## 🎯 Fluxo de Trabalho

### 1. Cliente Acessa o Portal
```
Cliente → Portal (/portal-cliente) → Formulário
```

### 2. Cliente Preenche Dados
```
Dados Pessoais → Seleção de Médico → Data/Hora → Confirma
```

### 3. Sistema Processa
```
Validação → Criação no Banco → Confirmação Visual
```

### 4. Aparece no Sistema
```
Consultas → Nova Entrada → Status: Agendada
```

### 5. Equipe Confirma
```
Visualiza → Confirma Disponibilidade → Envia Confirmação
```

---

## 📊 Campos do Formulário

### Obrigatórios (*):
- ✅ Nome Completo
- ✅ Telefone/WhatsApp
- ✅ Médico
- ✅ Data
- ✅ Horário
- ✅ Tipo de Atendimento

### Opcionais:
- 📧 Email
- 📝 Motivo da Consulta

---

## 🔧 Configuração Técnica

### Arquivo Principal:
```
src/pages/PortalClientePage.tsx
```

### Rota:
```typescript
{
  name: 'Portal do Cliente',
  path: '/portal-cliente',
  element: <PortalClientePage />,
  visible: false  // Não aparece no menu interno
}
```

### API Utilizada:
```typescript
// Buscar médicos disponíveis
medicosApi.getAll()

// Criar agendamento
consultasApi.create({
  paciente_id: null,
  medico_id: string,
  data_hora: string,
  tipo: string,
  status: 'Agendada',
  motivo: string,
  observacoes: string,
  ...
})
```

---

## 🎨 Design e UX

### Características:

1. **Visual Atraente**
   - Gradiente suave de fundo
   - Cards com sombras
   - Ícones ilustrativos
   - Cores do tema do sistema

2. **Responsivo**
   - Funciona em desktop
   - Funciona em tablet
   - Funciona em smartphone
   - Layout adaptativo

3. **Feedback Visual**
   - Mensagens de sucesso
   - Mensagens de erro
   - Loading states
   - Validação em tempo real

4. **Acessibilidade**
   - Labels claros
   - Campos obrigatórios marcados
   - Mensagens descritivas
   - Navegação por teclado

---

## 📱 Divulgação do Portal

### 1. QR Code
Gere um QR Code apontando para `/portal-cliente` e divulgue em:
- Recepção da clínica
- Materiais impressos
- Redes sociais
- WhatsApp Status

### 2. Link Direto
Compartilhe o link em:
- WhatsApp Business
- Instagram Bio
- Facebook
- Google Meu Negócio
- Site institucional

### 3. Mensagem Sugerida
```
📅 Agende sua consulta online!

Acesse nosso portal de agendamento:
https://seu-dominio.com/portal-cliente

✅ Rápido e fácil
✅ Escolha seu médico
✅ Selecione data e horário
✅ Confirmação imediata

Estamos esperando por você! 🏥
```

---

## ⚙️ Validações Implementadas

### No Cliente:
1. ✅ Todos os campos obrigatórios preenchidos
2. ✅ Email válido (se fornecido)
3. ✅ Data não pode ser no passado
4. ✅ Médico deve ser selecionado

### No Sistema:
1. ✅ Conversão correta de data/hora
2. ✅ Campos opcionais tratados como null
3. ✅ Mensagens de erro descritivas
4. ✅ Logging de erros no console

---

## 🔔 Notificações

### Automáticas:
- ✅ Lembrete WhatsApp ativado
- ✅ Lembrete Email (se fornecido)
- ✅ Status: Agendada

### Manuais (pela equipe):
- Confirmação do agendamento
- Alterações de horário
- Cancelamentos
- Lembretes adicionais

---

## 📈 Benefícios

### Para a Clínica:
- ✅ Reduz ligações telefônicas
- ✅ Disponibilidade 24/7
- ✅ Dados já digitalizados
- ✅ Menos erros de anotação
- ✅ Processo automatizado

### Para o Cliente:
- ✅ Conveniência
- ✅ Agendar a qualquer hora
- ✅ Sem necessidade de ligar
- ✅ Confirmação imediata
- ✅ Escolha de médico e horário

---

## 🔒 Segurança

### Dados Protegidos:
- Conexão HTTPS
- Validação de entrada
- Sanitização de dados
- Sem armazenamento de senhas
- Conformidade com LGPD

### Privacidade:
- Dados usados apenas para agendamento
- Não compartilhados com terceiros
- Cliente não precisa criar conta
- Informações armazenadas com segurança

---

## 🚀 Próximos Passos

### Melhorias Futuras:
1. **Disponibilidade de Horários**
   - Mostrar apenas horários disponíveis
   - Integração com agenda dos médicos
   - Bloqueio de horários ocupados

2. **Cadastro Automático**
   - Criar paciente automaticamente
   - Vincular agendamento ao paciente
   - Histórico de consultas

3. **Confirmação Automática**
   - Envio de WhatsApp automático
   - Envio de email automático
   - SMS de confirmação

4. **Pagamento Online**
   - Pagamento antecipado
   - Reserva de horário
   - Comprovante digital

---

## 📞 Suporte

### Para Clientes:
- Telefone da clínica
- WhatsApp
- Email de contato

### Para Administradores:
- Consulte a documentação técnica
- Verifique logs de erro
- Entre em contato com suporte técnico

---

## ✅ Checklist de Implementação

- [x] Página do portal criada
- [x] Rota configurada
- [x] Integração com API
- [x] Validações implementadas
- [x] Design responsivo
- [x] Mensagens de feedback
- [x] Tela de confirmação
- [x] Documentação completa

---

**Implementado em**: 2025-11-22  
**Versão**: 1.0.0  
**Status**: ✅ Pronto para Uso  
**Acesso**: `/portal-cliente`
