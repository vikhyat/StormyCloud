require 'sinatra'
require 'json'

$job_status = {
  "eta" => "(unknown)"
}
Thread.new do
  loop do
    status = $transport.status
    $job_status['assigned'] = status[:assigned]
    $job_status['nodes'] = status[:clients].keys.sort_by {|x| status[:clients][x] }
                                           .reverse
    $job_status['node_times'] = status[:clients]
    $job_status['completed_count'] = status[:completed_count]
    $job_status['task_count'] = status[:task_count]
    $job_status['assigned_count'] = status[:assigned_count]
    $job_status['name'] = status[:name]
    $job_status['result'] = $transport.result || "(incomplete)"

    sleep 1
  end
end

def seconds_to_units(seconds)
  '%d days, %d h, %d m, %d s' %
    [24,60,60].reverse.inject([seconds]) {|result, unitsize|
      result[0,0] = result.shift.divmod(unitsize)
      result
    }
end

$prev = $transport.status[:completed_count]
Thread.new do
  loop do
    sleep 10
    status = $transport.status
    current = status[:completed_count]
    jobs_per_sec = (current - $prev).to_f / 10.0
    seconds_left = (status[:task_count] - status[:completed_count]) / jobs_per_sec
    if seconds_left == 1.0 / 0
      $job_status["eta"] = "infinity";
    else
      $job_status["eta"] = seconds_to_units seconds_left
    end
    $prev = current
  end
end

class Dashboard < Sinatra::Base
  set :logging, false

  get '/' do
    File.read('dashboard/index.html')
  end

  get '/status' do
    $job_status.to_json
  end
end

puts ">>> Starting dashboard."
Dashboard.run!
