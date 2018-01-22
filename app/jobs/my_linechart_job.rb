require 'net/http'
require 'uri'
require 'json'


SOURCE_URI = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=MSFT&apikey=#{ENV["ALPHAVANTAGE_API_KEY"]}"

labels = ['January', 'February', 'March', 'April', 'May', 'June', 'July']

Dashing.scheduler.every '5s' do

  uri = URI.parse(SOURCE_URI)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == 'https')
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  response = http.request(Net::HTTP::Get.new(uri.request_uri))
  response_body = JSON.parse(response.body)

  data = [
      {
          label: 'First dataset',
          data: Array.new(labels.length) { rand(40..80) },
          backgroundColor: [ 'rgba(255, 99, 132, 0.2)' ] * labels.length,
          borderColor: [ 'rgba(255, 99, 132, 1)' ] * labels.length,
          borderWidth: 1,
      }, {
          label: 'Second dataset',
          data: Array.new(labels.length) { rand(40..80) },
          backgroundColor: [ 'rgba(255, 206, 86, 0.2)' ] * labels.length,
          borderColor: [ 'rgba(255, 206, 86, 1)' ] * labels.length,
          borderWidth: 1,
      }, {
          label: 'Third dataset',
          data: Array.new(labels.length) { rand(40..80) },
          backgroundColor: [ 'rgba(255, 206, 0, 0.2)' ] * labels.length,
          borderColor: [ 'rgba(255, 206, 86, 1)' ] * labels.length,
          borderWidth: 1,
      }
  ]
  Dashing.send_event('linechart', {labels: labels, datasets: data })
end
