defmodule ClusterNode do
  defstruct hostname: "cthulhu", cpus: -1, ram: -1
end

defmodule ParseCsv do
  def parse(filename) do
    case(File.open(filename)) do
      {:ok, file} -> keepParsing(file)
      {:error, err} -> IO.puts("Error reading file: " + err)
    end
  end

  def keepParsing(file) do
    headers = IO.read(file, :line) |> parse_headers
    Enum.map IO.stream(file, :line), &(parse_configs(&1, headers))
  end

  defp parse_headers(line) do
    line
    |> split_columns
    |> Enum.map(&String.to_atom/1)
  end

  defp parse_configs(line, headers) do
    config = line
      |> split_columns
      |> convert_types

    Enum.zip headers, config
  end

  defp split_columns(line) do
    line
    |> String.strip
    |> String.split(",")
  end

  defp convert_types([host, cpus, ram]) do
    [
      String.to_atom(host),
      String.to_integer(cpus),
      String.to_integer(ram)
    ]
  end
end


defmodule ElixirLoadBalancer do

def init() do
  case File.open("master.conf") do
    {:ok, file} ->
      config = ParseCsv.parse("master.conf")
      main(config)
    {:error, err} -> IO.puts("Error reading master.conf: " + err)
  end
end

defp printHost(host) do
  #IO.inspect(host)
  IO.inspect("#{Keyword.get(host, :host, 0)}           #{Keyword.get(host, :cpu, 0)}       #{Keyword.get(host, :ram, 0)}")
end

def main(config) do
  IO.puts("Hostname:      Cpus:      Ram(GB):")
  config |> Enum.map(&printHost(&1))
end


end
