defmodule DocusignEx.Api.EnvelopeTest do
  use ExUnit.Case

  import Mock

  alias DocusignEx.Api.Envelope
  alias HTTPoison.Response
  alias HTTPoison
  alias DocusignEx.Api.Base

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
        Base,
        [],
        [
          put: fn _, _ ->
            {:ok,
             %Response{
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

  test "foo" do
    with_mocks [
      {
        Base,
        [],
        [
          put: fn _, _ ->
            {:ok,
             %Response{
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
    ] do
      assert Envelope.update_envelope("SOME-UID", %{
               "status" => "voided",
               "voidedReason" => "The reason for voiding the envelope"
             }) == {:ok, %{"errorCode" => "", "message" => "SUCCESS"}}
    end
  end
end
