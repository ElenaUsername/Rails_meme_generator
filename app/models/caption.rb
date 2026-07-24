class Caption < ApplicationRecord
  validates :url, presence: true
  validates :text, presence: true, length: { maximum: 266 }
  validate :url_is_valid
  validate :url_points_to_valid_image_type

  before_validation :generate_unique_name, on: :create
  validates :unique_name, presence: true, uniqueness: true

  private

  def url_is_valid
    return if url.blank?

    uri = URI.parse(url)

    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      errors.add(:url, "is not a valid URL")
    end
  rescue URI::InvalidURIError
    errors.add(:url, "is not a valid URL")
  end

  def url_points_to_valid_image_type
    return if url.blank?

    uri = URI.parse(url)
    return unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    extension = File.extname(uri.path).downcase
    return if extension.blank?

    valid_extensions = %w[.jpg .jpeg .png .gif .webp]
    unless valid_extensions.include?(extension)
      errors.add(:url, "must point to a valid image (jpg, jpeg, png, gif, webp)")
    end
  rescue URI::InvalidURIError
    # url_is_valid will handle invalid URLs
  end

  def generate_unique_name
    return if unique_name.present?

    loop do
      candidate = "meme_#{Date.current.strftime('%Y%m%d')}_#{SecureRandom.hex(4)}"
      unless Caption.exists?(unique_name: candidate)
        self.unique_name = candidate
        break
      end
    end
  end
end
