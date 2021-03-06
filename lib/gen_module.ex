defmodule Mix.Tasks.Curl2httpoison.Gen do

  defmodule Module do
    use Mix.Task
    @doc false
    def run([inputfile, outputfile | t]) do
      Curl2httpoison.gen_file(inputfile, outputfile, t == ["--force"])
    end
  end

  defmodule Line do
    use Mix.Task
    @doc false
    def run(args) do
      out = args
      |> String.join(" ")
      |> Curl2httpoison.parse_curl
      |> Curl2httpoison.produce_code
      Mix.shell.info out
    end
  end
end
