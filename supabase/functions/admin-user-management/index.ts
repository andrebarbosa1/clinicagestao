import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface CreateUserRequest {
  action: 'create';
  username: string;
  password: string;
  nome_completo: string;
  role?: 'admin' | 'medico' | 'recepcionista';
}

interface UpdatePasswordRequest {
  action: 'update_password';
  userId: string;
  newPassword: string;
}

type RequestBody = CreateUserRequest | UpdatePasswordRequest;

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    );

    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      throw new Error('Autorização necessária');
    }

    const token = authHeader.replace('Bearer ', '');
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser(token);

    if (userError || !user) {
      throw new Error('Usuário não autenticado');
    }

    const { data: profile, error: profileError } = await supabaseClient
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .maybeSingle();

    if (profileError || !profile || profile.role !== 'admin') {
      throw new Error('Acesso negado. Apenas administradores podem executar esta ação');
    }

    const body: RequestBody = await req.json();

    if (body.action === 'create') {
      const { username, password, nome_completo, role = 'recepcionista' } = body;

      if (!username || !password || !nome_completo) {
        throw new Error('Campos obrigatórios: username, password, nome_completo');
      }

      if (password.length < 6) {
        throw new Error('A senha deve ter no mínimo 6 caracteres');
      }

      if (!/^[a-zA-Z0-9_]+$/.test(username)) {
        throw new Error('O nome de usuário deve conter apenas letras, números e underscore');
      }

      const email = `${username}@miaoda.com`;

      const { data: newUser, error: createError } = await supabaseClient.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: {
          nome_completo,
        },
      });

      if (createError) {
        throw new Error(`Erro ao criar usuário: ${createError.message}`);
      }

      const { error: profileUpdateError } = await supabaseClient
        .from('profiles')
        .update({ role, nome_completo, username })
        .eq('id', newUser.user.id);

      if (profileUpdateError) {
        throw new Error(`Erro ao atualizar perfil: ${profileUpdateError.message}`);
      }

      return new Response(
        JSON.stringify({
          success: true,
          message: 'Usuário criado com sucesso',
          user: {
            id: newUser.user.id,
            email: newUser.user.email,
            username,
            nome_completo,
            role,
          },
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      );
    } else if (body.action === 'update_password') {
      const { userId, newPassword } = body;

      if (!userId || !newPassword) {
        throw new Error('Campos obrigatórios: userId, newPassword');
      }

      if (newPassword.length < 6) {
        throw new Error('A senha deve ter no mínimo 6 caracteres');
      }

      const { error: updateError } = await supabaseClient.auth.admin.updateUserById(
        userId,
        { password: newPassword }
      );

      if (updateError) {
        throw new Error(`Erro ao atualizar senha: ${updateError.message}`);
      }

      return new Response(
        JSON.stringify({
          success: true,
          message: 'Senha atualizada com sucesso',
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      );
    } else {
      throw new Error('Ação inválida');
    }
  } catch (error) {
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    );
  }
});
