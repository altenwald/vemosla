defmodule Vemosla.Accounts.UserNotifier do
  @doc """
  Deliver instructions to confirm account.
  """
  defdelegate deliver_confirmation_instructions(user, url), to: VemoslaMail

  @doc """
  Deliver instructions to reset a user password.
  """
  defdelegate deliver_reset_password_instructions(user, url), to: VemoslaMail

  @doc """
  Deliver instructions to update a user email.
  """
  defdelegate deliver_update_email_instructions(user, url), to: VemoslaMail
end
