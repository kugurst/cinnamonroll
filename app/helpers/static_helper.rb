module StaticHelper
  MESSAGE_ARRAY = ['Hey there', 'Nice weather?', 'Good of you to drop by', 'Bonjour', 'puts "Hello"', "Welcome"]


  def greeting_message
    MESSAGE_ARRAY.sample
  end

  def get_static_links
    { "/" => "Home", "#{about_me_path}" => "About Me", "#{login_path}" => "Log In", "#{new_user_path}" => "Sign Up" }
  end

  def static_link_name(path)
    sl = get_static_links
    sl[path]
  end
end
