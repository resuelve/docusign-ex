defmodule DocusignEx.Api.Base do
  @moduledoc """
  Funcionalidades básicas y comunes del API del Docusign
  """

  @auth_header "{\"Username\":\"%s\",\"Password\":\"%s\",\"IntegratorKey\": \"%s\"}"
  @connect_timeout 100000
  @recv_timeout 100000
  @timeout 100000

  use HTTPoison.Base

  def api, do: Process.get("base_url")
  defp process_url(url), do: api() <> url
  defp process_request_body(body), do: Poison.encode!(body)

  defp process_request_options(options) do
    [
      connect_timeout: @connect_timeout,
      recv_timeout: @recv_timeout,
      timeout: @timeout
    ]
  end

  defp process_request_headers(headers) do
    username = Application.get_env(:docusign_ex, :username)
    password = Application.get_env(:docusign_ex, :password)
    integrator_key = Application.get_env(:docusign_ex, :integrator_key)
    auth_headers = ExPrintf.sprintf(@auth_header, [username, password, integrator_key])

    [
      {"X-DocuSign-Authentication", auth_headers},
      {"Content-Type", "application/json"},
    ] ++ headers
  end

  defp process_response_body(body) do
    case Poison.decode(body) do
      {:ok, success_response} ->
        success_response
      _ ->
        :error
    end
  end

end
