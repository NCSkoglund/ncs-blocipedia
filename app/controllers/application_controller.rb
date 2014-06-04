class ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  
  private

  def user_not_authorized(exception)
    #QUESTION:  doesn't recognize methods exception.policy or exception.query
    #Rewrote to work around, see en.yml
    #policy_name = exception.policy.class.to_s.underscore  
    #"pundit.#{policy_name}.#{exception.query}" 
    flash[:error] = I18n.t "pundit.#{@_action_name}?", default: 'You cannot perform this action.'
    redirect_to(request.referrer || root_path)
  end

  def not_found
    render text: "404 Not Found", status: 404
  end
  
  # redirect after devise login
  def after_sign_in_path_for(resource)
    wikis_path
  end
end
