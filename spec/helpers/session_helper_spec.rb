require "rails_helper"

describe SessionHelper, '#log_in' do
  subject { build :user }
  it 'logs a user in' do
    log_in subject


    expect(session[:user_id]).to be == subject.id.to_s
  end
end

describe SessionHelper, '#logged_in?' do
  subject { create :user }

  it 'returns true if the user is logged in' do
    log_in subject


    expect(logged_in?).to be
  end

  it 'returns false if the user is not logged in' do
    expect(logged_in?).to_not be
  end
end

describe SessionHelper, '#remember' do
  subject { create :user }

  it 'sets the cookies when asked to remember this user' do
    remember subject


    expect(cookies.signed[:user_id]).to be
    expect(cookies.signed[:remember_token]).to be
  end
end

describe SessionHelper, '#forget' do
  subject { create :user }

  it 'removes the cookies from a remembered user' do
    remember subject
    forget subject


    expect(cookies.signed[:user_id]).to_not be
    expect(cookies.signed[:remember_token]).to_not be
  end

  it 'removes only its cookies from a remembered user' do
    remember subject
    remember subject
    forget subject


    expect(subject.remember_hash).to_not be_empty


    forget subject


    expect(subject.remember_hash).to_not be_empty
  end
end

describe SessionHelper, '#current_user' do
  context 'when the user is in the session' do
    before :each do
      @user = create :user


      log_in @user
    end

    it 'returns that user' do
      expect(current_user).to be == @user
      expect(session[:user_id]).to be == @user.id.to_s
    end
  end

  context 'when the user is remembered and not in the session' do
    before :each do
      @user = create :user


      remember @user
    end

    it 'returns that user and adds it to he session' do
      expect(session[:user_id]).to_not be


      expect(current_user).to be == @user


      expect(session[:user_id]).to be
    end
  end

  context 'when the user is remembered and in the session' do
    before :each do
      @user = create :user


      remember @user
      log_in @user
    end

    it 'returns the user' do
      expect(session[:user_id]).to be
      expect(cookies.signed[:user_id]).to be == @user.id.to_s
      expect(current_user).to be == @user
    end
  end
end

describe SessionHelper, '#log_out' do
  context 'when the user is logged in' do
    before :each do
      @user = create :user


      remember @user
      log_in @user
    end

    it "removes the user's cookie and session" do
      log_out


      expect(session[:user_id]).to_not be
      expect(cookies.signed[:user_id]).to_not be
      expect(cookies.signed[:remember_token]).to_not be
    end
  end
end
