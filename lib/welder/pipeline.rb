module Welder
  # A wrapper around a sequence of callables (i.e. anything that responds to a
  # single-argument 'call' method, which includes procs, blocks and other
  # pipelines)
  #
  # Pipelines are immutable. There are mechanisms to create more complex
  # pipelines out of existing ones, but they will always create a new pipeline
  class Pipeline
    # A domain error indicating that there was an attempt to create a pipeline
    # out of a non-callable (e.g. a string)
    CallableExpectedError = Class.new(Exception)

    # Creates a new pipe out of a sequence of callables. If a block is given,
    # it is executed as the last step of the pipeline
    #
    # @param lambdas [Array<#call>] Expanded array of callables
    # @param block [Block] A block to execute as the last step in the pipeline
    #
    # @raise [CallableExpectedError] When trying to create a pipeline
    #   out of a non-callable
    #
    # @example Create a pipeline from an anonymous function
    #   square = Welder::Pipeline.new(->(x){ x ** 2 })
    #
    # @example Create a pipeline from a module method and a block
    #   square_and_double = Welder::Pipeline.new(->(x){ x ** 2 }) { |x| x * 2 }
    def initialize(*lambdas, &block)
      callable!(*lambdas)

      @pipes = [*lambdas]
      @pipes << block if block
    end

    # Apply the sequence of functions to a particular input
    #
    # @param input [*] The input for the first element of the pipeline
    #
    # @return [*] The output resulting of passing the input through the whole
    #   pipeline
    def call(input)
      @pipes.reduce(input) { |a, e| e.call(a) }
    end

    # Compose a pipeline with another one. This method does not modify
    # existing pipelines. Instead, it creates a new pipeline composed
    # of the previous two
    #
    # @param other [Welder::Pipeline] the pipeline to be executed after
    #   the current one
    #
    # @raise [CallableExpectedError] When trying to create a pipeline
    #   out of non-callables
    #
    # @return [Welder::Pipeline] a new pipeline composed of the current one and 'other',
    #   in that order
    def |(other)
      self.class.new(self, other)
    end

    private

    # Assert that a series of values are callable (respond to call)
    #
    # @param lambdas [Array<*>] expanded array of values to check
    #
    # @raise [CallableExpectedError] If one or more of the values are
    #   not callable
    def callable!(*lambdas)
      non_callable = lambdas.reject { |lambda| lambda.respond_to?(:call) }
      unless non_callable.empty?
        raise(
          CallableExpectedError,
          "Expected #{non_callable.map(&:to_s).join(', ')} " \
          "to respond to 'call(input)'"
        )
      end
    end
  end
end

[Object, Fixnum, TrueClass, FalseClass].each do |klass|
  # The bitwise OR operator is overloaded to force the creation and evaluation
  # of a pipeline whose first element is not a pipeline, but whose second and
  # further are.
  #
  # For any other case (i.e. a case where Welder::Pipeline is not involved),
  # the behavior remains the same. Thus, there is no way for this extension
  # to affect the rest of the application
  #
  # @param other [*] second argument for the pipeline operator
  #
  # @return [*] an evaluated pipeline (see conditions above) or the expected
  #   behavior for arbitrary objects
  klass.class_eval do
    def |(other)
      if other.is_a?(Welder::Pipeline) && !is_a?(Welder::Pipeline)
        return other.call(self)
      end

      super
    end
  end
end
