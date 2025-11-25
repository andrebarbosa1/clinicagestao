import "jsr:@supabase/functions-js/edge-runtime.d.ts";

interface ReminderRequest {
  phone: string;
  message: string;
  consultaId: string;
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
    });
  }

  try {
    const { phone, message, consultaId }: ReminderRequest = await req.json();

    if (!phone || !message) {
      return new Response(
        JSON.stringify({ error: 'Telefone e mensagem são obrigatórios' }),
        {
          status: 400,
          headers: { 'Content-Type': 'application/json' },
        }
      );
    }

    // Aqui você pode integrar com serviços como Twilio, WhatsApp Business API, etc.
    // Por enquanto, vamos apenas simular o envio
    
    // Exemplo de integração com Twilio (descomente e configure):
    /*
    const TWILIO_ACCOUNT_SID = Deno.env.get('TWILIO_ACCOUNT_SID');
    const TWILIO_AUTH_TOKEN = Deno.env.get('TWILIO_AUTH_TOKEN');
    const TWILIO_WHATSAPP_NUMBER = Deno.env.get('TWILIO_WHATSAPP_NUMBER');

    const twilioUrl = `https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json`;
    const auth = btoa(`${TWILIO_ACCOUNT_SID}:${TWILIO_AUTH_TOKEN}`);

    const response = await fetch(twilioUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        From: `whatsapp:${TWILIO_WHATSAPP_NUMBER}`,
        To: `whatsapp:${phone}`,
        Body: message,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Erro ao enviar WhatsApp: ${error}`);
    }
    */

    // Simulação de envio bem-sucedido
    console.log(`Lembrete enviado para ${phone}: ${message}`);
    console.log(`Consulta ID: ${consultaId}`);

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Lembrete enviado com sucesso',
        consultaId,
      }),
      {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    );
  } catch (error) {
    console.error('Erro ao enviar lembrete:', error);
    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : 'Erro desconhecido',
      }),
      {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    );
  }
});
