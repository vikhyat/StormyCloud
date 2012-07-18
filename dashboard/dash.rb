require 'sinatra'
require 'json'

def job_status
  $transport.status
end

class Dashboard < Sinatra::Base
  set :logging, false

  get '/' do
    File.read('dashboard/index.html')
  end

  get '/status' do
    job_status.to_json
  end
end

puts ">>> Starting dashboard."
Dashboard.run!
