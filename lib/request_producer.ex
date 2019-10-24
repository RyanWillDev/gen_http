defmodule GenHttp.RequestProducer do
  use GenStage

  def start_link(_) do
    GenStage.start_link(GenHttp.RequestProducer, :ok, name: __MODULE__)
  end

  def init(_) do
    {:producer, {:queue.new(), 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_call({:request, request}, from, {queue, demand}) do
    queue = :queue.in({from, request}, queue)
    dispatch_requests(queue, demand, [])
  end

  def handle_demand(incoming_demand, {queue, demand}) do
    dispatch_requests(queue, incoming_demand + demand, [])
  end

  defp dispatch_requests(queue, 0, events) do
    {:noreply, Enum.reverse(events), {queue, 0}}
  end

  defp dispatch_requests(queue, demand, requests) do
    case :queue.out(queue) do
      {{:value, {from, request}}, queue} ->
        # Respond to call from sync_notify
        GenStage.reply(from, :ok)
        dispatch_requests(queue, demand - 1, [request | requests])

      {:empty, queue} ->
        {:noreply, Enum.reverse(requests), {queue, demand}}
    end
  end
end
