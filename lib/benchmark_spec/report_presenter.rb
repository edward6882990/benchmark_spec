class BenchmarkSpec
  class ReportPresenter
    attr_accessor :benchmark, :formatter, :nested_reports, :round_to

    def initialize(benchmark, opts = {}, formatter: nil)
      @benchmark = benchmark
      @formatter = formatter || BenchmarkSpec::OutputFormatter.new

      @round_to = opts[:round_to] || 3

      @nested_reports = []
      @benchmark.nested_specs.map do |ns|
        child_formatter = BenchmarkSpec::OutputFormatter.new(indent_level: @formatter.indent_level + 1)
        @nested_reports << ReportPresenter.new(ns, formatter: child_formatter)
      end
    end

    def print
      formatter.print "#{benchmark.description}:".colorize(:light_blue)
      benchmark.reports.each do |r|
        formatter.with_margins_vertically do
          formatter.print "#{r.label}:".colorize(:cyan).underline
          formatter.new_line
          formatter.print "    User: #{r.utime.round(round_to)}s"
          formatter.print "  System: #{r.stime.round(round_to)}s"
          formatter.print "   Total: #{r.total.round(round_to)}s"
        end
      end

      if nested_reports
        nested_reports.each do |nr|
          nr.print
        end
      end
    end

    def self.print_results(benchmarks)
      benchmarks ||= []

      reports = benchmarks.map{|b| ReportPresenter.new(b)}
      reports.each{|r| r.print}
      print_summary(benchmarks)
    end

    def self.print_summary(benchmarks)
      benchmarks ||= []

      num_of_examples_run = benchmarks.map{|b| calculate_num_of_examples_run(b)}.reduce(:+) || 0
      total_time          = benchmarks.map{|b| calculate_total_time(b)}.reduce(:+) || 0

      puts "--------------------------------------------------------------------"
      puts "Examples run: #{num_of_examples_run}, Total Execution Time: #{total_time}s".colorize(:light_green)
    end

    def self.calculate_num_of_examples_run(benchmark)
      return benchmark.reports.count if benchmark.nested_specs.empty?

      num_of_examples_run = benchmark.reports.count
      benchmark.nested_specs.each do |ns|
        num_of_examples_run += calculate_num_of_examples_run(ns)
      end

      num_of_examples_run
    end

    def self.calculate_total_time(benchmark)
      if benchmark.nested_specs.empty?
        return benchmark.reports.map(&:total).reduce(:+) || 0
      end

      total_time = benchmark.reports.map(&:total).reduce(:+) || 0
      benchmark.nested_specs.each do |ns|
        total_time += calculate_total_time(ns)
      end

      total_time
    end
  end
end
