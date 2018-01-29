require 'net/http'
require 'uri'
require 'json'


Dashing.scheduler.every '5s', :first_in => 0.4 do

  interval_min = 5
  plot_range_hr = 6 # Range that plot must show, ie: 6hrs of datapoints
  nasdaq_symbol = 'GOOGL'
  source_uri = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=#{nasdaq_symbol}&interval=#{interval_min}min&apikey=#{ENV["ALPHAVANTAGE_API_KEY"]}"

  uri = URI.parse(source_uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == 'https')
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  begin
    response = http.request(Net::HTTP::Get.new(uri.request_uri))
  rescue StandardError => e
    puts "ERROR: JOB UNABLE TO GET SITE WITH SYMBOL: #{nasdaq_symbol}, error #{e}"
  end

  unless response.nil?
    response_body = JSON.parse(response.body)

    # Number of points, based off dev-school requirement
    n = (  plot_range_hr*60 )/ interval_min

    # Get time series, convert to array, sort (0=oldest), keep first n
    ts = response_body["Time Series (#{ interval_min}min)"].to_a.sort
    ts = ts[(ts.length-n)...ts.length] if ts.length > n # last n points

    ts_times = ts.map{ |x| x[0]}
    ts_open = ts.map{ |x| x[1]['1. open'] }
    ts_close= ts.map{ |x| x[1]['4. close'] }
    ts_volume= ts.map{ |x| x[1]['5. volume'] }

    #ts_open = ts.map { |x| x['1. open']}

    labels = ts_times
    open_close= [
        {
            label: 'Open',
            data: ts_open,
            backgroundColor: [ 'rgba(0, 99, 132, 0.2)' ] * labels.length,
            borderColor: [ 'rgba(0, 99, 132, 1)' ] * labels.length,
            borderWidth: 1,
        }, {
            label: 'Close',
            data: ts_close,
            backgroundColor: [ 'rgba(0, 0, 132, 0.2)' ] * labels.length,
            borderColor: [ 'rgba(0, 0, 132, 1)' ] * labels.length,
            borderWidth: 1,
        }
    ]
    volume = [
        {
            label: 'Volume',
            data: ts_volume,
            backgroundColor: [ 'rgba(0, 0, 132, 0.2)' ] * labels.length,
            borderColor: [ 'rgba(0, 0, 132, 1)' ] * labels.length,
            borderWidth: 1,
        }
    ]
    Dashing.send_event('google_open_close', {labels: labels, datasets: open_close})
    Dashing.send_event('google_volume', {labels: labels, datasets: volume})
  end
end
