defmodule DocusignEx.Mapper.EnvelopeMapper do
  @moduledoc """
  Mapper para Envelopes de Docusign
  """

  alias DocusignEx.Utils.FileUtils

  @doc """
  Mapea la información del envelope al formato que pide Docusign
  """
  @spec map(map) :: map
  def map(envelope_data) do
    envelope = %{"status" => "sent"}

    envelope
    |> add_subject(envelope_data)
    |> add_documents(envelope_data)
    |> add_signers(envelope_data)
    |> add_webhook(envelope_data)
    |> add_reply_to(envelope_data)
    |> add_email_body(envelope_data)
    |> add_carbon_copies(envelope_data)
  end

  @doc """
  Mapea el subject al envelope
  """
  @spec add_subject(map, map) :: map
  def add_subject(envelope, data) do
    Map.put(
      envelope,
      "emailSubject",
      Map.get(data, "subject", "")
    )
  end

  @doc """
  Mapea los documentos al envelope
  """
  @spec add_documents(map, map) :: map
  def add_documents(envelope, data) do
    document_list = get_document_list(data)

    {documents, _} =
      Enum.map_reduce(document_list, 1, fn pdf_path, acc ->
        {extract_document_data(pdf_path, acc), acc + 1}
      end)

    Map.put(envelope, "documents", documents)
  end

  @doc """
  Obtiene la lista de los documentos que se enviarán
  """
  @spec get_document_list(map) :: list
  def get_document_list(data) do
    data
    |> Map.get("signers")
    |> Enum.reduce([], fn signer, acc ->
      signer
      |> Map.get("documents")
      |> Enum.map(fn document ->
        Map.get(document, "path")
      end)
      |> Enum.into(acc)
    end)
    |> Enum.uniq()
  end

  @doc """
  Extrae la información del documento a enviar
  """
  @spec extract_document_data(String.t(), integer) :: map
  def extract_document_data(pdf_path, id) do
    %{
      "documentBase64" => FileUtils.encode64(pdf_path),
      "documentId" => Integer.to_string(id),
      "fileExtension" => FileUtils.get_extension(pdf_path),
      "name" => FileUtils.get_filename(pdf_path)
    }
  end

  @doc """
  Mapea los signers al envelope
  """
  @spec add_signers(map, map) :: map
  def add_signers(envelope, data) do
    envelope = Map.put(envelope, "recipients", %{})
    signers_list = Map.get(data, "signers", [])

    {signers, _} =
      Enum.map_reduce(signers_list, 1, fn signer, acc ->
        tabs =
          signer
          |> Map.get("documents")
          |> Enum.map(fn document ->
            id = get_document_id(data, Map.get(document, "path"))
            add_tabs(Map.get(document, "tabs"), id + 1, acc)
          end)
          |> Enum.reduce(%{}, fn tab, acc ->
            Map.merge(acc, tab, fn _key, v1, v2 ->
              List.flatten([v1 | v2])
            end)
          end)

        {
          %{
            "email" => Map.get(signer, "email"),
            "name" => Map.get(signer, "name"),
            "recipientId" => acc,
            "routingOrder" => acc,
            "tabs" => tabs
          },
          acc + 1
        }
      end)

    put_in(envelope, ["recipients", "signers"], signers)
  end

  @doc """
  Obtiene el ID (autoincremental) del documento a enviar. El ID se genera
  en el orden de que los archivos hayan sido ingresados en el mapa
  """
  @spec get_document_id(map, map) :: integer
  def get_document_id(data, document) do
    Enum.find_index(get_document_list(data), &(&1 == document))
  end

  @doc """
  Agrega los tabs al envelope
  """
  @spec add_tabs(map, integer, integer) :: map
  def add_tabs(nil, _, _), do: nil

  def add_tabs(tabs, document_id, recipient_id) do
    tabs
    |> Map.keys()
    |> Enum.reduce(%{}, fn key, acc ->
      do_add_tabs(acc, tabs, document_id, recipient_id, key)
    end)
  end

  # Agrega los tabs a la lista
  @spec do_add_tabs(list, map, integer, integer, String.t()) :: map
  defp do_add_tabs(tabs, tabs_data, doc_id, recipient_id, tab_label) do
    tabs_to_add =
      tabs_data
      |> Map.get(tab_label)
      |> add_recipient_document_id(doc_id, recipient_id)

    (!is_nil(tabs_to_add) && Map.put(tabs, tab_label, tabs_to_add)) || tabs
  end

  # Agrega el recipientId y el documentId a cada Tab
  @spec add_recipient_document_id(list, integer, integer) :: list
  defp add_recipient_document_id(nil, _, _), do: nil

  defp add_recipient_document_id(tabs, document_id, recipient_id) do
    Enum.map(tabs, fn tab ->
      tab
      |> Map.put("recipientId", Integer.to_string(recipient_id))
      |> Map.put("documentId", Integer.to_string(document_id))
    end)
  end

  # Agrega los datos del webhook al envelope
  @spec add_webhook(map, map) :: map
  def add_webhook(envelope, data) do
    Map.put(envelope, "eventNotification", Map.get(data, "eventNotification"))
  end

  @doc """
  Mapea el valor que aparecerá en el campo reply_to del correo en el que
  se enviará el sobre
  """
  @spec add_reply_to(map, map) :: map
  def add_reply_to(envelope, data) do
    case Map.get(data, "reply_to") do
      nil ->
        envelope

      email ->
        Map.put(envelope, "emailSettings", %{
          "replyEmailAddressOverride" => email
        })
    end
  end

  @doc """
  Mapea el mensaje que se aparecerá en el cuerpo del correo en el que se
  enviará el sobre (opcional)
  """
  @spec add_email_body(map, map) :: map
  def add_email_body(envelope, data) do
    case Map.get(data, "email_body") do
      nil -> envelope
      email_body -> Map.put(envelope, "emailBlurb", email_body)
    end
  end

  @doc """
  Mapea los correos a los que se enviará copia carbón del sobre, si son
  proporcionados
  """
  @spec add_carbon_copies(map, map) :: map
  def add_carbon_copies(envelope, data) do
    case Map.get(data, "carbon_copies") do
      carbon_copies when is_list(carbon_copies) ->
        number_of_signers =
          envelope
          |> get_in(["recipients", "signers"])
          |> length()
          |> Kernel.+(1)

        cc =
          carbon_copies
          |> Enum.with_index()
          |> Enum.map(fn {%{email: email, name: name}, index} ->
            id = Integer.to_string(number_of_signers + index)

            %{
              "email" => carbon_copies,
              "name" => name,
              "recipientId" => id,
              "routingOrder" => id
            }
          end)

        put_in(envelope, ["recipients", "carbon_copies"], cc)

      _ ->
        envelope
    end
  end
end
