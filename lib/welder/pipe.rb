module Welder
  # A wrapper around a sequence of callables (i.e. anything that responds to a
  # single-argument 'call' method, which includes procs, blocks and other pipes)
  #
  # Pipes are immutable. There are mechanisms to create more complex pipes
  # out of existing ones, but they will always create a new pipe
  class Pipe
    # A domain error indicating that there was an attempt to create a pipe
    # out of a non-callable (e.g. a string)
    CallableExpectedError = Class.new(Exception)

    # Creates a new pipe out of a sequence of callables. If a block is given,
    # it is executed as the last step of the pipe
    #
    # @param lambdas [Array<#call>] Expanded array of callables
    # @param block [Block] A block to execute as the last step in the pipeline
    #
    # @raise [CallableExpectedError] When trying to create a pipe
    #   out of a non-callable
    #
    # @example Create a pipe from an anonymous function
    #   square = Welder::Pipe.new(->(x){ x ** 2 })
    #
    # @example Create a pipe from a module method and a block
    #   square_and_double = Welder::Pipe.new(->(x){ x ** 2 }) { |x| x * 2 }
    def initialize(*lambdas, &block)
      callable!(lambdas)

      @pipes = [*lambdas]
      @pipes << block if block
    end

    # Apply the sequence of functions to a particular input
    #
    # @param input [*] The input for the first element of the pipe(line)
    #
    # @return [*] The output resulting of passing the input through the whole
    #   pipeline
    def call(input)
      @pipes.reduce(input) { |a, e| e.call(a) }
    end

    # Compose a pipe with another one. This method does not modify existing
    # pipes. Instead, it creates a new pipe composed of the previous two
    #
    # @param other [Welder::Pipe] the pipe to be executed after the current one
    #
    # @raise [CallableExpectedError] When trying to create a pipe
    #   out of non-callables
    #
    # @return [Welder::Pipe] a new pipe composed of the current one and 'other',
    #   in that order
    def |(other)
      self.class.new(self, other)
    end

    private

    def callable!(lambdas)
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

# Global Object class all other objects (and hence all literals) inherit from
class Object
  # The bitwise OR operator is overloaded to force the creation and evaluation
  # of a pipeline whose first element is not a pipe, but whose second and
  # further are.
  #
  # For any other case (i.e. a case where Welder::Pipe is not involved), the
  # behavior remains the same. Thus, there is no way for this extension to
  # affect the rest of the application
  def |(other)
    return other.call(self) if other.is_a?(Welder::Pipe) && !is_a?(Welder::Pipe)
    super
  end
end
