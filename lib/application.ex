defmodule GenHttp.Application do
  use Application

  def start(_type, args) do
    opts = [strategy: :one_for_one]
    Supervisor.start_link([{GenHttp, args}], opts)
  end
end
