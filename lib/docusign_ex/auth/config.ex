defmodule DocusignEx.Auth.Config do
  @moduledoc """
  Auth Config for Docusign API
  """

  @enforce_keys [:username, :password, :integrator_key]
  defstruct [:username, :password, :integrator_key, :base_url]

  @type t :: %{
          username: String.t(),
          password: String.t(),
          integrator_key: String.t(),
          base_url: String.t()
        }

  @spec new(String.t(), String.t(), String.t()) :: __MODULE__.t()
  def new(username, password, integrator_key) do
    %__MODULE__{
      username: username,
      password: password,
      integrator_key: integrator_key
    }
  end

  @spec set_base_url(__MODULE__.t(), String.t()) :: __MODULE__.t()
  def set_base_url(%__MODULE__{} = config, base_url) do
    %{config | base_url: base_url}
  end

  @spec set_login_url(__MODULE__.t()) :: __MODULE__.t()
  def set_login_url(%__MODULE__{} = config) do
    base_url = System.get_env("DOCUSIGN_LOGIN_URL")
    set_base_url(config, base_url)
  end
end
