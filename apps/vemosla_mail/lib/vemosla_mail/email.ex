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
end
