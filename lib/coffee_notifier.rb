require 'json'

class CoffeeNotifier

  # Strong bubble gum to get state of server without retraining model
  $url = "localhost:3000/state" if Rails.env.development?
  $url = "http://coffeeapi.g7xd2rhrfs.eu-central-1.elasticbeanstalk.com/state" if Rails.env.production?
  $file_path = ".coffee_state"

  # To avoid spamming notifications,
  # only send another one when coffee levels have sufficiently gone down first
  def self.notify
    state = JSON.parse(RestClient.get($url))["state"]
    previous_ok = eval(IO.read($file_path))
    if state >= 10 and previous_ok
      Firebase.send state
      IO.write($file_path, "false")
    elsif state <= 3
      IO.write($file_path, "true")
    end
  end
end
