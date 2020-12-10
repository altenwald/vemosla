defmodule VemoslaMail do
  alias VemoslaMail.{Email, Mailer}

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    Email.confirmation_instructions(user, url)
    |> Mailer.deliver_now()
    |> case do
      %Bamboo.Email{text_body: body} -> {:ok, %{to: user.email, body: body}}
      error -> error
    end
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    Email.reset_password_instructions(user, url)
    |> Mailer.deliver_now()
    |> case do
      %Bamboo.Email{text_body: body} -> {:ok, %{to: user.email, body: body}}
      error -> error
    end
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    Email.update_email_instructions(user, url)
    |> Mailer.deliver_now()
    |> case do
      %Bamboo.Email{text_body: body} -> {:ok, %{to: user.email, body: body}}
      error -> error
    end
  end
end
