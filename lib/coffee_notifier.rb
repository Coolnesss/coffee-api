require 'coffee_state'
class CoffeeNotifier

  # Strong bubble gum to get state of server without retraining model
  #$url = "http://coffeeapi.g7xd2rhrfs.eu-central-1.elasticbeanstalk.com/state"
  #$file_path = ".coffee_state"

  # To avoid spamming notifications,
  # only send another one when coffee levels have sufficiently gone down first
  #def self.notify
  #  state = JSON.parse(RestClient.get($url))["state"]
  #  previous_ok = eval(IO.read($file_path))
  #  if state >= 10 and previous_ok
  #    Firebase.send state
  #    IO.write($file_path, "false")
  #  elsif state <= 3
  #    IO.write($file_path, "true")
  #  end
  #end

  @ok = true

  def perform(*args)
    state = CoffeeState.state
    Rails.logger.info "Current state was #{state}, with previous state #{@ok}"
    if state >= 10 and @ok
      Firebase.send state
      @ok = false
      Rails.logger.info "Notification sent"
    elsif state <= 3
      @ok = true
    end
  end
end
