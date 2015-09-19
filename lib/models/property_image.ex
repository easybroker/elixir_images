defmodule Images.PropertyImage do
  use Ecto.Model

  schema "property_images" do
    field :property_id, :integer
    field :file, :string
    field :position, :integer
  end

  def main_query do
    from i in Images.PropertyImage,
      select: i,
      limit: 10
  end

  def all do
    Images.Repo.all main_query
  end

  def process(image) do
    image.file |> s3_url(image.id) |> IO.puts
    image.file |> size_name(:medium) |> s3_url(image.id) |> IO.puts
    image.file |> size_name(:thumb) |> s3_url(image.id) |> IO.puts
  end

  def s3_url(file, id) do
    ~s(https://s3.amazonaws.com/assets.stagingea.com/uploads/property_image/file/#{id}/#{file})
  end

  def size_name(name, size) do
    ~s(#{size}_#{name})
  end
end
