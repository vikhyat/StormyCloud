require 'sinatra'

class Dashboard < Sinatra::Base
  set :logging, false

  get '/' do
    File.read('dashboard/index.html')
  end
end

puts "> Starting dashboard."
Dashboard.run!
