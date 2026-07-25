require "open-uri"
require "mini_magick"
require "fileutils"

class ImageCreation
  class DownloadError < StandardError; end

  def initialize(caption)
    @caption = caption
  end

  DEFAULT_SIZE = 36

  def call
    image = build_base_image

    save_image(image)

    "/images/#{filename}"
  end

  private

  attr_reader :caption

  def build_base_image
    
    case caption.type_field
    when "color"
      generate_color_background(caption.color)
    when "gradient"
      generate_gradient_background(caption.start_color, caption.end_color, caption.text)
    else
      download_image
    end
  end

  def download_image
    image =MiniMagick::Image.open(caption.url)
  rescue OpenURI::HTTPError, SocketError, Errno::ENOENT, URI::InvalidURIError => error
    raise DownloadError, "Could not download image from #{caption.url}: #{error.message}"
  rescue MiniMagick::Error, StandardError => error
    raise DownloadError, "Failed to process image from #{caption.url}: #{error.message}"
    
    add_text_to_image(image)
    image
  end

  def generate_gradient_background(start_color, end_color, text, output_path)
    # image = MiniMagick.convert do |convert|
    #     convert.size '600x400'
    #     convert << "gradient:#{start_color}-#{end_color}"
    #     convert.font "Arial"
    #     convert.pointsize (DEFAULT_SIZE)
    #     convert.gravity "Center"
    #     convert.fill "white"
    #     convert.stroke "black"
    #     convert.strokewidth 2
    #     convert.annotate "+0+20", caption.text
    #     convert << filename
    #   end
  end

  def generate_color_background(color)
    MiniMagick::Tool::Convert.new do |convert|
      convert.size "300x200"
      convert.xc "#{color}"
      # convert.font "Arial"
      convert.pointsize (DEFAULT_SIZE)
      convert.gravity "Center"
      convert.fill "white"
      convert.stroke "black"
      convert.strokewidth 2
      convert.annotate "+0+20", caption.text
      # binding.pry
      convert << filename
      convert.output filename
    end
  end

  def add_text_to_image(image)
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
