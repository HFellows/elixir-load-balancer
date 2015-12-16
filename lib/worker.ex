defmodule Worker do
  def intialize(master_pid) do
    case File.read("processing.ex") do
      {:ok, body} -> Code.eval(body)
      {:error, reason} -> IO.puts("worker read error: " + reason)
    end
    mapper_pid = spawn(Mapper)
    send(mapper_pid, {:confirm?, self()})
    reducer_pid = spawn(Reducer)
    send(reducer_pid, {:confirm?, self()})
    setup_loop(mapper_pid, false, reducer_pid, false, master_pid)
  end

 def setup_loop(mapper_pid, mapper_ready?, reducer_pid, reducer_ready?, master_pid) do
   if mapper_ready? && reducer_ready? do
     messaging_loop(mapper_pid, reducer_pid, master_pid)
   end
   receive do
     {:ready, src-pid, description} ->
        case description do
          "Default" ->
            IO.puts("Apparently, you just put a default module in the file. Congratulations.")
          desc -> IO.puts(desc)
        end
        case src-pid do
          ^mapper_pid ->
            IO.puts("Worker " + self() + "'s mapper is ready.")
            setup_loop(mapper_pid, true, reducer_pid, reducer_ready?, master_pid)

          ^reducer_pid ->
            IO.puts("Worker " + self() + "'s reducer is ready.")
            setup_loop(mapper_pid, mapper_ready?, reducer_pid, true, master_pid)

          _ ->
            IO.puts("A process that shouldn't be talking to this worker sent a message. (>_<)")
            IO.puts("Worker pid: " + self() + " Other pid: " + src-pid)
            setup_loop(mapper_pid, reducer_pid, master_pid)
        end
      # {other, src-pid  _ } ->
      #   send(src-pid, {:fail, self(), other})
      #   IO.puts("Bad message: " + other + " from: " + src-pid)
  end
 end

  def messaging_loop(mapper_pid, reducer_pid, master_pid) do
    receive do
      {:map, a, b, filename} ->
        send(mapper_pid, {:go, self(), a, b, filename})
      {:reduce, list_o_work} ->
        send(reducer_pid, {:go, self(), list_o_work})
      {:result, x} ->
        case x do
          x when is_list(x) -> send(reducer_pid, {:go, self(), x})
          x -> send(master_pid, {x, self()})
        end
    end
    messaging_loop(mapper_pid, reducer_pid, master_pid)
  end
end

## This mapper / reducer set takes the sum of a bunch of fibs of numbers.
defmodule mapper
  def initalize()
    receive do
      {:confirm?, pid} ->
        send (pid {:ready, self(), "Default"})
      {:go, pid, a, b, filename} ->
        start(pid, a, b, filename)
    end
  end

  def work(line) do
    #work here
  end

  def start(pid, a, b, filename) do
    fileStream = File.stream!(filename)

    # Assumes you want an integer from each line of the file,
    # calls work on each of those.
    results = Enum.drop(fileStream, a-1)
    |> Enum.take((b + 1 - a))
    |> Enum.map(&String.to_integer(String.strip(&1)))
    |> Enum.map(&work(&1))

    # Sends results back to the worker, begins waiting for more work.
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
        send (pid {:ready, self(), "Default"})
      {:go, pid, work} ->
        start(pid, work)
      end
    end

  def start(pid, work)
    # Assumes that work is a list of ints, and sums them.
    result = Enum.map(work, (&(&1 + &2)))

    # Sends the sum to the worker and begins waiting for more work.
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
