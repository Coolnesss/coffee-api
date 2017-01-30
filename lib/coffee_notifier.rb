require 'coffee_state'
require 'last_notified'
require 'firebase'

class CoffeeNotifier
  
  def perform(*args)
    ok = LastNotified.instance.ok
    state = CoffeeState.state
    Rails.logger.info "Current state was #{state}, with previous state #{ok}"

    if state >= 10 and ok
      Firebase.send state
      LastNotified.instance.ok = false
      Rails.logger.info "Notification sent"
    elsif state <= 3
      LastNotified.instance.ok = true
    end

  end
end
