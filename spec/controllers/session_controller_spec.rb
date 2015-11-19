require "rails_helper"

describe SessionController, '#new' do
  context 'when no user is logged in' do
    it 'sends us to the log in page' do
      get :new


      expect(response).to render_template("new")
    end
  end

  context 'when a user is logged in' do
    before :each do
      pass = "password"
      @user = create :user, password: pass

      puts "@user.email: #{@user.email}"

      post :create, session: { email_or_username: @user.email, password: pass },
           enc: { active: false }


      expect(response).to redirect_to "/users/#{@user.id}"
    end

    it "redirects us to the user's page" do
      get :new


      expect(response).to redirect_to "/users/#{@user.id}"
    end
  end
end
