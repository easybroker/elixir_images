defmodule Images do
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Repo, [])
    ]

    opts = [strategy: :one_for_one, name: Images.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
