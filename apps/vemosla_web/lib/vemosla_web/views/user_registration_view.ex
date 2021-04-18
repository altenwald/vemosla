defmodule VemoslaWeb.UserRegistrationView do
  use VemoslaWeb, :view

  def public_key() do
    Application.get_env(:vemosla_web, :public_key)
  end
end
