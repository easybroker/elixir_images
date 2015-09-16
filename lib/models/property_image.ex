defmodule PropertyImage do
  use Ecto.Model

  schema "property_images" do
    field :property_id, :integer
  end
end
