defmodule Images.PropertyImageWorker do
  use GenServer

  def start_link([]) do
    :gen_server.start_link(__MODULE__, [], [])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(image, from, state) do
    result = Images.PropertyImage.process(image)
    {:reply, [result], state}
  end
end
