require IEx

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
    #image.file |> s3_url(image.id) |> IO.puts
    medium = image.file |> size_name(:medium) |> s3_url(image.id)
    #thumb  =image.file |> size_name(:thumb) |> s3_url(image.id)

    response = medium |> HTTPotion.head

    unless response.status_code == 200 do
      generate_versions(image.file, image.id)
    end
  end

  def s3_url(file, id) do
    "#{s3_path}/#{id}/#{file}"
  end

  def s3_path do
    "https://s3.amazonaws.com/assets.stagingea.com/uploads/property_image/file"
  end

  def size_name(name, size) do
    "#{size}_#{name}"
  end

  def generate_versions(filename, id) do
    file = download_original(filename, id)
    medium_file = generate_medium(file, filename)
  end

  def download_original(filename, id) do
    file     = temp_filename(filename, id)
    ibrowse  = [save_response_to_file: String.to_char_list(file)]
    response = s3_url(filename, id) |> HTTPotion.get([ibrowse: ibrowse])
    file
  end

  def temp_filename(filename, id) do
    Path.join(System.tmp_dir, "#{Integer.to_string(id)}#{filename}")
  end

  def generate_medium(file, filename) do
    result = Path.join(System.tmp_dir, size_name(filename, :medium))
    Mogrify.open(file)
    |> Mogrify.copy
    |> Mogrify.resize_to_fill("450x300")
    |> Mogrify.save(result)
    result
  end
end
