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

  def paged(offset, limit) do
    from i in main_query,
      limit: ^limit,
      offset: ^offset
  end

  def process(image) do
    medium   = image.file |> size_name(:small) |> s3_url(image.id)
    response = medium |> HTTPotion.head

    unless response.status_code == 200 do
      IO.puts "#{image.id} - #{image.file} Start"
      generate_versions(image.file, image.id)
      IO.puts "#{image.id} - #{image.file} End"
    else
      IO.puts "#{image.id} - #{image.file} OK"
    end
  end

  def s3_url(file, id) do
    "#{s3_path}/#{id}/#{file}"
  end

  def s3_path do
    "https://s3.amazonaws.com/#{Application.get_env(:images, :s3_bucket)}/uploads/property_image/file"
  end

  def size_name(name, size) do
    "#{size}_#{name}"
  end

  def generate_versions(filename, id) do
    file        = download_original(filename, id)
    generate_medium(file, filename, id)
    generate_small(file, filename, id)
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
    result = Path.join(System.tmp_dir, size_name(filename, :medium))

    Mogrify.open(file)
      |> Mogrify.copy
      |> Mogrify.resize_to_fill("450x300")
      |> Mogrify.save(result)

    s3_name = s3_full_name(id, filename, :medium)
    {status, _} = System.cmd("s3cmd", ["-P", "put", result, s3_name])
    IO.puts status
  end

  def generate_small(file, filename, id) do
    path = file_path(id)
    result = Path.join(System.tmp_dir, size_name(filename, :small))

    Mogrify.open(file)
      |> Mogrify.copy
      |> Mogrify.resize_to_limit("150x100")
      |> Mogrify.save(result)

    s3_name = s3_full_name(id, filename, :small)
    {status, _} = System.cmd("s3cmd", ["-P", "put", result, s3_name])
    IO.puts status
  end

  def file_path(id) do
    path = "./file/#{id}"
    File.mkdir(path)
    path
  end

  def s3_full_name(id, filename, size) do
    "#{s3_dest}/#{id}/#{size_name(filename, size)}"
  end

  def s3_dest do
    "s3://#{Application.get_env(:images, :s3_bucket)}/uploads/property_image/file"
  end
end
