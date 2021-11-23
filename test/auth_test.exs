defmodule DocusignEx.AuthTest do
  use ExUnit.Case

  import Mock

  alias DocusignEx.Auth

  test "Should create an Auth Config" do
    username = "test"
    password = "secret"
    key = "key"

    assert %Auth.Config{username: ^username, password: ^password, integrator_key: ^key} =
             Auth.config(username, password, key)
  end

  test "Runs login" do
    auth_config = Auth.config("fake_user", "fake_pwd", "fake_key")

    assert auth_config.base_url == nil

    with_mock Mojito,
      get: fn _, _, _ ->
        body =
          Jason.encode!(%{
            "loginAccounts" => [
              %{
                "baseUrl" => ""
              }
            ]
          })

        {:ok, %{status_code: 200, body: body}}
      end do
      {:ok, login_config} = Auth.login(auth_config)
      assert login_config.base_url != nil
    end
  end
end
