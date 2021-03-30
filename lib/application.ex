defmodule Authorizer.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Authorizer.DynamicSupervisor},
      Authorizer.Queue.Subscriber
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
