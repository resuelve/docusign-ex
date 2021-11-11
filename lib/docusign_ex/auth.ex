defmodule DocusignEx.Auth do
  @moduledoc """
  Docusign API managment
  """

  alias DocusignEx.Auth.Config
  alias DocusignEx.Request

  @login_endpoint "login_information"

  @doc """
  Creates an Auth Config needed for a login
  """
  @spec config(String.t(), String.t(), String.t()) :: Config.t()
  def config(username, password, integrator_key) do
    Config.new(username, password, integrator_key)
  end

  @spec config(map()) :: Config.t()
  def config(%{"username" => username, "password" => password, "integrator_key" => integrator_key}) do
    config(username, password, integrator_key)
  end

  @doc """
  Logins on the Docusign API
  """
  @spec login(Config.t()) :: {:ok, Config.t()} | {:error, String.t()}
  def login(%Config{} = auth_config) do
    auth_config
    |> Config.set_login_url()
    |> Request.new(@login_endpoint)
    |> Request.get()
    |> case do
      %{valid?: true, response: response} ->
        base_url = extract_base_url(response)

        {:ok, %{auth_config | base_url: base_url}}

      failed_request ->
        {:error, failed_request.error}
    end
  end

  @spec extract_base_url(map()) :: String.t()
  defp extract_base_url(response) do
    response
    |> Map.get("loginAccounts")
    |> List.first()
    |> Map.get("baseUrl")
  end
end
