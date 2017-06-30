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
    envelope = %{status: "sent"}

    envelope
    |> add_subject(envelope_data)
    |> add_documents(envelope_data)
    |> add_signers(envelope_data)
  end

  @doc """
  Mapea el subject al envelope
  """
  @spec add_subject(map, map) :: map
  def add_subject(envelope, data) do
    Map.put(
      envelope,
      :emailSubject,
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
          end
      )

    Map.put(envelope, :documents, documents)
  end

  @doc """
  Obtiene la lista de los documentos que se enviarán
  """
  @spec get_document_list(map) :: list
  def get_document_list(data) do
    data
    |> Map.get("signers")
    |> Enum.reduce([], fn (signer,acc) ->
      signer
      |> Map.get("documents")
      |> Enum.map(fn document ->
        Map.get(document, "path")
      end)
      |> Enum.into(acc)
      end
      )
    |> Enum.uniq
  end

  @doc """
  Extrae la información del documento a enviar
  """
  @spec extract_document_data(String.t, integer) :: map
  def extract_document_data(pdf_path, id) do
    %{
      documentBase64: FileUtils.encode64(pdf_path),
      documentId: Integer.to_string(id),
      fileExtension: FileUtils.get_extension(pdf_path),
      name: FileUtils.get_filename(pdf_path)
    }
  end

  @doc """
  Mapea los signers al envelope
  """
  @spec add_signers(map, map) :: map
  def add_signers(envelope, data) do
    envelope = Map.put(envelope, :recipients, %{})
    signers_list = Map.get(data, "signers", [])

    {signers, _} =
      Enum.map_reduce(signers_list, 1, fn signer, acc ->
        tabs =
          signer
          |> Map.get("documents")
          |> Enum.map(fn document ->
            id = get_document_id(data, Map.get(document, "path"))
            format_tabs(Map.get(document, "tabs"), id+1, acc)
            end
          )
          |> Enum.reduce(%{}, fn(tab, acc) ->
              Map.merge(acc, tab, fn _key, v1, v2 ->
                List.flatten([v1|v2])
                end
              )
              end
            )

        {
          %{
            email: Map.get(signer, "email"),
            name: Map.get(signer, "name"),
            recipientId: acc,
            routingOrder: acc,
            tabs: tabs
          },
          acc + 1
        } 
      end
      )

    put_in(envelope, [:recipients, :signers], signers)
  end

  @doc """
  Obtiene el ID (autoincremental) del documento a enviar. El ID se genera 
  en el orden de que los archivos hayan sido ingresados en el mapa
  """
  @spec get_document_id(map, map) :: integer
  def get_document_id(data, document) do
    id = Enum.find_index(get_document_list(data), &(&1 == document))
    !is_nil(id) && id || nil
  end

  @doc """
  Agrega a los tabs el recipientId y el documentId correspondientes
  """
  @spec format_tabs(list, integer, integer) :: map
  def format_tabs(nil, _, _), do: nil
  def format_tabs(tabs, document_id, recipient_id) do
    formatted_tabs = %{}

    date_signed_tabs =
      tabs
      |> Map.get("dateSignedTabs")
      |> add_recipient_document_id(document_id, recipient_id)

    full_name_tabs =
      tabs
      |> Map.get("fullNameTabs")
      |> add_recipient_document_id(document_id, recipient_id)

    sign_here_tabs =
      tabs
      |> Map.get("signHereTabs")
      |> add_recipient_document_id(document_id, recipient_id)


    formatted_tabs =
      !is_nil(date_signed_tabs) && 
      Map.put(formatted_tabs, :dateSignedTabs, date_signed_tabs) ||
      formatted_tabs
    
    formatted_tabs =
      !is_nil(full_name_tabs) &&
      Map.put(formatted_tabs, :fullNameTabs, full_name_tabs) ||
      formatted_tabs
    
    formatted_tabs =
      !is_nil(sign_here_tabs) &&
      Map.put(formatted_tabs, :signHereTabs, sign_here_tabs) ||
      formatted_tabs

    formatted_tabs
  end

  # Realiza el put a el recipientId y el documentId
  @spec add_recipient_document_id(list, integer, integer) :: list
  defp add_recipient_document_id(nil, _, _), do: nil
  defp add_recipient_document_id(tabs, document_id, recipient_id) do
    Enum.map(tabs, fn(tab) ->
      tab
      |> Map.put(:recipientId, Integer.to_string(recipient_id))
      |> Map.put(:documentId, Integer.to_string(document_id))
      end
    )
  end
end
