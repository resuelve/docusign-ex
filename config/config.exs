use Mix.Config

config :docusign_ex,
  username: System.get_env("DOCUSIGN_USER"),
  password: System.get_env("DOCUSIGN_PWD"),
  integrator_key: System.get_env("DOCUSIGN_KEY"),
  host: System.get_env("DOCUSIGN_HOST")
