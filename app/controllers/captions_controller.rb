class CaptionsController < ApplicationController
  wrap_parameters false
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

  def create
    @caption = Caption.new(caption_params)

    if @caption.save
      render json: @caption, status: 201
    else
      error_response(
        "invalid_parameters", 
        "Unprocessable Entity", 
        @caption.errors.full_messages.join(", "), 
        422)
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
    error_response(
      "missing_parameter",
      "Bad Request",
      exception.message,
      400
    )
  end

end
