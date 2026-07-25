class CaptionsController < ApplicationController
  wrap_parameters false
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  before_action :set_caption, only: [ :show, :destroy ]

  def index
    render json: { captions: Caption.all.map { |c| serialize(c)[:caption] } }, status: 200
  end

  def show
    render json: serialize(@caption), status: 200
  end

  def create
    create_caption
  end

  def create_instagram
    create_caption
  end

  def show_instagram
    render json: { message: "Instagram endpoint is available" }, status: 200
  end

  def destroy
    delete_generated_image if @caption.caption_url.present?
    @caption.destroy
    head :ok
  end

  private

  def create_caption
    @caption = Caption.new(caption_params)

    if @caption.save
      begin
        relative_path = ImageCreation.new(@caption).call
        @caption.update!(caption_url: "#{request.base_url}#{relative_path}")
        render json: serialize(@caption), status: 201
      rescue ImageCreation::DownloadError => e
        @caption.destroy
        error_response("invalid_url", "Unprocessable Entity", e.message, 422)
      rescue StandardError => e
        @caption.destroy
        error_response("image_creation_failed", "Unprocessable Entity", e.message, 422)
      end
    else
      error_response(
        "invalid_parameters",
        "Unprocessable Entity",
        @caption.errors.full_messages.join(", "),
        422)
    end
  end

  def delete_generated_image
    parsed_url = URI.parse(@caption.caption_url)
    return unless parsed_url.path.include?("/images/")

    path = parsed_url.path.split("/images/").last
    return if path.blank?

    FileUtils.rm_f(Rails.root.join("public", "images", path))
  rescue URI::InvalidURIError
    nil
  end

  def set_caption
    @caption = Caption.find(params[:id])
  end

  def serialize(caption)
    {
      caption: {
        id: caption.id,
        url: caption.url,
        text: caption.text,
        caption_url: caption.caption_url
      }
    }
  end

  def caption_params
    params.require(:caption).permit(
      :url, :text, :type_field, :color,
      :start_color, :end_color, :filter, :unique_name
    )
  end

  def handle_parameter_missing(exception)
    error_response("missing_parameter", "Bad Request", exception.message, 400)
  end

  def handle_not_found(exception)
    error_response("not_found", "Not Found", exception.message, 404)
  end
end
