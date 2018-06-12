defmodule DocusignEx.Utils.FileUtils do
  @moduledoc """
  Funciones para formatear u obtener datos de archivos
  """

  @doc """
  Encodea a base64 el archivo
  """
  @spec encode64(String.t()) :: String.t()
  def encode64(file_path) do
    data = File.read!(file_path)
    :base64.encode(data)
  end

  @doc """
  Obtiene el nombre del archivo de un path
  """
  @spec get_filename(String.t()) :: String.t()
  def get_filename(file_path) do
    case Regex.run(~r/\/([^\/]+)$/, file_path) do
      [_, file] ->
        file

      _ ->
        file_path
    end
  end

  @doc """
  Obtiene la extensión del archivo de un path
  """
  @spec get_extension(String.t()) :: String.t()
  def get_extension(file_path) do
    case Regex.run(~r/\/[^\/]+\.(.+)$/, file_path) do
      [_, extension] ->
        extension

      _ ->
        file_path
    end
  end
end
