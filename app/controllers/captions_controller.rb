class CaptionsController < ApplicationController
  wrap_parameters false
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

  def create
    @caption = Caption.new(caption_params)

    if @caption.save
      render json: @caption, status: :created
    else
      render json: { errors: @caption.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def caption_params
    params.require(:caption).permit(
      :url, :text, :kind, :type_field, :color, 
      :start_color, :end_color, :filter, :unique_name
    )
  end

  def handle_parameter_missing(exception)
    render json: { error: "Bad Request: #{exception.message}" }, status: :bad_request
  end
end