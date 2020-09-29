defmodule DocusignEx.Api.CreditoAuthBase do
  @moduledoc """
  Funcionalidades básicas y comunes del API del Docusign
  """

  use HTTPoison.Base

  alias DocusignEx.Api.Helper

  def api, do: Application.get_env(:docusign_ex, :host)
  defp process_url(url), do: api() <> url
  defp process_request_body(body), do: Poison.encode!(body)

  defp process_request_headers(_headers) do
    username = Application.get_env(:docusign_ex, :credito_username)
    password = Application.get_env(:docusign_ex, :credito_password)
    integrator_key = Application.get_env(:docusign_ex, :integrator_key)

    [
      Helper.build_custom_auth_header(username, password, integrator_key),
      {"Content-Type", "application/json"}
    ]
  end

  defp process_response_body(body) do
    {:ok, success_response} = Poison.decode(body)
    success_response
  end
end
