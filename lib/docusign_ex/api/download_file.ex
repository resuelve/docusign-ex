defmodule DocusignEx.Api.DownloadFile do
  @moduledoc """
  Funcionalidades para descarga de documentos
  """

  @auth_header "{\"Username\":\"%s\",\"Password\":\"%s\",\"IntegratorKey\": \"%s\"}"

  use HTTPoison.Base

  def api, do: Process.get("base_url")
  defp process_url(url), do: api() <> url

  defp process_request_headers(headers) do
    username = Application.get_env(:docusign_ex, :username)
    password = Application.get_env(:docusign_ex, :password)
    integrator_key = Application.get_env(:docusign_ex, :integrator_key)
    auth_headers = ExPrintf.sprintf(@auth_header, [username, password, integrator_key])

    [
      {"X-DocuSign-Authentication", auth_headers},
      {"Content-Type", "application/json"},
    ]
  end
end
