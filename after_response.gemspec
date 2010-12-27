Gem::Specification.new do |s|
  s.name            = "after_response"
  s.version         = "0.9.2"
  s.platform        = Gem::Platform::RUBY
  s.summary         = "Provides hooks to execute callbacks after the response has been delivered to the client."

  s.description = <<-EOF
AfterResponse provides callbacks into the Passenger2.2, Passenger3 and Unicorn
request cycle. The main goal is to delay as much non-critical processing until later, delivering
the response to the client application sooner. This would mainly include logging data into a Observatory-like
event logging service, sending email and other tasks that do not affect the response body in any way.
EOF

  s.files           = Dir['{lib/*,rails/*}'] +
                        %w(after_response.gemspec CHANGELOG README)
  s.require_path    = 'lib'
  s.extra_rdoc_files = ['README', 'CHANGELOG']

  s.author          = 'Kevin E. Hunt'
  s.email           = 'kevin@kev.in'
  s.homepage        = 'https://github.com/kevn/after_response'

end

