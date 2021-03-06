class SessionsController < ApplicationController
  before_action :login_required, only: [:destroy]
  def create
    begin
      user = User.from_omni_auth(request.env["omniauth.auth"])
      login(user.id)
    rescue
      flash[:danger] = Message.authentication_error
    end
    redirect_to root_path
  end

  def destroy
    logout
    redirect_to root_url
  end
end
