defmodule Images do
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Images.Repo, []),
      worker(Task, [fn -> Images.run end])
    ]

    opts = [strategy: :one_for_one, name: Images.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def run do
    Enum.each Images.PropertyImage.all, fn(i) -> IO.puts i.file end
  end
end
