defmodule DocusignEx.Accounts do
  @moduledoc """
  Account and branding management
  """

  alias DocusignEx.Auth.Config
  alias DocusignEx.Request

  @doc """
  Lists the brands related to the account that is logged in on the Auth Config
  """
  @spec list_brands(Config.t()) :: Request.api_response()
  def list_brands(%Config{} = auth_config) do
    auth_config
    |> Request.new("brands")
    |> Request.get()
    |> Request.unwrap_response()
  end
end
