module Welder
  module Support
    # A domain error indicating that there was an attempt to create
    # a pipeline out of a non-callable (e.g. a string)
    CallableExpectedError = Class.new(Exception)

    # Mixin that provides several utilities to handle callable objects
    module CallableHandler
      # Assert that a series of values are callable (respond to call)
      #
      # @param lambdas [Array<*>] Array of values to check
      #
      # @raise [CallableExpectedError] If one or more of the values are
      #   not callable
      def callable!(*lambdas)
        non_callable = lambdas.reject { |lambda| lambda.respond_to?(:call) }
        unless non_callable.empty?
          raise(
            CallableExpectedError,
            "Expected #{non_callable.map(&:to_s).join(', ')} " \
        "to respond to 'call'"
          )
        end
      end
    end
  end
end
