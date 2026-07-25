require "open-uri"
require "mini_magick"
require "fileutils"

class ImageCreation
  class DownloadError < StandardError; end

  def initialize(caption)
    @caption = caption
  end

  DEFAULT_SIZE = 64

  def call
    image = download_image

    add_text_to(image)
    save_image(image)

    "/images/#{filename}"
  end

  private

  attr_reader :caption

  def download_image
    MiniMagick::Image.open(caption.url)
  rescue OpenURI::HTTPError, SocketError, Errno::ENOENT, URI::InvalidURIError => error
    raise DownloadError, "Could not download image from #{caption.url}: #{error.message}"
  rescue MiniMagick::Error, StandardError => error
    raise DownloadError, "Failed to process image from #{caption.url}: #{error.message}"
  end

  def add_text_to(image)
    image.combine_options do |config|
      config.font "Arial"
      config.pointsize(DEFAULT_SIZE)
      config.gravity "Center"
      config.fill "white"
      config.stroke "black"
      config.strokewidth 2
      config.annotate "+0+20", caption.text
    end
  end

  def save_image(image)
    FileUtils.mkdir_p(output_directory) unless Dir.exist?(output_directory)
    image.write(output_directory.join(filename).to_s)
  rescue StandardError => error
    raise DownloadError, "Failed to save image: #{error.message}"
  end

  def output_directory
    Rails.root.join("public", "images")
  end

  def filename
    "#{caption.unique_name}#{file_extension}"
  end

  def file_extension
    extension = File.extname(URI.parse(caption.url).path).downcase
    extension.present? ? extension : ".jpg"
  rescue URI::InvalidURIError
    ".jpg"
  end
end
