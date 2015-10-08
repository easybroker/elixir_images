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
      limit: 200
  end

  def all do
    Images.Repo.all main_query
  end

  def process(image) do
    medium   = image.file |> size_name(:medium) |> s3_url(image.id)
    response = medium |> HTTPotion.head

    unless response.status_code == 200 do
      IO.puts "#{image.id} - #{image.file} Start"
      generate_versions(image.file, image.id)
      IO.puts "#{image.id} - #{image.file} End"
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
    file        = download_original(filename, id)
    generate_medium(file, filename, id)
    generate_thumb(file, filename, id)
  end

  def download_original(filename, id) do
    file     = temp_filename(filename, id)
    ibrowse  = [save_response_to_file: String.to_char_list(file)]
    s3_url(filename, id) |> HTTPotion.get([ibrowse: ibrowse])
    file
  end

  def temp_filename(filename, id) do
    Path.join(System.tmp_dir, "#{Integer.to_string(id)}#{filename}")
  end

  def generate_medium(file, filename, id) do
    path = file_path(id)
    result = Path.join(path, size_name(filename, :medium))

    Mogrify.open(file)
      |> Mogrify.copy
      |> Mogrify.resize_to_fill("450x300")
      |> Mogrify.save(result)
    result
  end

  def generate_thumb(file, filename, id) do
    path = file_path(id)
    result = Path.join(path, size_name(filename, :thumb))

    Mogrify.open(file)
      |> Mogrify.copy
      |> Mogrify.resize_to_limit("200x200")
      |> Mogrify.save(result)
    result
  end

  def file_path(id) do
    path = "./file/#{id}"
    File.mkdir(path)
    path
  end
end
