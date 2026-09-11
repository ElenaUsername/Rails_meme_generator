class ApplicationController < ActionController::API
  private

  def error_response(code, title, description, status)
    render json: { code: code, title: title, description: description }, status: status
  end
end
