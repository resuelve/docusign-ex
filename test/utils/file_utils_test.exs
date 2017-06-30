defmodule DocusignEx.Utils.FileUtilsTest do
  use ExUnit.Case

  import DocusignEx.Utils.FileUtils

  test "Should encode the file to base64" do
    assert encode64("test/utils/test64.txt") == "MTIzNDU2Nzg5CmFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6Cg=="
  end

  test "Should return the filename from a path" do
    assert get_filename("/folder/") == "/folder/"
    assert get_filename("/folder/test.pdf") == "test.pdf"
  end

  test "Should return the file extension from a path" do
    assert get_extension("/folder/") == "/folder/"
    assert get_extension("/folder/test.pdf") == "pdf"
  end
end
