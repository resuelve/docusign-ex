defmodule DocusignEx.Api.Auth do
  @moduledoc """
  Login with Docusign api
  """

  require Logger

  alias DocusignEx.Api.AuthBase
  alias HTTPoison.Response
  alias HTTPoison.Error

  def login() do
    response = AuthBase.get("/login_information?api_password=true")

    case response do
      {:ok, %Response{body: body}} ->
        base_url = get_base_url(body)
        Process.put("base_url", base_url)
        base_url
      {:error, %Error{reason: reason}} ->
        Logger.error(reason)
    end
  end

  def get_base_url(body) do
    [data] = Map.get(body, "loginAccounts")
    Map.get(data, "baseUrl")
  end
end
