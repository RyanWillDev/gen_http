defmodule GenHttp.RequestConsumerProducer do
  use GenStage

  def start_link({name, _selector_fn} = args) do
    GenStage.start_link(__MODULE__, args, name: name)
  end

  def init({name, selector_fn}) do
    {:producer_consumer, name, subscribe_to: [{GenHttp.RequestProducer, [selector: selector_fn]}]}
  end

  def handle_events(events, _from, name) do
    {:noreply, events, name}
  end
end
