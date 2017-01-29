require 'singleton'
class LastNotified
  include Singleton

  def initialize
    @ok = true
  end
  
  attr_accessor :ok

end
