# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'multi-file-processor'
  s.version     = '0.1.0'
  s.licenses    = ['MIT']
  s.summary     = 'Process mutliple files'
  s.description = 'Iterates over files moving them to inprogress, done or failed'
  s.authors     = ['Doug Youch']
  s.email       = 'dougyouch@gmail.com'
  s.homepage    = 'https://github.com/dougyouch/multi-file-processor'
  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
end
