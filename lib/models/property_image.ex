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
    s3_url(image) |> IO.puts
  end

  def s3_url(image) do
    ~s(https://s3.amazonaws.com/assets.stagingea.com/uploads/property_image/file/#{image.id}/#{image.file})
  end
end
