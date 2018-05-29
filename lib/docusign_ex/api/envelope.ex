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
      iex> DocusignEx.Api.Envelope.send_envelope(data)
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
    |> Base.post(envelope)
    |> _parse_post_response()
  end

  @doc """
  Obtiene la información de un sobre de docusign
  """
  @spec get_envelope(String.t()) :: map
  def get_envelope(envelope_uid) do
    "/envelopes/#{envelope_uid}"
    |> Base.get()
    |> _parse_get_response()
  end

  @doc """
  Obtiene la lista de documentos asociados a un sobre de docusign
  """
  @spec get_documents(String.t()) :: map
  def get_documents(envelope_uid) do
    "/envelopes/#{envelope_uid}/documents"
    |> Base.get()
    |> _parse_get_response()
  end

  @doc """
  Devuelve el stream de datos de un documento
  """
  @spec download_document(String.t, String.t) :: map
  def download_document(envelope_uid, document_id) do
    "/envelopes/#{envelope_uid}/documents/#{document_id}"
    |> DownloadFile.get()
    |> _parse_download_response()
  end

  @spec _parse_post_response({:ok, %Response{}}) :: map()
  defp _parse_post_response(
         {
           :ok,
           %Response{
             body: body,
             headers: _headers,
             status_code: 201
           }
         }
       ) do
    {:ok, body}
  end
  defp _parse_post_response({:ok, %Response{body: body}}), do: {:error, body}
  defp _parse_post_response(_), do: {:error, %{
    "errorCode" => "Unknown",
    "message" => "Unknown error"
  }}

  @spec _parse_get_response(tuple) :: tuple
  defp _parse_get_response({:ok, %Response{body: body, status_code: 200}}) do
    {:ok, body}
  end
  defp _parse_get_response(error) do
    Logger.error(
      "No se pudo obtener información del paquete, #{inspect(error)}"
    )
    {:error, "El paquete no existe o no se puede acceder en este momento"}
  end

  @spec _parse_download_response(tuple) :: tuple
  defp _parse_download_response(
         {:ok, %Response{body: body, headers: headers, status_code: 200}}
       ) do
    if Enum.find(
         headers,
         fn {header_name, header_value} -> header_name == "Content-Type" and
                                           header_value == "application/pdf"
         end
       ) do
      {:ok, body}
    else
      {:error, "El documento no es un PDF"}
    end

  end
  defp _parse_download_response(error) do
    Logger.error(
      "No se pudo obtener información documento, #{inspect(error)}"
    )
    {:error, "El documento no existe o no se puede acceder en este momento"}
  end
end
