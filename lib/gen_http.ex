defmodule GenHttp do
  @moduledoc """
  Documentation for GenHttp.
  """
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(args) do
    GenStage.start_link(GenHttp.RequestProducer, :ok, name: GenHttp.RequestProducer)
    # GenServer.start_link(GenHttp.Monitor, :ok, name: GenHttp.Monitor)
    GenHttp.Monitor.start_link(:ok)

    start_producer_consumers(args)
    start_consumers(args)
    #
    # Process.send_after(self(), :start_consumers, 4000)

    {:ok, args}
  end

  # def handle_info(:start_consumers, state) do
  #  IO.puts("starting consumers #{inspect(state)}")
  #  start_consumers(state)
  #  {:noreply, state}
  # end
  #
  #

  def request(request) do
    request = Map.put(request, :respond_to, self())

    GenStage.call(GenHttp.RequestProducer, {:request, request})
  end

  def handle_response(:ok) do
    receive do
      m ->
        GenHttp.Monitor.add_success()
        # after
        #   5000 ->
        #     GenHttp.Monitor.add_error()
    end
  end

  def handle_response(_) do
    IO.puts("error occurred")
  end

  def send_requests(num) do
    require Integer

    Enum.each(0..num, fn x ->
      Task.start(fn ->
        request(%{host: "localhost", number: x}) |> handle_response()
      end)
    end)

    #    Enum.each(1..num, fn
    #      x when Integer.is_even(x) ->
    #        Task.start(fn ->
    #          Process.sleep(Enum.random(200..15000))
    #          # IO.puts("sending req #{x}")
    #          request(%{host: "example.com", number: x}) |> handle_response()
    #        end)
    #
    #      x ->
    #        Task.start(fn ->
    #          Process.sleep(Enum.random(200..15000))
    #          # IO.puts("sending req #{x}")
    #          request(%{host: "anotherhost.org", number: x}) |> handle_response()
    #        end)
    #    end)
  end

  defp start_producer_consumers(args) do
    Keyword.get(args, :hosts, [])
    |> Enum.map(fn {host_name, _opts} ->
      name = [host_name, "_", "consumer_producer"] |> Enum.join() |> String.to_atom()

      {name, fn %{host: host} -> host == Atom.to_string(host_name) end}
    end)
    |> Enum.each(fn {name, _} = args ->
      {:ok, _} = GenStage.start_link(GenHttp.RequestConsumerProducer, args, name: name)
    end)
  end

  defp start_consumers(args) do
    Keyword.get(args, :hosts, [])
    |> Enum.map(fn {host_name, opts} ->
      name = [host_name, "_", "consumer_producer"] |> Enum.join() |> String.to_atom()
      pool_size = Keyword.get(opts, :pool)
      port = Keyword.get(opts, :port)
      {host_name, port, name, pool_size}
    end)
    |> Enum.each(fn {host_name, port, name, pool_size} = args ->
      Enum.each(1..pool_size, fn _ ->
        GenStage.start_link(GenHttp.RequestConsumer, args)
      end)
    end)
  end
end
