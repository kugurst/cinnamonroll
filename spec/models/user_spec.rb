require "rails_helper"

describe User, '#password=' do
  password = "test_password"

  it "creates with the hashed the password" do
    user = User.create password: password
    # user.password = password
    expect(user.password).to_not be == password
  end

  it "converts the assigned password to a hash" do
    user = User.create
    user.password = password
    expect(user.password).to_not be == password
  end

  # Set a password for the remaning tests
  subject { User.create password: password }
  it { is_expected.to be_valid_pass password }
  it { is_expected.to_not be_valid_pass password * 2 }
end
