defmodule Images do
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Images.Repo, []),
      supervisor(Task.Supervisor, [[name: Images.TaskSupervisor]])
    ]

    opts = [strategy: :one_for_one]
    supervisor = Supervisor.start_link(children, opts)
    run
    supervisor
  end

  def run do
    Enum.each Images.PropertyImage.all, fn(i) -> Task.Supervisor.start_child(Images.TaskSupervisor, fn -> Images.PropertyImage.process i end) end
  end
end
