class BenchmarkSpec
  module SharedContext
    def self.included(klass)
      klass.class_eval do
        @@shared_context ||= {}

        class << klass
          def shared_context(context_name, &block)
            @@shared_context[context_name] = block
          end
        end
        
      end
    end

    def include_context(context_name)
      raise "Shared context #{context_name.to_s} does not exist!" if @@shared_context[context_name].nil?
      instance_eval &@@shared_context[context_name]
    end
  end
end
