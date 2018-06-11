defmodule DocusignEx do
  @moduledoc """
  Provides access interfaces for the Docusign API.
  """

  use Application

  @doc """
  Start application
  """
  def start(_type, _args) do
    if Application.get_env(:docusign_ex, :oauth, nil) do
      IO.puts(:stderr, "Use :docusign_ex in config.exs.")
    end

    DocusignEx.Supervisor.start_link()
  end
end
