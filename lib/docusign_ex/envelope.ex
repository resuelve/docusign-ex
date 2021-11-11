defmodule DocusignEx.Envelope do
  @moduledoc """
  Manejo de apis relacionadas a los sobres de Docusign
  """

  alias DocusignEx.Mapper.EnvelopeMapper
  alias DocusignEx.Request

  require Logger

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
  @spec send_envelope(Config.t(), map) :: Request.json_api_response()
  def send_envelope(auth_config, envelope_data) do
    envelope = EnvelopeMapper.map(envelope_data)

    auth_config
    |> Request.new("envelopes")
    |> Request.set_expected_status_code(201)
    |> Request.post(envelope)
    |> Request.unwrap_response()
  end

  @doc """
  Reenvía un sobre a sus destinatarios originales
  """
  @spec resend_envelope(Config.t(), String.t()) :: Request.json_api_response()
  def resend_envelope(auth_config, envelope_uid) do
    with {:ok, recipients} = get_recipients(auth_config, envelope_uid) do
      signers = Map.take(recipients, ["signers"])

      auth_config
      |> Request.new("/envelopes/#{envelope_uid}/recipients")
      |> Request.add_query_param("resend_envelope", true)
      |> Request.put(signers)
      |> Request.unwrap_response()
    end
  end

  # Devuelve la lista de destinatorios de un sobre
  @spec get_recipients(Config.t(), String.t()) :: Request.json_api_response()
  defp get_recipients(auth_config, envelope_uid) do
    auth_config
    |> Request.new("/envelopes/#{envelope_uid}/recipients")
    |> Request.get()
    |> Request.unwrap_response()
  end

  @doc """
  Actualiza un sobre por medio del uid

  ## Ejemplos
    iex> data = %{"status" => "voided" =>, "voidedReason" => "The reason"}
    iex> envelope_uid = "2a4674c5-4fd4-47b0-9af0-89970dd8e6c9"
    iex> DocusignEx.Api.Envelope.send_envelope(envelope_uid, data)
    {
      :ok, %{"envelopeId" => "2a4674c5-4fd4-47b0-9af0-89970dd8e6c9"}
    }
  """
  @spec update_envelope(Config.t(), String.t(), map) :: Request.json_api_response()
  def update_envelope(auth_config, envelope_uid, data) do
    auth_config
    |> Request.new("/envelopes/#{envelope_uid}")
    |> Request.put(data)
    |> Request.unwrap_response()
  end

  @doc """
  Obtiene la información de un sobre de docusign
  """
  @spec get_envelope(Config.t(), String.t()) :: Request.json_api_response()
  def get_envelope(auth_config, envelope_uid) do
    auth_config
    |> Request.new("/envelopes/#{envelope_uid}")
    |> Request.get()
    |> Request.unwrap_response()
  end

  @doc """
  Obtiene la lista de documentos asociados a un sobre de docusign
  """
  @spec get_documents(Config.t(), String.t()) :: Request.json_api_response()
  def get_documents(auth_config, envelope_uid) do
    auth_config
    |> Request.new("/envelopes/#{envelope_uid}/documents")
    |> Request.get()
    |> Request.unwrap_response()
  end

  @doc """
  Devuelve el stream de datos de un documento
  """
  @spec download_document(Config.t(), String.t(), String.t()) :: Request.api_response()
  def download_document(auth_config, envelope_uid, document_id) do
    auth_config
    |> Request.new("/envelopes/#{envelope_uid}/documents/#{document_id}")
    |> Request.set_response_type("binary")
    |> Request.get()
    |> Request.unwrap_response()
  end
end
