class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :null_session

  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  devise_group :person, contains: [ :manager ]
  #before_action :authenticate_person!
  before_action do |controller|
    controller_name = controller.class.to_s
    cond1 = (controller_name == "Managers::SessionsController" && action_name == "new")
    if cond1
      next
    end

    #authenticate_person!
    if (controller_name =~ /^Managers.*$/) == 0
      authenticate_manager!
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    render 'errors/error_403', status: 403,  layout: 'error'
  end
    
  ######## devise ########
  #override devise after login path
  def after_sign_in_path_for(resource)
     case resource
     when :manager, Manager
       managers_mains_path
     else
     end
  end

  #override devise after logout path
  def after_sign_out_path_for(resource)
     case resource
     when :manager, Manager
       new_manager_session_path
     else
     end
  end

  def authenticate_manager
    authenticate_manager!
    unless current_manager
      redirect_to new_manager_session_path
    end
  end
  #######################

  def response_json(status=403, data={})
    {status: status}.merge(data: data).to_json
  end

  def response_json_by_obj(is_success, obj)
    is_success ? response_json(200) : response_json(500, message: obj.errors.full_messages.first)
  end

  def common_json_response(status =403, data={})
    result = data.to_json unless data.is_a? String
    {:status => status, :json => result }
  end

  def reponse_json_only(data={})
    result = data.to_json unless data.is_a? String
    {:json => result}
  end

  def format_report_task_name prefix, job_type
    prefix + "#" + job_type
  end

  #format errors from model
  def format_error ins
    ins.errors.nil?? "" : ins.errors.messages.map{|k,v| "#{k}:#{v.uniq[0]}"}.join("<br>")
  end

  private 

    # set swtk app locale, so can get the suitable labels 
    #
    def set_locale
      I18n.locale = extract_locale_from_request
    end

    def deal_label(key, arr)
      arr.delete(nil)
      arr.map {|m| [I18n.t("#{key}.#{m}"), m] }
    end

    # get locale according to conditions which are ordered by priority
    #
    def extract_locale_from_request
      # locale defined in parameters
      return params[:locale] if params[:locale]
      # get locale from subdomains
      parsed_locale = request.subdomains.first
      return parsed_locale if I18n.available_locales.map(&:to_s).include?(parsed_locale)
      # get locale from http header
      return request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first if request.env['HTTP_ACCEPT_LANGUAGE']
      # get default locale
      return I18n.default_locale
    end

    def configure_permitted_parameters
      #devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password, :password_confirmation,:remember_me])
      devise_parameter_sanitizer.permit(:sign_in, keys: [:login, :password])
      #devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :password, :password_confirmation,:remember_me])
    end

end
