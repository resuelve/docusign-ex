defmodule DocusignEx.Api.Envelope do
  @moduledoc """
  Manejo de apis relacionadas a los sobres de Docusign
  """

  alias DocusignEx.Api.Base
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
    |> Base.post(envelope)
    |> parse_envelope()
  end

  @spec parse_envelope({:ok, %Response{}}) :: map()
  defp parse_envelope({:ok, %Response{
    body: body,
    headers: headers,
    status_code: 201}}) do
    body
  end

  @doc """
  Crea una plantilla
  """
  @spec create_template(map) :: map
  def create_template(data) do
    Base.post("/templates", data)
  end
end
