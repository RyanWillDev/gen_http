defmodule GenHttp.RequestSupervisor do
  use ConsumerSupervisor

  def start_link(_) do
    ConsumerSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    require Integer

    children = [
      %{
        id: GenHttp.RequestConsumer,
        start: {GenHttp.RequestConsumer, :start_link, []},
        restart: :transient
      }
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [
        {
          GenHttp.RequestProducer,
          [max_demand: 100]
          # selector: fn s ->
          #  String.split(s, " ")
          #  |> Enum.at(1)
          #  |> String.to_integer()
          #  |> (fn i -> if(type == [:odd], do: Integer.is_odd(i), else: Integer.is_even(i)) end).()
          # end
        }
      ]
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
