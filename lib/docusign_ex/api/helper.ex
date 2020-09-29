defmodule DocusignEx.Api.Helper do
  @moduledoc """
  Docusign API helpers
  """

  @doc """
  Create a docusign custom header `X-DocuSign-Authentication` using the given parameters.
  """
  @spec build_custom_auth_header(String.t(), String.t(), String.t()) :: {String.t(), String.t()}
  def build_custom_auth_header(username, password, integrator_key) do
    payload = %{
      "Username" => username,
      "Password" => password,
      "IntegratorKey" => integrator_key
    }

    {"X-DocuSign-Authentication", Poison.encode!(payload)}
  end
end
