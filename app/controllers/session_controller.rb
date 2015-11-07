class SessionController < ApplicationController
  layout 'session/session'

  def new
  end

  def create
    lp = login_params params
    begin
      user = User.find_by email: lp[:email].downcase()
    rescue Mongoid::Errors::DocumentNotFound
      begin
        user = User.find_by name: lp[:email]
      rescue Mongoid::Errors::DocumentNotFound
        render 'new', status: :not_found
        return
      end
    end

    if user && user.authenticate(params[:session][:password])
      # Log the user in and redirect to the user's show page.
    else
      # Create an error message.
      render 'new'
    end
  end

  def destroy
  end

  private
    def login_params(params)
      params.require(:session).permit(:password, :email)
    end
end
