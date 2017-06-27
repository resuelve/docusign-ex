defmodule DocusignEx.Api.Envelope do

  alias DocusignEx.Api.Base
  alias HTTPoison.Response
  alias HTTPoison.Error

  def send_envelope(data) do
    Base.post("/envelopes", data)
  end

  def create_template(data) do
    Base.post("/templates", data)
  end
end
