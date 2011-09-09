class ApplicationController < ActionController::Base
   helper :all # include all helpers, all the time
  before_filter :check_authentication

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => '043de2bf08edd0f70d03353b22b67b1e38947b44dbf701a32f54d1d8621e824cff5be03f2aa0f49ef19b2a9093b8b634de4b80e36cdad938c918dc8512db6f5e'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  # filter_parameter_logging :password


  def check_authentication
    if session[:member_id]
      @current_member = Member.find(session[:member_id])
    end
  end


  def requires_login
    
    unless @current_member
      flash[:error] = "You must be logged in to access this area"
      session[:protected] = request.path
      redirect_to "/login"
    end
  end
  
end
