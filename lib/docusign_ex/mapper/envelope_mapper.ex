defmodule DocusignEx.Mapper.EnvelopeMapper do
  @moduledoc """
  Module to prepare a payload for a given envelope struct
  """

  alias DocusignEx.Envelope

  @signer_default_lang "es"

  # TODO: allow to parameterize these values
  @envelope_events ["sent", "delivered", "completed", "declined", "voided"]
  @recipient_events [
    "Sent",
    "Delivered",
    "Completed",
    "Declined",
    "AuthenticationFailed",
    "AutoResponded"
  ]

  @spec build_payload(Envelope.t()) :: map
  def build_payload(%Envelope{} = envelope) do
    # we need to set `sent` status to force to send the envelope once it's created
    payload = %{
      "status" => "sent",
      "emailSubject" => envelope.email_subject,
      "documents" =>
        envelope.documents
        |> Enum.with_index(1)
        |> Enum.map(fn {doc, index} -> map_document(doc, index) end),
      "recipients" => %{
        "signers" =>
          envelope.signers
          |> Enum.with_index(1)
          |> Enum.map(fn {signer, index} -> map_signer(signer, index) end)
      },
      "eventNotification" => setup_webhook(envelope.webhook_url)
    }

    # brand id value is verified during envelope creation, this values is not required
    # that's why we only include it when it's not nil
    unless is_nil(envelope.brand_id) do
      Map.put(payload, "brandId", envelope.brand_id)
    else
      payload
    end
  end

  @spec map_document(%{filename: String.t(), content: iodata}, integer) :: map
  defp map_document(%{filename: filename, content: content}, order) do
    # we assume all the filenames have the form {filename}.{extension} so we can safely make a split
    [filename, extension] = String.split(filename, ".")

    %{
      "documentBase64" => Base.encode64(content),
      "documentId" => order,
      "fileExtension" => extension,
      "name" => filename
    }
  end

  @spec map_signer(map, integer) :: map
  defp map_signer(signer, order) do
    %{
      "email" => signer.email,
      "emailNotification" => %{
        "supportedLanguage" => Map.get(signer, :lang, @signer_default_lang)
      },
      "name" => signer.email,
      "recipientId" => order,
      "routingOrder" => order,
      "tabs" =>
        signer
        |> Map.get(:tabs, [])
        |> Enum.group_by(&Map.get(&1, :key), &map_tab/1)
    }
  end

  @spec map_tab(map) :: map
  defp map_tab(tab) do
    %{
      "anchorIgnoreIfNotPresent" => "false",
      "anchorString" => tab.string,
      "anchorUnits" => "pixels",
      "anchorXOffset" => tab.x_offset,
      "anchorYOffset" => tab.y_offset
    }
  end

  @spec setup_webhook(String.t()) :: map
  defp setup_webhook(url) do
    %{
      "url" => url,
      "envelopeEvents" => Enum.map(@envelope_events, &%{"envelopeEventStatusCode" => &1}),
      "recipientEvents" => Enum.map(@recipient_events, &%{"recipientEventStatusCode" => &1}),
      "includeCertificateOfCompletion" => "false",
      "includeCertificateWithSoap" => "false",
      "includeDocumentFields" => "false",
      "includeDocuments" => "false",
      "includeEnvelopeVoidReason" => "true",
      "includeSenderAccountAsCustomField" => "false",
      "includeTimeZone" => "false",
      "loggingEnabled" => "true",
      "requireAcknowledgment" => "true",
      "signMessageWithX509Cert" => "false",
      "useSoapInterface" => "false"
    }
  end
end
