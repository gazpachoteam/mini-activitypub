class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  force_ssl if: :https_enabled?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to main_app.root_url, notice: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end

  def current_account
    @current_account ||= current_user.try(:account)
  end

  def https_enabled?
    Rails.env.production? && ENV['LOCAL_HTTPS'] == 'true'
  end
end
