require 'rest-client'
require 'nokogiri'
require 'pry'
require 'open-uri'

url = "cce.kapsi.fi/kahvi/"
save_path = "lib/unlabelled_training_data/"

response = RestClient.get(url)
body = Nokogiri::HTML(response.body)
rows = body.search("a")
image_names = body.search("a").map{|x| x.text if x.text =~ /\d{7}_/}.compact

image_names.each do |image_name|
  open(save_path + image_name, 'wb') do |file|
    file << open("http://" + url + image_name).read
  end
end
