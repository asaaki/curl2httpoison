defmodule Curl2httpoisonTest do
  use ExUnit.Case

  doctest Curl2httpoison

  @url "http://google.pl"
  @header1 "Accept:application/json"
  @header2 "Content-Type:application/json"
  @data "{username: 'user@example.com', password: 'thepassword'}"

  @curl1 """
  curl -X POST --header "#{@header1}" --header "#{@header2}" #{@url} -d "#{@data}"
  """
  @correct_response1 """
  request(:post, "#{@url}", "#{@data}", ["#{@header1}", "#{@header2}"], [])
  """

  @curl2 """
  curl -X GET --header "#{@header1}" --header "#{@header2}" #{@url}
  """
  @correct_response2 """
  request(:get, "#{@url}", "", ["#{@header1}", "#{@header2}"], [])
  """

  test "parse curl" do
    code = (@curl1 |> String.strip)
    |> Curl2httpoison.parse_curl
    |> Curl2httpoison.produce_code
    assert code == @correct_response1
  end

  test "defaults data" do
    code = (@curl2 |> String.strip)
    |> Curl2httpoison.parse_curl
    |> Curl2httpoison.produce_code
    assert code == @correct_response2
  end

  test "finds common root" do
   assert Curl2httpoison.common_root([
      "aaaa",
      "aabb",
      "aacc",
      "aaae"
    ]) == "aa"
  end

  test "makes a whole file" do
    out = Curl2httpoison.gen([name: @curl1], "SomeModule")
    assert out == """
    defmodule SomeModule do
      use HTTPoison.Base

      @endpoint ""

      def process_url(url), do: endpoint <> url

      def name() do
        #{@correct_response1 |> String.strip()}
      end
    end
    """
  end

  test "Works on files too" do
    Curl2httpoison.gen_file("test/dummydata.ex", "test/dummymodule.ex")
    assert File.exists?("test/dummymodule.ex")
    IO.puts File.read! "test/dummymodule.ex"
    File.rm!("test/dummymodule.ex")
  end
end
