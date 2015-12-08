defmodule node do
  defstruct hostname: "cthulhu", cpus: -1, ram: -1
end



defmodule ElixirLoadBalancer do

defp parseMasterConf(stuff) do
  IO.puts(stuff)
end


def main() do
  case File.read("master.conf") do
    {:ok, body} -> parseMasterConf(body)
    {:error, reason} -> IO.puts("master.conf read error: " + reason)
  end
end


end
