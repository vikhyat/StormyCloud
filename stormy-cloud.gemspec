Gem::Specification.new do |s|
  s.name        = 'stormy-cloud'
  s.version     = '0.1.3'
  s.date        = '2012-06-18'
  s.summary     = "Ridiculously simple distributed applications."
  s.description = "StormyCloud makes writing distributed applications in Ruby a piece of cake."
  s.authors     = ["Vikhyat Korrapati"]
  s.email       = 'c@vikhyat.net'

  s.files       = Dir.glob('lib/*') + Dir.glob('dashboard/*')
  while s.files.any? {|f| File.directory? f }
    s.files = s.files.map {|x| File.directory?(x) ? Dir.glob(x+'/*') : x }.flatten
  end

  s.homepage    = "https://github.com/vikhyat/StormyCloud"
end
