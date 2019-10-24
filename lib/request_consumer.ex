defmodule GenHttp.RequestConsumer do
  use GenStage

  def start_link({_host_name, _port, producer, _pool_size} = args) do
    GenStage.start_link(__MODULE__, producer, args)
  end

  def init({host_name, port, producer, pool_size}) do
    host_name = Atom.to_string(host_name)
    {:ok, conn} = Mint.HTTP.connect(:http, host_name, port)

    {:consumer, %{conn: conn, host_name: host_name, port: port},
     subscribe_to: [{producer, max_demand: pool_size}]}
  end

  def handle_events([request | _], _from, %{conn: conn} = state) do
    {:ok, conn, _} = Mint.HTTP.request(conn, "GET", "/api/test", [], "")
    state = Map.put(state, :conn, conn)
    {:ok, conn, responses} = await_responses(state)
    send(request.respond_to, responses)

    {:noreply, [], Map.put(state, :conn, conn)}
  end

  defp await_responses(%{conn: conn} = state) do
    receive do
      {:"$gen_consumer", from, events} ->
        handle_events(events, from, state)
        await_responses(state)

      message ->
        case Mint.HTTP.stream(conn, message) do
          :unknown ->
            IO.puts("unkown message: #{inspect(message)}")
            handle_info(message, state)
            await_responses(state)

          {:ok, _conn, responses} = result ->
            # IO.puts("kown message: #{inspect(message)}")
            # IO.puts("responses: #{inspect(responses)}")
            result
            #            IO.puts("handled message #{inspect(message)}")
            #
            #            if request.number > 100 do
            #              IO.puts("sending response #{request.number}")
            #            end
            #
        end
    end
  end

  def handle_info({:tcp_closed, _}, %{host_name: host_name, port: port} = state) do
    {:ok, conn} = Mint.HTTP.connect(:http, host_name, port)
    {:noreply, [], Map.put(state, :conn, conn)}
  end

  #  def handle_info(message, state) do
  #    IO.puts("generic handle_info: #{inspect(message)}")
  #    {:noreply, [], state}
  #  end
end
