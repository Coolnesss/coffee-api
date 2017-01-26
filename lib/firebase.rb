require 'fcm'

class Firebase
  include Singleton
  @@fcm = FCM.new ENV["FIREBASE_SERVER_KEY"]

  def self.send(message)
    @@fcm.send_to_topic("coffee", data: {
      coffee: message
    })
  end
end
