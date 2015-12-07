class BenchmarkSpec
  module DSL
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      def change_global_dsl(context, &changes)
        (class << context; self; end).class_exec(&changes)
      end

      def expose_method_dsl_to_context(method, context)
        change_global_dsl(context) do
          remove_method(method) if method_defined?(method)
          define_method(method) do |*a, &b|
            BenchmarkSpec.__send__(method, *a, &b)
          end
        end
      end

      def expose_methods_to_context(methods, context)
        methods.each {|meth| expose_method_dsl_to_context(meth, context)}
      end
    end
  end
end
