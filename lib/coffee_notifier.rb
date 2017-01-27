require 'singleton'
class CoffeeNotifier
  include Singleton
  @@ok = true

  # To avoid spamming notifications,
  # only send another one when coffee levels have sufficiently gone down first
  def notify
    state = CoffeeState.state
    if state >= 10 and @@ok
      Firebase.send state
      @@ok = false
    elsif state <= 3
      @@ok = true
    end
  end
end
