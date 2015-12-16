
defmodule worker do
  case File.read("master.conf") do
    {:ok, body} -> parseMasterConf(body)
  end
end
    Code.eval(string)
    mapper.start()
    reducer.start()
  end

  defmodule mapper
    def initalize()
      receive do
        {:confirm?, pid} ->
          send (pid {:ready, self(), "Default"})
        {:go, a, b, filename} ->
          start(a, b, filename)
      end
    end

    def start(a, b, filename)
      IO.puts("The default mapper module hasn't been replaced.")
    end

  end

  defmodule reducer
    def initalize()
      receive do
        {:confirm?, pid} ->
          send (pid {:ready, self(), "Default"})
          {:go, a, b, filename} ->
            start(a, b, filename)
          end
        end

    def start(a, b, filename)
      IO.puts("The default reducer module hasn't been replaced.")
    end
  end
end
