# DocusignEx

> A little wrapper for the DocusignEx 2.1 API

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `docusign_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:docusign_ex, "~> 2.0.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/docusign_ex](https://hexdocs.pm/docusign_ex).


## Usage

### Auth

From version 2.0.0 now you need to create an Auth config to use all functionality.
This helps standarize the way auth is used and also it possibilitate the use of different users, something that wasn't possible in the previous interation.

In the `DocusignEx.Auth` module you can use both `config/1` and `config/3 `to get a `DocusignEx.Auth.Config`struct.

``` elixir
iex> DocusignEx.Auth.config("test_user", "test_pwd", "test_integration_key")
%DocusignEx.Auth.Config{
  username: "test_user",
  password: "test_password",
  integrator_key: "test_integrator_key",
  base_url: nil
}
```

The `base_url`will be filled when you login using `DocusignEx.Auth.login/1`.

You only need to login once because this login action will only retrieve your base user URL and credentials will be sent with every request.

> Yes, we should be using oAuth, maybe in the future we´ll update this

### Error Managment
All API errors will come in the way of a map:

``` elixir
%{error: "", description: ""}
```


### Envelopes

All envelope related functionality it´s in the `DocusignEx.Envelope`module. You can do the next actions:
- Sending an envelope
- Retrieve an envelope data
- Resending an envelope
- Updating an envelope
- Retrieve the envelope documents
- Download an specific document

#### Sending

``` elixir
iex> DocusignEx.Envelope.send_envelope(%AuthConfig{}, %{"some" => "envelope_data"})
{:ok,
  %{
    "envelopeId" => "5aadc814-53be-4a03-8590-6cf381faa163",
    "status" => "sent",
    "statusDateTime" => "2017-07-17T17:53:51.0370000Z",
    "uri" => "/envelopes/5aadc814-53be-4a03-8590-6cf381faa163"
  }
}
```

> We´ll update this when an envelope struct is written to manage the data required to send an envelope instead of just using a map

### Retrieve an envelope data

``` elixir
iex> DocusignEx.Envelope.get_envelope(%AuthConfig{}, "some_envelope_uid")
{:ok, %{...}}
```

#### Resend envelope

This sends again the same envelope to the same signers.

> In the future this could be updated to accept different signers from the original
