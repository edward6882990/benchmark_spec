class BenchmarkSpec
  class OutputFormatter
    attr_accessor :indent_level, :space_per_indent

    TITLE_LENGHT       = 100
    TITLE_FILLER       = '-'
    MIN_NUM_OF_FILLERS = 20

    def initialize(indent_level: 0, space_per_indent: 2)
      @indent_level = indent_level
      @space_per_indent = space_per_indent
    end

    class << self
      def title(content)
        with_margins_vertically do
          side_fillers =
            TITLE_FILLER * ([TITLE_LENGHT - content.length, MIN_NUM_OF_FILLERS].max / 2 - 1) # -1 for the space

          puts "#{side_fillers} #{content} #{side_fillers}"
        end
      end

      def with_margins_vertically(num_of_lines = 1)
        num_of_lines.times { new_line }
        yield
        num_of_lines.times { new_line }
      end

      def new_line
        puts "\n"
      end
    end

    def title(content)
      self.class.title(content)
    end

    def new_line
      self.class.new_line
    end

    def with_margins_vertically(*a, &b)
      self.class.with_margins_vertically(*a, &b)
    end

    def print(message)
      message = indent_message(message)
      puts message
    end

    def indent_message(message)
      return message unless indent_level > 0

      message = message.gsub("\n", "\n" + margin)

      return "#{margin}#{message}"
    end

    def margin
      " " * indent_level * space_per_indent
    end
  end
end
