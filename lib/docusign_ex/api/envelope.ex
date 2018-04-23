defmodule DocusignEx.Api.Envelope do
  @moduledoc """
  Manejo de apis relacionadas a los sobres de Docusign
  """

  require Logger
  alias DocusignEx.Api.Base
  alias DocusignEx.Api.DownloadFile
  alias HTTPoison.Response
  alias HTTPoison.Error
  alias DocusignEx.Mapper.EnvelopeMapper

  @doc """
  Envia un documento para que el remitente pueda firmarlo.

  ## Ejemplos:
      iex> data = %{
        "subject" => "Test",
        "signers" => [...]
      }
      iex> DocusignEx.Api.Envelope(data)
      %{
        "envelopeId" => "5aadc814-53be-4a03-8590-6cf381faa163",
        "status" => "sent",
        "statusDateTime" => "2017-07-17T17:53:51.0370000Z",
        "uri" => "/envelopes/5aadc814-53be-4a03-8590-6cf381faa163"
      }
  """
  @spec send_envelope(map) :: map
  def send_envelope(envelope_data) do
    envelope = EnvelopeMapper.map(envelope_data)

    "/envelopes"
    |> Base.post(
         envelope,
         [],
         [connect_timeout: 100000, recv_timeout: 100000, timeout: 100000]
       )
    |> parse_post_response()
  end

  @spec get_envelope(String.t()) :: map
  def get_envelope(envelope_uid) do
    "/envelopes/#{envelope_uid}"
    |> Base.get(
         [],
         [connect_timeout: 100000, recv_timeout: 100000, timeout: 100000]
       )
    |> parse_get_response()
  end

  @spec get_documents(String.t()) :: map
  def get_documents(envelope_uid) do
    "/envelopes/#{envelope_uid}/documents"
    |> Base.get(
         [],
         [connect_timeout: 100000, recv_timeout: 100000, timeout: 100000]
       )
    |> parse_get_response()
  end

  @spec download_document(String.t, String.t) :: map
  def download_document(envelope_uid, document_id) do
    "/envelopes/#{envelope_uid}/documents/#{document_id}"
    |> DownloadFile.get(
         [],
         [connect_timeout: 100000, recv_timeout: 100000, timeout: 100000]
       )
  end

  @spec parse_post_response({:ok, %Response{}}) :: map()
  defp parse_post_response(
         {
           :ok,
           %Response{
             body: body,
             headers: headers,
             status_code: 201
           }
         }
       ) do
    {:ok, body}
  end
  defp parse_post_response({:ok, %Response{body: body}}), do: {:error, body}
  defp parse_post_response(_), do: {:error, %{
    "errorCode" => "Unknown",
    "message" => "Unknown error"
  }}

  @spec parse_get_response(tuple) :: tuple
  def parse_get_response({:ok, %Response{body: body, status_code: 200}}) do
    {:ok, body}
  end
  def parse_get_response(error) do
    Logger.error(
      "No se pudo obtener información del paquete, #{inspect(error)}"
    )
    {:error, "Error al obtener el paquete de docusign"}
  end
end
