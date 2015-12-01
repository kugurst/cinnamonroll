module StaticHelper
  MESSAGE_ARRAY = ['Hey there', 'Nice weather?', 'Good of you to drop by', 'Bonjour', 'puts "Hello"', "Hope you weren't waiting long"]

  def greeting_message
    MESSAGE_ARRAY.sample
  end
end
