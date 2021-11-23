defmodule DocusignEx.EnvelopeTest do
  use ExUnit.Case

  import Mock
  alias DocusignEx.Envelope
  alias DocusignEx.Auth.Config

  setup do
    [
      auth: Config.new("user", "pwd", "key") |> Config.set_base_url("https://test.resuelve.test"),
      envelope: %Envelope{
        email_subject: "Test",
        webhook_url: "localhost",
        signers: [
          %{
            name: "Name",
            email: "email@email.com",
            tabs: [
              %{key: "signHereTabs", x_offset: 10, y_offset: 100, string: "SIGN_HERE"}
            ]
          }
        ],
        documents: [
          %{filename: "test.txt", content: "text"}
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
             %Mojito.Response{body: Jason.encode!(%{"envelopeId" => "123"}), status_code: 201}}
          end
        ]
      }
    ]) do
      assert Envelope.send_envelope(data.auth, data.envelope) == {:ok, %{"envelopeId" => "123"}}
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
      assert Envelope.send_envelope(data.auth, data.envelope) ==
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
