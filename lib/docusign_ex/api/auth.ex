defmodule DocusignEx.Api.Auth do
  @moduledoc """
  Login con el API de Docusign
  """

  require Logger

  alias DocusignEx.Api.AuthBase
  alias HTTPoison.Response
  alias HTTPoison.Error

  @doc """
  Login
  """
  @spec login :: String.t() | :ok
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

  @doc """
  Obtiene la url base para el acceso por API
  """
  @spec get_base_url(map) :: String.t()
  def get_base_url(%{"errorCode" => code, "message" => message}) do
    Logger.error("#{code}: #{message}")
    ""
  end

  def get_base_url(%{"loginAccounts" => accounts}) do
    accounts
    |> Enum.filter(fn account -> account["isDefault"] == "true" end)
    |> Enum.reduce("", fn account, _acc -> Map.get(account, "baseUrl") end)
  end
end
