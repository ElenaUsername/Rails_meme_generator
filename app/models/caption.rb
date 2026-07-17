class Caption < ApplicationRecord
  validates :url, presence: true
  validates :text, presence: true, length: { maximum: 266 }
  validate :url_points_to_valid_image_type

  private

  def url_points_to_valid_image_type
    return if url.blank?

    uri = URI.parse(url)

    is_valid_web_url = uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    unless is_valid_web_url
      errors.add(:url, "is not a valid URL")
    end

    valid_extensions = %w[.jpg .jpeg .png .gif .webp]
    file_extension = File.extname(uri.path).downcase

    unless valid_extensions.include?(file_extension)
      errors.add(:url, "must point to a valid image (jpg, jpeg, png, gif, webp)")
    end

  rescue URI::InvalidURIError
    errors.add(:url, "is not a valid URL")
  end
end
