defmodule DocusignEx.Api.Envelope do

  alias DocusignEx.Api.Base
  alias HTTPoison.Response
  alias HTTPoison.Error
  alias DocusignEx.Mapper.EnvelopeMapper

  def send_envelope(envelope_data) do
    envelope = EnvelopeMapper.map(envelope_data)
    Base.post("/envelopes", envelope)
  end

  def create_template(data) do
    Base.post("/templates", data)
  end
end
