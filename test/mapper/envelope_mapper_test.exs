defmodule DocusignEx.Mapper.EnvelopeMapperTest do
  use ExUnit.Case

  alias DocusignEx.Envelope
  alias DocusignEx.Mapper.EnvelopeMapper

  test "build_payload/1 render a envelope with documents and signers correctly" do
    envelope = %Envelope{
      email_subject: "test subject",
      webhook_url: "http://localhost",
      brand_id: "c6086cf4-1c7c-4a43-9084-928df75de8a5",
      documents: [
        %{
          filename: "contract.pdf",
          content: "some random content"
        }
      ],
      signers: [
        %{
          lang: "it",
          name: "test",
          email: "test@test.com",
          tabs: [
            %{key: "signHereTabs", string: "SIGN_MARK", x_offset: 10, y_offset: 15}
          ]
        }
      ]
    }

    assert %{} = payload = EnvelopeMapper.build_payload(envelope)

    refute is_nil(payload["brandId"])

    assert payload
           |> get_in(["recipients", "signers"])
           |> hd()
           |> get_in(["emailNotification", "supportedLanguage"]) == "it"

    assert [
             %{
               "anchorIgnoreIfNotPresent" => "false",
               "anchorString" => "SIGN_MARK",
               "anchorUnits" => "pixels",
               "anchorXOffset" => 10,
               "anchorYOffset" => 15
             }
           ] =
             payload
             |> get_in(["recipients", "signers"])
             |> hd()
             |> get_in(["tabs", "signHereTabs"])

    assert get_in(payload, ["eventNotification", "url"]) == "http://localhost"

    assert %{
             "documentBase64" => _encoded,
             "documentId" => 1,
             "name" => "contract",
             "fileExtension" => "pdf"
           } = hd(payload["documents"])
  end

  test "build_payload/1 render a envelope with no brand, no documents and no signers" do
    envelope = %Envelope{
      email_subject: "test subject",
      webhook_url: "http://localhost",
      documents: [],
      signers: []
    }

    assert %{} = payload = EnvelopeMapper.build_payload(envelope)

    assert is_nil(payload["brandId"])
    assert payload["documents"] == []
    assert payload["recipients"]["signers"] == []
  end
end
