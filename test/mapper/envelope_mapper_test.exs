defmodule DocusignEx.Mapper.EnvelopeMapperTest do
  use ExUnit.Case

  import DocusignEx.Mapper.EnvelopeMapper

  setup do
    [
      envelope: %{
        "documents" => [
          %{
            "documentBase64" => "MTIzNDU2Nzg5CmFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6Cg==",
            "documentId" => "1",
            "fileExtension" => "txt",
            "name" => "test64.txt"
          }
        ],
        "emailSubject" => "Test",
        "recipients" => %{
          "signers" => [
            %{
              "email" => "email@email.com",
              "name" => "Name",
              "recipientId" => 1,
              "routingOrder" => 1,
              "tabs" => %{
                "initialHereTabs" => [
                  %{
                    "documentId" => "1",
                    "recipientId" => "1",
                    "pageNumber" => "1",
                    "xPosition" => "20",
                    "yPosition" => "20"
                  }
                ],
                "dateSignedTabs" => [
                  %{
                    "documentId" => "1",
                    "recipientId" => "1",
                    "pageNumber" => "1",
                    "xPosition" => "32",
                    "yPosition" => "75"
                  },
                  %{
                    "documentId" => "1",
                    "recipientId" => "1",
                    "pageNumber" => "1",
                    "xPosition" => "62",
                    "yPosition" => "10"
                  }
                ],
                "fullNameTabs" => [
                  %{
                    "documentId" => "1",
                    "recipientId" => "1",
                    "pageNumber" => "1",
                    "xPosition" => "10",
                    "yPosition" => "100"
                  }
                ],
                "signHereTabs" => [
                  %{
                    "documentId" => "1",
                    "recipientId" => "1",
                    "pageNumber" => "1",
                    "xPosition" => "25",
                    "yPosition" => "62"
                  }
                ]
              }
            }
          ]
        },
        "status" => "sent",
        "eventNotification" => nil
      },
      json: %{
        "subject" => "Test",
        "signers" => [
          %{
            "name" => "Name",
            "email" => "email@email.com",
            "documents" => [
              %{
                "path" => "test/utils/test64.txt",
                "tabs" => %{
                  "dateSignedTabs" => [
                    %{
                      "xPosition" => "32",
                      "yPosition" => "75",
                      "pageNumber" => "1"
                    },
                    %{
                      "xPosition" => "62",
                      "yPosition" => "10",
                      "pageNumber" => "1"
                    }
                  ],
                  "fullNameTabs" => [
                    %{
                      "xPosition" => "10",
                      "yPosition" => "100",
                      "pageNumber" => "1"
                    }
                  ],
                  "signHereTabs" => [
                    %{
                      "xPosition" => "25",
                      "yPosition" => "62",
                      "pageNumber" => "1"
                    }
                  ],
                  "initialHereTabs" => [
                    %{
                      "xPosition" => "20",
                      "yPosition" => "20",
                      "pageNumber" => "1"
                    }
                  ]
                }
              }
            ]
          }
        ]
      }
    ]
  end

  test "Should map the data correctly to the Docusign format", data do
    assert map(data.json) == data.envelope
  end

  test "Should add subject to envelope map", data do
    assert add_subject(%{}, data.json) == %{"emailSubject" => "Test"}
  end

  test "Should add documents", data do
    assert add_documents(%{}, data.json) == %{
      "documents" => [
        %{
          "documentBase64" => "MTIzNDU2Nzg5CmFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6Cg==",
          "documentId" => "1",
          "fileExtension" => "txt",
          "name" => "test64.txt"
        }
      ]
    }
  end
end
