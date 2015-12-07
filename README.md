# benchmark_spec
`benchmark_spec` is a RSpec syntax mimicked lightweight benchmarking framework to better organize benchmarks.

## Getting Start
To install, you can run:

```
gem install benchmark-spec
```

Or, you can bundle by adding the gem to your Gemfile:

```
gem 'benchmark-spec'
```

## Running benchmarks
To run benchmarks, you can run:

```
bundle exec benchmark_spec path/to/dir path/to/file [...]
```

Or by default, if there is no argument provided, `benchmark_spec` will run benchmarks from `{YOUR_PROJECT_ROOT}/benchmark` folder

```
bundle exec benchmark-spec
```

## Writing a benchmark
`benchmark_spec` will only load files that end with `*_benchmark.rb`, therefore be careful when naming your benchmark files:

```
touch benchmark/test_benchmark.rb
```

Then in at the top of your code, `require 'benchmark_spec` and write your RSpec like benchmark:

```ruby
require 'benchmark_spec'

shared_context :something do
  before :each do
    puts "Shared something"
  end
end

describe "test" do
  include_context :something
  
  before :each do
    @times = 10000
  end
  
  after :each do
    @times = nil
  end
  
  describe "nested" do
    benchmark "iterate using 'for'" do
      for i in 1..@times
        a = 1
      end
    end
  end
end
```

## Configuration
You can pass in a block to configure `benchmark_spec`:
```ruby
  BenchmarkSpec.configure do |config|
    # Whatever you put here will be evaluated with the instance's context
  end
```

If you want to use [Rack::Test](https://github.com/brynary/rack-test) with `benchmark_spec`, you will need to do something like:
```ruby
  BenchmarkSpec.configure do |config|
    def app
      MyApp
    end
  end
```

## Note
`benchmark_spec` does not support all RSpec features at the moment. Followings are currently adapted:
```ruby
  describe "string"
  before :each
  after :each
  shared_context &block
  include_context :symbol
```
