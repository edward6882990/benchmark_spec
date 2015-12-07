Gem::Specification.new do |s|
  s.name    = 'benchmark-spec'
  s.version = '0.1.3'
  s.summary = 'RSpec syntax mimicked benchmarking framework'
  s.authors = ['Edward Tam']
  s.email   = 'etam@adparlor.com'
  s.files   = [
    'lib/benchmark_spec.rb',
    'lib/benchmark_spec/dsl.rb',
    'lib/benchmark_spec/output_formatter.rb',
    'lib/benchmark_spec/report_presenter.rb',
    'lib/benchmark_spec/shared_context.rb'
  ]

  s.executables = ['benchmark_spec']

  s.license = 'MIT'
end
