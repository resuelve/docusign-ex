defmodule DocusignEx.Request do
  @moduledoc """
  API Request Managment Module
  """

  alias DocusignEx.Auth.Config

  @default_headers [{"Content-Type", "application/json"}]

  @type t :: %{
          base_url: String.t(),
          endpoint: String.t(),
          headers: [tuple()],
          options: list(),
          query: map(),
          expected_status_code: integer(),
          response_type: String.t(),
          valid?: boolean(),
          status_code: integer(),
          response: any(),
          error: any()
        }

  @enforce_keys [:base_url, :endpoint]
  defstruct [
    :base_url,
    :endpoint,
    {:headers, @default_headers},
    {:options, []},
    {:query, %{}},
    {:expected_status_code, 200},
    {:response_type, "json"},
    {:valid?, false},
    :response,
    :status_code,
    :error
  ]

  @spec new(Config.t(), String.t()) :: __MODULE__.t()
  def new(%Config{} = config, endpoint) do
    new_request = %__MODULE__{
      base_url: config.base_url,
      endpoint: endpoint,
      query: %{}
    }

    set_auth_header(new_request, config)
  end

  @spec add_header(__MODULE__.t(), String.t(), String.t()) :: __MODULE__.t()
  def add_header(%__MODULE__{headers: headers} = request, key, value) do
    updated_headers = [{key, value} | headers]
    %{request | headers: updated_headers}
  end

  @spec set_auth_header(__MODULE__.t(), Config.t()) :: __MODULE__.t()
  def set_auth_header(%__MODULE__{} = request, %Config{} = config) do
    payload = %{
      "Username" => config.username,
      "Password" => config.password,
      "IntegratorKey" => config.integrator_key
    }

    add_header(request, "X-DocuSign-Authentication", Jason.encode!(payload))
  end

  defp add_base_url(%__MODULE__{} = request, base_url) do
    %{request | base_url: base_url}
  end

  @spec add_query_param(__MODULE__.t(), String.t(), String.t()) :: __MODULE__.t()
  def add_query_param(%__MODULE__{} = request, key, value) do
    Map.update(request, :query, %{}, fn query_params ->
      Map.put(query_params, key, value)
    end)
  end

  @spec set_expected_status_code(__MODULE__.t(), integer()) :: __MODULE__.t()
  def set_expected_status_code(%__MODULE__{} = request, status_code) do
    %{request | status_code: status_code}
  end

  @spec set_response_type(__MODULE__.t(), String.t()) :: __MODULE__.t()
  def set_response_type(%__MODULE__{} = request, response_type) do
    updated_request =
      case response_type do
        "json" -> add_header(request, "Content-Type", "application/json")
        _ -> request
      end

    %{updated_request | response_type: response_type}
  end

  @spec get(__MODULE__.t()) :: __MODULE__.t()
  def get(%__MODULE__{} = request) do
    url = Path.join(request.base_url, request.endpoint) <> "?" <> URI.encode_query(request.query)

    url
    |> Mojito.get(request.headers, request.options)
    |> parse_response(request)
  end

  @spec post(__MODULE__.t(), String.t()) :: __MODULE__.t()
  def post(%__MODULE__{} = request, payload) do
    url = Path.join(request.base_url, request.endpoint) <> "?" <> URI.encode_query(request.query)
    encoded_payload = Jason.encode!(payload)

    url
    |> Mojito.post(request.headers, encoded_payload, request.options)
    |> parse_response(request)
  end

  @spec put(__MODULE__.t(), String.t()) :: __MODULE__.t()
  def put(%__MODULE__{} = request, payload) do
    url = Path.join(request.base_url, request.endpoint) <> "?" <> URI.encode_query(request.query)
    encoded_payload = Jason.encode!(payload)

    url
    |> Mojito.put(request.headers, encoded_payload, request.options)
    |> parse_response(request)
  end

  @spec parse_response({atom(), map()}, String.t()) :: __MODULE__.t()
  defp parse_response(response, %__MODULE__{expected_status_code: expected_status_code} = request) do
    case response do
      {:ok, %{status_code: ^expected_status_code, body: body} = response} ->
        parsed_body = parse_body(response, request.response_type)
        %{request | valid?: true, status_code: 200, response: parsed_body}

      {:ok, %{status_code: status_code, body: body}} ->
        error = parse_response_error(body, request.response_type)
        %{request | valid?: false, status_code: status_code, error: error}

      {:error, %{message: message, reason: reason}} ->
        error = create_error(message, reason)
        %{request | valid?: false, status_code: nil, error: error}
    end
  end

  @spec parse_body(map(), String.t()) :: any()
  defp parse_body(%{body: body}, "json") do
    Jason.decode!(body)
  end

  defp parse_body(body, _request_type) do
    body
  end

  @spec parse_response_error(String.t(), String.t()) :: any()
  defp parse_response_error(body, "json") do
    json_error = Jason.decode!(body)
    error = Map.get(json_error, "errorCode")
    message = Map.get(json_error, "message")
    create_error(error, message)
  end

  defp parse_response_error(body, _request_type) do
    body
  end

  @spec create_error(String.t(), String.t()) :: map()
  def create_error(error, error_description) do
    %{error: error, description: error_description}
  end
end
