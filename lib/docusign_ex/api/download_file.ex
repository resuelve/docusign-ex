defmodule DocusignEx.Api.DownloadFile do
  @moduledoc """
  Funcionalidades para descarga de documentos
  """

  @auth_header "{\"Username\":\"%s\",\"Password\":\"%s\",\"IntegratorKey\": \"%s\"}"

  use HTTPoison.Base

  @doc """
  Devuelve la URL base para realizar peticiones a Docusign (incluyendo el id
  de la cuenta
  """
  @spec api() :: String.t()
  def api, do: Process.get("base_url")

  # Devuelve la url del servicio concatenada con la url del host
  @spec process_url(String.t()) :: String.t()
  defp process_url(url), do: api() <> url

  # Agrega los headers de autenticación a la petición de Docusign
  @spec process_request_headers(list) :: list
  defp process_request_headers(headers) do
    username = Application.get_env(:docusign_ex, :username)
    password = Application.get_env(:docusign_ex, :password)
    integrator_key = Application.get_env(:docusign_ex, :integrator_key)
    auth_headers = ExPrintf.sprintf(@auth_header, [username, password, integrator_key])

    [
      {"X-DocuSign-Authentication", auth_headers},
      {"Content-Type", "application/json"}
    ]
  end
end
