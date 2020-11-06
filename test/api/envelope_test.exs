defmodule DocusignEx.Api.EnvelopeTest do
  use ExUnit.Case

  import Mock
  alias DocusignEx.Api.Envelope

  setup do
    [
      json: %{
        "subject" => "Test",
        "signers" => [
          %{
            "name" => "Name",
            "email" => "email@email.com",
            "documents" => [
              %{
                "path" => "test/utils/test64.txt",
                "tabs" => %{
                  "dateSignedTabs" => [
                    %{
                      "xPosition" => "32",
                      "yPosition" => "75",
                      "pageNumber" => "1"
                    },
                    %{
                      "xPosition" => "62",
                      "yPosition" => "10",
                      "pageNumber" => "1"
                    }
                  ],
                  "fullNameTabs" => [
                    %{
                      "xPosition" => "10",
                      "yPosition" => "100",
                      "pageNumber" => "1"
                    }
                  ],
                  "signHereTabs" => [
                    %{
                      "xPosition" => "25",
                      "yPosition" => "62",
                      "pageNumber" => "1"
                    }
                  ],
                  "initialHereTabs" => [
                    %{
                      "xPosition" => "20",
                      "yPosition" => "20",
                      "pageNumber" => "1"
                    }
                  ]
                }
              }
            ]
          }
        ]
      }
    ]
  end

  test "send_envelope/1 returns ok response", data do
    with_mocks([
      {
        DocusignEx.Api.Base,
        [],
        [
          post: fn _, _ ->
            {:ok,
             %HTTPoison.Response{body: %{"envelopeId" => "123"}, headers: [], status_code: 201}}
          end
        ]
      }
    ]) do
      assert Envelope.send_envelope(data.json) == {:ok, %{"envelopeId" => "123"}}
    end
  end

  test "send_envelope/1 returns error response", data do
    with_mocks([
      {
        DocusignEx.Api.Base,
        [],
        [
          post: fn _, _ ->
            {:ok,
             %HTTPoison.Response{
               body: %{
                 "errorCode" => "INVALID_EMAIL_ADDRESS_FOR_RECIPIENT",
                 "message" =>
                   "The email address for the recipient is invalid. The recipient Id follows."
               },
               headers: [],
               status_code: 400
             }}
          end
        ]
      }
    ]) do
      assert Envelope.send_envelope(data.json) ==
               {:error,
                %{
                  "errorCode" => "INVALID_EMAIL_ADDRESS_FOR_RECIPIENT",
                  "message" =>
                    "The email address for the recipient is invalid. The recipient Id follows."
                }}
    end
  end

  test "update_envelope/2 updates the envelope status" do
    with_mocks([
      {
        DocusignEx.Api.Base,
        [],
        [
          put: fn _, _ ->
            {:ok,
             %HTTPoison.Response{
               body: %{
                 "errorCode" => "",
                 "message" => "SUCCESS"
               },
               headers: [],
               status_code: 200
             }}
          end
        ]
      }
    ]) do
      assert Envelope.update_envelope("SOME-UID", %{
               "status" => "voided",
               "voidedReason" => "The reason for voiding the envelope"
             }) == {:ok, %{"errorCode" => "", "message" => "SUCCESS"}}
    end
  end

  test "update_envelope/2 returns docusign error code fro 400 status code" do
    docusign_error_code = "ENVELOPE_CANNOT_VOID_INVALID_STATE"
    docusign_error_message = "Only envelopes in the 'Sent' or 'Delivered' states may be voided."

    with_mocks([
      {
        DocusignEx.Api.Base,
        [],
        [
          put: fn _, _ ->
            {:ok,
             %HTTPoison.Response{
               body: %{
                 "errorCode" => docusign_error_code,
                 "message" => docusign_error_message
               },
               headers: [],
               status_code: 400
             }}
          end
        ]
      }
    ]) do
      assert Envelope.update_envelope("SOME-UID", %{
               "status" => "voided",
               "voidedReason" => "The reason for voiding the envelope"
             }) ==
               {:error, docusign_error_code}
    end
  end
end
