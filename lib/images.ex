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
    step = 10
    Images.PropertyImage.paged(0, step)
      |> Images.Repo.all
      |> enqueue_batch(0, step)
  end

  def enqueue_batch(batch, offset, step) when length(batch) == 0 do
    IO.puts "Done processing batches"
  end

  def enqueue_batch(batch, offset, step) do
    Enum.each batch, fn(i) -> spawn(fn() -> pool_image(i) end) end
    #Enum.each batch, fn(i) -> IO.puts(i.id) end

    offset = offset + step
    Images.PropertyImage.paged(offset, step)
      |> Images.Repo.all
      |> enqueue_batch(offset, step)
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
