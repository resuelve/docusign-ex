defmodule DocusignEx.Api.AuthBase do
  @moduledoc """
  Funcionalidades básicas y comunes del API del Docusign
  """

  @auth_header "{\"Username\":\"%s\",\"Password\":\"%s\",\"IntegratorKey\": \"%s\"}"

  use HTTPoison.Base

  def api, do: "https://demo.docusign.net/restapi/v2"
  defp process_url(url), do: api() <> url
  defp process_request_body(body), do: Poison.encode!(body)

  defp process_request_headers(_headers) do
    username = Application.get_env(:docusign_ex, :username)
    password = Application.get_env(:docusign_ex, :password)
    integrator_key = Application.get_env(:docusign_ex, :integrator_key)
    auth_headers = ExPrintf.sprintf(@auth_header, [username, password, integrator_key])

    [
      {"X-DocuSign-Authentication", auth_headers},
      {"Content-Type", "application/json"},
    ]
  end

  defp process_response_body(body) do
    {:ok, success_response} = Poison.decode(body)
    success_response
  end
end
