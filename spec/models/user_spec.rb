require "rails_helper"

describe User, 'state' do
  context "password" do
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

  context "email" do
    email = "TEST@TEST.com"
    subject { User.create(email: email).email }
    it { is_expected.to_not be == email }
    it { is_expected.to be == email.downcase }
  end
end

describe User, "#remember" do
  user = FactoryGirl.build :user

  before :each do
    @length = user.remember_hash.length
  end

  it "adds a remember hash when asked to remember something" do
    user.remember
    expect(user.remember_hash.length).to be == @length + 1
  end

  it "doesn't remove a token that hasn't been added" do
    user.forget User.new_token
    expect(user.remember_hash.length).to be == @length
  end

  it "removes a token that has been added" do
    tok = user.remember
    user.forget tok
    expect(user.remember_hash.length).to be == @length
  end

  it "removes a token when the length reaches #{User::MAX_REMEMBERED_DEVICES}" do
    # clear the hash and mark the token that falls off
    user.remember_hash.clear
    tok = user.remember
    while user.remember_hash.length < User::MAX_REMEMBERED_DEVICES
      user.remember
    end

    # add the token that should trigger the removal step
    tok_newest = user.remember
    # make sure it's gone
    expect(user).to_not be_valid_rem tok
    # and make sure the newest one is here
    expect(user).to be_valid_rem tok_newest
  end

  it "persists the remember_hash correctly" do
    # Persist the user
    expect(user.save!).to be == true

    # Make sure the hashes match
    loaded_user = User.find_by name: user.name
    expect(loaded_user.name).to be_eql user.name
    expect(loaded_user.remember_hash).to be_eql user.remember_hash
  end

  it "clears the remember_hash correctly" do
    # clear and save the hash
    user.forget_all!
    expect(user.remember_hash).to be_empty

    # make sure the hash was saved empty
    loaded_user = User.find_by name: user.name
    expect(loaded_user.remember_hash).to be_empty
  end

  it "saves changes to the remember_hash correctly" do
    # make sure the added token was remembered
    tok = user.remember
    loaded_user = User.find_by name: user.name
    expect(loaded_user).to be_valid_rem tok
    expect(loaded_user.remember_hash.length).to be == 1

    # overload the remember_hash again
    while user.remember_hash.length < User::MAX_REMEMBERED_DEVICES
      user.remember
    end
    new_tok = user.remember

    # ensure the last value is gone and the new value is present
    loaded_user = User.find_by name: user.name
    expect(loaded_user).to_not be_valid_rem tok
    expect(loaded_user).to be_valid_rem new_tok
  end
end

describe User, 'relations' do
  subject { create :user }
  it "sets comments to deleted when destroyed" do
    c = create :comment, :with_sub_comments, same_user: true, comment_list: [5]
    subject.comments << c
    c.comments.each{ |e| subject.comments << e }
    expect(subject.save).to be
    expect(c.save).to be
    expect(subject.comments[0]).to be == c


    subject.destroy


    expect(c.deleted).to be
    c.comments.each { |child| expect(child.deleted).to be }
  end
end
