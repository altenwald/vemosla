defmodule VemoslaMail.Email do
  import Bamboo.Email

  defp config do
    Application.get_env(:vemosla_mail, :email, [])
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def confirmation_instructions(user, url) do
    config = config()
    new_email()
    |> from(config[:from])
    |> to(user.email)
    |> subject("[Vemosla] Instrucciones de confirmación")
    |> text_body("""
    Hola,

    Puedes confirmar la cuenta visitando la siguiente URL:

    #{url}

    Si no creaste una cuenta en vemosla.com, por favor, ignora este email.

    El equipo de Vemosla!
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def reset_password_instructions(user, url) do
    config = config()
    new_email()
    |> from(config[:from])
    |> to(user.email)
    |> subject("[Vemosla] Instrucciones de recuperación de clave")
    |> text_body("""
    Hola,

    Puedes recuperar tu clave visitando la siguiente URL:

    #{url}

    Si no solicitaste recuperar la clave, por favor, ignora este email.

    El equipo de Vemosla!
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def update_email_instructions(user, url) do
    config = config()
    new_email()
    |> from(config[:from])
    |> to(user.email)
    |> subject("[Vemosla] Instrucciones de cambio de email")
    |> text_body("""
    Hola,

    Puedes cambiar tu dirección de email visitando la siguiente URL:

    #{url}

    Si no solicitaste este cambio, por favor, ignora este email.

    El equipo de Vemosla!
    """)
  end

  @doc """
  Deliver instructions to accpet an invitation.
  """
  def invitation_instructions(relation, url) do
    config = config()
    name = relation.user.profile.name
    body =
      case relation.body_msg do
        "" -> ""
        msg -> "\n#{name} quiere decirte: #{msg}\n"
      end

    new_email()
    |> from(config[:from])
    |> to(relation.friend_email)
    |> subject("[Vemosla] Invitación de #{name}")
    |> text_body("""
    Hola,

    Te enviamos este mensaje porque el usuario #{name}
    quiere invitarte para conectar en vemosla.com, sigue el enlace
    para aceptar su invitación:

    #{url}
    #{body}
    Si no tienes cuenta, antes de aceptar la invitación deberás crear
    la cuenta. Es un proceso rápido, no te preocupes.

    El equipo de Vemosla!
    """)
  end
end
