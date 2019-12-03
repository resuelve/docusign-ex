defmodule DocusignEx.Api.Base do
  @moduledoc """
  Funcionalidades básicas y comunes del API del Docusign
  """

  @auth_header "{\"Username\":\"%s\",\"Password\":\"%s\",\"IntegratorKey\": \"%s\"}"
  @connect_timeout 100_000
  @recv_timeout 100_000
  @timeout 100_000

  use HTTPoison.Base

  # Devuelve el endpoint de Docusign
  @spec api :: String.t()
  def api, do: Process.get("base_url")

  # Devuelve el path a donde se hace la petición
  @spec process_url(String.t()) :: String.t()
  defp process_url(url), do: api() <> url

  # Encodear de mapa a string el body
  @spec process_request_body(map) :: String.t()
  defp process_request_body(body), do: Poison.encode!(body)

  # Agrega los opciones compartidos por todos los requests que usen este módulo
  @spec process_request_options(list) :: list
  defp process_request_options(options) do
    [
      connect_timeout: @connect_timeout,
      recv_timeout: @recv_timeout,
      timeout: @timeout
    ] ++ options
  end

  # Agrega los headers compartidos por todos los requests que usen este módulo
  @spec process_request_headers(list) :: list
  defp process_request_headers(headers) do
    username = Application.get_env(:docusign_ex, :la_tasa_username)
    password = Application.get_env(:docusign_ex, :la_tasa_password)
    integrator_key = Application.get_env(:docusign_ex, :integrator_key)
    auth_headers = ExPrintf.sprintf(@auth_header, [username, password, integrator_key])

    [
      {"X-DocuSign-Authentication", auth_headers},
      {"Content-Type", "application/json"}
    ] ++ headers
  end

  # Devuelve la respuesta de Docusign en un mapa o un atomo de error si fallo
  @spec process_response_body(String.t()) :: :error | map
  defp process_response_body(body) do
    case Poison.decode(body) do
      {:ok, success_response} ->
        success_response

      _ ->
        :error
    end
  end
end
