class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :ya_loggeado, only: [:create]


  def new
  end

  def ya_loggeado
    if(current_user)
      redirect_to root_path
      flash[:notice] = "Ya estas Logeado!"
    else
    end
  end
  
  def create
  user = Admin.authenticate(params[:login], params[:password])
  if user
    session[:user_id] = user.id
    redirect_to root_url, :notice => "Logged in!"
  else
    flash.now.alert = "Invalid email or password"
    render "new"
  end
end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end
end