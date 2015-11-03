class SecurityController < ApplicationController
  skip_before_action :require_aes_key!, only: :new
  skip_before_action :verify_authenticity_token, only: :new
  def new
    render js: "alert('Hello Rails')"
  end
end
