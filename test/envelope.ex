defmodule DocusignEx.EnvelopeTest do
  use ExUnit.Case

  import Mock
  alias DocusignEx.Envelope
  alias DocusignEx.Auth.Config

  setup do
    [
      auth: Config.new("user", "pwd", "key") |> Config.set_base_url("https://test.resuelve.test"),
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
        Mojito,
        [],
        [
          post: fn _, _, _, _ ->
            {:ok,
             %Mojito.Response{body: Jason.encode!(%{"envelopeId" => "123"}), status_code: 200}}
          end
        ]
      }
    ]) do
      assert Envelope.send_envelope(data.auth, data.json) == {:ok, %{"envelopeId" => "123"}}
    end
  end

  test "send_envelope/1 returns error response", data do
    body =
      Jason.encode!(%{
        "errorCode" => "INVALID_EMAIL_ADDRESS_FOR_RECIPIENT",
        "message" => "The email address for the recipient is invalid. The recipient Id follows."
      })

    with_mocks([
      {
        Mojito,
        [],
        [
          post: fn _, _, _, _ ->
            {:ok, %Mojito.Response{body: body, status_code: 400}}
          end
        ]
      }
    ]) do
      assert Envelope.send_envelope(data.auth, data.json) ==
               {:error,
                %{
                  error: "INVALID_EMAIL_ADDRESS_FOR_RECIPIENT",
                  description:
                    "The email address for the recipient is invalid. The recipient Id follows."
                }}
    end
  end

  test "update_envelope/2 updates the envelope status", data do
    body =
      Jason.encode!(%{
        "errorCode" => "",
        "message" => "SUCCESS"
      })

    with_mocks([
      {
        Mojito,
        [],
        [
          put: fn _, _, _, _ ->
            {:ok, %Mojito.Response{body: body, status_code: 200}}
          end
        ]
      }
    ]) do
      assert Envelope.update_envelope(data.auth, "SOME-UID", %{
               "status" => "voided",
               "voidedReason" => "The reason for voiding the envelope"
             }) == {:ok, %{"errorCode" => "", "message" => "SUCCESS"}}
    end
  end

  test "update_envelope/2 returns docusign error code fro 400 status code", data do
    docusign_error_code = "ENVELOPE_CANNOT_VOID_INVALID_STATE"

    body =
      Jason.encode!(%{
        "errorCode" => docusign_error_code,
        "message" => "Only envelopes in the 'Sent' or 'Delivered' states may be voided."
      })

    with_mocks([
      {
        Mojito,
        [],
        [
          put: fn _, _, _, _ ->
            {:ok, %Mojito.Response{body: body, status_code: 400}}
          end
        ]
      }
    ]) do
      {:error, error} =
        Envelope.update_envelope(data.auth, "SOME-UID", %{
          "status" => "voided",
          "voidedReason" => "The reason for voiding the envelope"
        })

      assert error.error == docusign_error_code
    end
  end
end
