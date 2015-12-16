## This mapper / reducer set takes the sum of a bunch of fibs of numbers.
defmodule mapper
  def initalize()
    receive do
      {:confirm?, pid} ->
        send (pid {:ready, self(), "Fib Mapper v1.0"})
      {:go, a, b, filename} ->
        start(a, b, filename)
    end
  end

  def fib(0) do 0 end
  def fib(1) do 1 end
  def fib(n) do fib(n-1) + fib(n-2) end

  def work(line) do
    fib(line)
  end

  def start(a, b, filename) do
    IO.puts("Fib Mapper Running with a: #{a}, b: #{b}, and filename: #{filename}")

    fileStream = File.stream!(filename)

    results = Enum.map(Enum.take(Enum.drop(a-1), (b + 1 - a)), &work(&1))

    ## Send results to worker, from there they go to a reducer
  end

end

# Fix this thing's go.
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
