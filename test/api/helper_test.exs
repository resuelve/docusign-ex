defmodule DocusignEx.Api.HelperTest do
  use ExUnit.Case

  alias DocusignEx.Api.Helper

  test "build_custom_auth_header/3 render a correct header value" do
    template = "{\"Username\":\"~s\",\"Password\":\"~s\",\"IntegratorKey\":\"~s\"}"
    username = "some-username"
    password = "some-password"
    integrator_key = "some-key"

    expected_value =
      template
      |> :io_lib.format([username, password, integrator_key])
      |> List.to_string()

    assert {"X-DocuSign-Authentication", expected_value} ==
             Helper.build_custom_auth_header(username, password, integrator_key)
  end
end
