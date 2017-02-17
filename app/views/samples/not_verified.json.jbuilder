json.samples @samples do |sample|
  json.id sample.id
  json.url sample.image.url
  json.label sample.label
end
