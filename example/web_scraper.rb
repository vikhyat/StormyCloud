require_relative '../lib/stormy-cloud'
require 'net/http'

StormyCloud.new("web_scraper", "localhost") do |c|
  c.split { (2..5).to_a }

  c.map do |roll_number|
    uri = URI('http://results.herokuapp.com/result')
    res = Net::HTTP.post_form(uri, 'rno' => roll_number.to_s)
    res.body.split('</strong>')[0..1].map {|x| x.split('<strong>')[1] } * ' '
  end

  c.reduce do |roll_number, result|
    puts "#{roll_number} #{result}"
  end

  c.finally do
    "done"
  end
end
