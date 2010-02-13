class SessionView < ApplicationView
  set_java_class 'session.New'

  map :model => :username, :view => "username.text"
  map :model => :password, :view => "password.text"
end