require "rails_helper"

describe SessionController, '#create' do
  context 'when the user is not in the database' do
    before :each do
      @pass = Forgery(:basic).password
      @user = build :user
    end

    it 'renders #new and sets the status to :not_found' do
      params = { session: { email_or_username: @user.email, password: @pass }, enc: { active: false } }


      post :create, params


      expect(response.status).to be 404
      expect(response).to render_template 'new'
    end
  end

  context 'when the user is in the database' do
    before :each do
      @pass = Forgery(:basic).password
      @user = create :user
    end

    context 'when the password is bad' do
      it 'responds with not found' do
        params = { session: { email_or_username: @user.email, password: @pass * 2 }, enc: { active: false } }


        post :create, params


        expect(response.status).to be 404
        expect(response).to render_template 'new'
      end
    end

    context 'when the password is good' do
      before :each do
        @pass = Forgery(:basic).password
        @user = create :user, password: @pass
      end

      it "redirects to the user's page" do
        params = { session: { email_or_username: @user.email, password: @pass }, enc: { active: false } }


        post :create, params


        expect(response.status).to be 302
        expect(response).to redirect_to  controller: 'users', action: 'show', id: @user.name
      end
    end
  end
end

describe SessionController, '#new' do
  context 'when no user is logged in' do
    it 'sends us to the log in page' do
      get :new


      expect(response).to render_template "new"
    end
  end

  context 'when a user is logged in' do
    before :each do
      pass = Forgery(:basic).password
      @user = create :user, password: pass

      session[:user_id] = @user.id.to_s
    end

    it "redirects us to the home page" do
      get :new


      expect(response).to redirect_to root_path
    end
  end
end

describe SessionController, '#destroy' do
  context 'when a user is logged in' do
    before :each do
      pass = Forgery(:basic).password
      @user = create :user, password: pass


      post :create, session: { email_or_username: @user.email, password: pass },
           enc: { active: false }


      expect(response).to redirect_to controller: 'users', action: 'show', id: @user.name
    end

    it 'logs the user out' do
      delete :destroy


      expect(response).to redirect_to root_url
      expect(session[:user_id]).to_not be
      expect(cookies.signed[:user_id]).to_not be
      expect(cookies.signed[:remember_token]).to_not be
    end
  end
end
