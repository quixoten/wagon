class SessionController < ApplicationController
  set_model 'SessionModel'
  set_view 'SessionView'
  set_close_action :exit

  def login_button_action_performed
    update_model(view_model, :username)
    update_model(view_model, :password)
    
    model.connection = Wagon::connect(model.username, model.password)

  end

  def cancel_button_action_performed
    self.close()
  end
end
