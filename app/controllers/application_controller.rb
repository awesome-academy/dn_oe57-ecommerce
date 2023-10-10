class ApplicationController < ActionController::Base
  include CategoriesHelper

  # app/controllers/application_controller.rb
  include Pagy::Backend

  before_action :set_locale
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json{head :forbidden}
      format.html{redirect_to main_app.root_url, alert: exception.message}
    end
  end

  private

  def current_ability
    controller_name_segments = params[:controller].split("/")
    controller_name_segments.pop
    controller_namespace = controller_name_segments.join("/").camelize
    @current_ability ||= Ability.new(current_user, controller_namespace)
  end
end
