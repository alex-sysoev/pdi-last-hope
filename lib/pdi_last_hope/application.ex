defmodule PdiLastHope.Application do
  use Application

  def start(_type, _args) do
    children = [
      {PdiLastHope.Reserver, []}
    ]

    opts = [strategy: :one_for_one, name: PdiLastHope.Supervisor]
    Supervisor.start_link(children, opts)
  end
end