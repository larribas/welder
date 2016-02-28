require 'welder/support/callable_handler'

module Welder
  # A wrapper around a sequence of callables (i.e. anything that responds to a
  # single-argument 'call' method, which includes procs, blocks and other
  # pipelines)
  #
  # Pipelines are immutable. There are mechanisms to create more complex
  # pipelines out of existing ones, but they will always create a new pipeline
  class Pipeline
    include Support::CallableHandler

    # Creates a new pipeline out of a sequence of callables. If a block is
    # given, it is executed as the last step of the pipeline.
    # It also accepts valves, with act as witnesses of the steps the pipeline
    # goes through
    #
    # @param lambdas [Array<#call>] Array of callables accepting 1 argument
    # @param valves [Array<#call>] Array of callables accepting 3 arguments
    # @param block [Block] A block to execute as the last step in the pipeline
    #
    # @raise [CallableExpectedError] When trying to create a pipeline
    #   out of a non-callable
    #
    # @example Create an empty pipeline (with no steps)
    #   square_and_double = Welder::Pipeline.new
    #
    # @example Create a pipeline from an anonymous function
    #   square = Welder::Pipeline.new(->(x){ x ** 2 })
    #
    # @example Create a pipeline from a block
    #   square_and_double = Welder::Pipeline.new { |x| x ** 2 }
    def initialize(*lambdas, valves: nil, &block)
      callable!(*lambdas, *valves)

      @pipes = [*lambdas]
      @pipes << block if block

      @valves = [*valves]
    end

    # Apply the sequence of functions to a particular input. Any valves
    # present in the pipeline are called as a side effect
    #
    # @param input [*] The input for the first element of the pipeline
    # @param valves [Array<#call>] An array of valves to be called at every
    #   step of the pipeline
    #
    # @return [*] The output resulting of passing the input through the whole
    #   pipeline
    def call(input, valves = [])
      valves = @valves.concat(valves)

      @pipes.reduce(input) do |a, e|
        if e.is_a?(Pipeline)
          e.call(a, valves)
        else
          e.call(a).tap do |output|
            valves.each { |valve| valve.call(a, e, output) }
          end
        end
      end
    end

    # Compose a pipeline with another one (or a callable). This method does not
    # modify existing pipelines. Instead, it creates a new pipeline composed
    # of the previous two
    #
    # @param other [#call] The callable to add as the last step of the
    #   pipeline, which has to accept 1 argument
    #
    # @raise [CallableExpectedError] When trying to create a pipeline
    #   out of non-callables
    #
    # @return [Welder::Pipeline] a new pipeline composed of the current
    #   one and 'other', in that order
    def |(other)
      self.class.new(self, other)
    end

    # Create a new pipeline that keeps all the steps in the current one,
    # but adds a valve overseeing the process. The valve will get called
    # at every stage, as a side effect, but it will never modify the final
    # outcome of the pipeline
    #
    # @param other [#call] The callable to invoke at every step of the
    #   pipeline. It must accept 3 arguments: (input, lambda, output)
    def -(other)
      self.class.new(self, valves: [*other])
    end
  end
end

WELDER_SAVED_PIPE_METHODS = {}
[Object, Fixnum, TrueClass, FalseClass].each do |klass|

  WELDER_SAVED_PIPE_METHODS[klass] = begin
    klass.instance_method(:|)
  rescue NameError
    nil
  end

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
  klass.class_eval <<EOF
    def |(other)
      if other.is_a?(Welder::Pipeline) && !is_a?(Welder::Pipeline)
        return other.call(self)
      end

      WELDER_SAVED_PIPE_METHODS[#{klass}].bind(self).call(other) if WELDER_SAVED_PIPE_METHODS[#{klass}]
    end
EOF
end
