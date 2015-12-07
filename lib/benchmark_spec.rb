require 'benchmark'
require 'colorize'
require 'rack/test'
require 'active_support/core_ext/class/attribute'

require_relative 'benchmark_spec/dsl'
require_relative 'benchmark_spec/shared_context'
require_relative 'benchmark_spec/output_formatter'
require_relative 'benchmark_spec/report_presenter'

class BenchmarkSpec
  include Rack::Test::Methods

  include DSL
  include SharedContext

  class_attribute :config_proc

  attr_accessor :description, :execution, :tasks, :nested_specs, :before_hooks,
    :after_hooks, :config, :reports, :formatter


  def initialize(description, opts = {})
    @description = description
    @execution   = opts[:execution]

    @before_hooks = opts[:before_hooks] || {}
    @after_hooks  = opts[:after_hooks]  || {}

    @tasks        = []
    @nested_specs = []
    @reports      = []

    @formatter = opts[:formatter] || OutputFormatter.new

    @config ||= {}
    instance_exec @config, &config_proc if config_proc
  end

  class << self
    def configure(&block)
      BenchmarkSpec.config_proc = block
    end

    def load_files_recursively(path)
      Dir[path].each do |file|
        if File.directory? file
          load_files_recursively file + "/*"
        else
          require file if File.basename(file).match /benchmark\.rb$/
        end
      end
    end

    def describe(description, &block)
      $benchmarks ||= []
      $benchmarks << BenchmarkSpec.new(description, execution: block)
    end

    def evaluate_all
      return unless $benchmarks

      $benchmarks.each {|b| b.evaluate}
    end

    def run(args = [])
      base_path = Dir.pwd

      files_to_run = args.map{|path| "#{base_path}/#{path}"}
      files_to_run = ["#{base_path}/benchmark"] if files_to_run.empty?

      files_to_run.each do |f|
        load_files_recursively(f)
      end

      OutputFormatter.title("Benchmark Spec")

      evaluate_all

      OutputFormatter.title("Results")
    ensure
      ReportPresenter.print_results($benchmarks)
    end
  end

  def before(hook = :each, &block)
    before_hooks[hook] ||= []
    before_hooks[hook] << block
  end

  def after(hook = :each, &block)
    after_hooks[hook] ||= []
    after_hooks[hook] << block
  end

  def describe(description, &block)
    spec_options = {}
    spec_options[:execution]    = block if block
    spec_options[:before_hooks] = before_hooks.dup
    spec_options[:after_hooks]  = after_hooks.dup
    spec_options[:formatter]    = OutputFormatter.new(indent_level: formatter.indent_level + 1)

    nested_specs << BenchmarkSpec.new(description, spec_options)
  end

  def benchmark(description, &block)
    tasks << { description: description, execution: block }
  end

  def run_all_tasks
    return if tasks.empty?

    tasks.each do |t|
      begin
        pending t[:description] if t[:execution].nil?

        formatter.print "running #{t[:description]} ..."

        before_each_hooks.each {|b| b.call}
        report = Benchmark.measure(t[:description], &t[:execution])
        after_each_hooks.each {|a| a.call}

        reports << report
      rescue => e
        formatter.print "Error: #{e.message}".colorize(:red)
      end
    end
  end

  def evaluate
    if execution
      formatter.print "#{description}".colorize(:light_blue)

      instance_eval &execution

      run_all_tasks

      nested_specs.each do |ns|
        ns.evaluate
      end
    else
      pending(description)
    end
  end

private

  def pending(description)
    formatter.print "Pending: #{description}".colorize(:yellow)
  end

  def before_each_hooks
    before_hooks[:each] || []
  end

  def after_each_hooks
    after_hooks[:each] || []
  end

end

BenchmarkSpec.expose_methods_to_context([:describe, :shared_context], self)
