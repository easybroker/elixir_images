defmodule Images do
  def start(_type, _args) do
    import Supervisor.Spec

    poolboy_config = [
      {:name, {:local, pool_name()}},
      {:worker_module, Images.PropertyImageWorker},
      {:size, 0},
      {:max_overflow, 5}
    ]

    children = [
      :poolboy.child_spec(pool_name(), poolboy_config, []),
      worker(Images.Repo, [])
    ]

    opts = [strategy: :one_for_one]
    supervisor = Supervisor.start_link(children, opts)
    enqueue
    supervisor
  end

  def enqueue do
    Enum.each Images.PropertyImage.all, fn(i) -> spawn(fn() -> pool_image(i) end) end
  end

  def pool_image(image) do
    :poolboy.transaction(
      pool_name(),
      fn(pid) -> :gen_server.call(pid, image) end,
      :infinity
    )
  end

  def pool_name do
    :property_images
  end
end
