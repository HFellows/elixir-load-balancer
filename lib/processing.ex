## This mapper / reducer set takes the sum of a bunch of fibs of numbers.
defmodule mapper
  def initalize()
    receive do
      {:confirm?, pid} ->
        send (pid {:ready, self(), "Fib Mapper v1.0"})
      {:go, pid, a, b, filename} ->
        start(pid, a, b, filename)
    end
  end

  def fib(0) do 0 end
  def fib(1) do 1 end
  def fib(n) do fib(n-1) + fib(n-2) end

  def work(line) do
    fib(line)
  end

  def start(pid, a, b, filename) do
    IO.puts("Fib Mapper Running with a: #{a}, b: #{b}, and filename: #{filename}")

    fileStream = File.stream!(filename)

    results = Enum.drop(fileStream, a-1)
    |> Enum.take((b + 1 - a))
    |> Enum.map(&String.to_integer(String.strip(&1)))
    |> Enum.map(&work(&1))

    send(pid, {:result, results})
    loopy()
  end

 def loopy() do
   receive do

     {:go, pid, a, b, filename} -> start(pid, a, b, filename)

     # TODO: Add option to kill mapper.

   end
 end


end

# Fix this thing's go.
defmodule reducer
  def initalize()
    receive do
      {:confirm?, pid} ->
        send (pid {:ready, self(), "Fib Reducer v1.0"})
      {:go, pid, work} ->
        start(pid, work)
      end
    end

  def start(pid, work)
    result = Enum.map(work, (&(&1 + &2)))

    send(pid {:result, result})
    loopy()
  end

  def loopy() do
    receive do
      {:go, pid, work} -> start(pid, work)

      #TODO: add option to kill mapper
    end
  end


end
