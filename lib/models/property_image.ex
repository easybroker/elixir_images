defmodule Images.PropertyImage do
  use Ecto.Model

  schema "property_images" do
    field :property_id, :integer
    field :file, :string
    field :position, :integer
  end

  def main_query do
    from i in Images.PropertyImage,
      select: i
  end

  def all do
    Images.Repo.all main_query
  end
end
