defmodule GenHttp.Monitor do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{error: 0, success: 0}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def add_error do
    GenServer.cast(__MODULE__, {:add, :error})
  end

  def add_success do
    GenServer.cast(__MODULE__, {:add, :success})
  end

  def results do
    GenServer.call(__MODULE__, :results)
  end

  def reset do
    GenServer.call(__MODULE__, :reset)
  end

  def handle_call(:results, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:reset, _from, state) do
    {:reply, state, %{error: 0, success: 0}}
  end

  def handle_cast({:add, type}, state) do
    state = Map.update!(state, type, &(&1 + 1))
    {:noreply, state}
  end
end
