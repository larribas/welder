require 'spec_helper'
require 'welder/pipeline'

describe Welder::Pipeline do
  it 'can be created empty, acting as the identity function' do
    pipeline = Welder::Pipeline.new
    expect(pipeline.call(2)).to eq(2)
  end

  it 'can be created from a block' do
    pipeline = Welder::Pipeline.new { |input| input * 2 }
    expect(pipeline.call(2)).to eq(4)
  end

  it 'can be created from an anonymous function' do
    pipeline = Welder::Pipeline.new(->(input) { input * 2 })
    expect(pipeline.call(2)).to eq(4)
  end

  it 'can be created from a function' do
    def some_function(input)
      input * 2
    end

    pipeline = Welder::Pipeline.new(method(:some_function))
    expect(pipeline.call(2)).to eq(4)
  end

  it 'can be created from a module that responds to "call"' do
    module CallableModule
      def self.call(input)
        input * 2
      end
    end

    pipeline = Welder::Pipeline.new(CallableModule)
    expect(pipeline.call(2)).to eq(4)
  end

  it 'can be created from a class instance that responds to "call"' do
    class CallableClass
      def initialize(multiplier)
        @multiplier = multiplier
      end

      def call(input)
        input * @multiplier
      end
    end

    pipeline = Welder::Pipeline.new(CallableClass.new(2))
    expect(pipeline.call(2)).to eq(4)
  end

  it 'raises an error when creating it with invalid parameters' do
    [
      [:invalid, :parameters],
      [->(_) { 'valid' }, 'invalid']
    ].each do |params|
      expect { Welder::Pipeline.new(*params) }.to(
        raise_error(Welder::Support::CallableExpectedError)
      )
    end
  end

  context 'when composing pipelines' do
    let(:parenthesize) { ->(input) { "(#{input})" } }
    let(:quote)        { ->(input) { "\"#{input}\"" } }
    let(:shout)        { ->(input) { "#{input}!!" } }

    it 'composes a series of pipelines using the unix pipe operator' do
      pipeline = Welder::Pipeline.new | parenthesize | quote | shout

      expect(pipeline).to be_a(Welder::Pipeline)
      expect(pipeline.call('hello world')).to eq('"(hello world)"!!')
    end

    it 'executes a pipeline when the first element is a literal' do
      [
        'hello world',
        2,
        2.5,
        true,
        Class.new,      # classes and modules
        Class.new.new,  # class instances
      ].each do |literal|
        expect(literal | Welder::Pipeline.new(parenthesize))
          .to eq(parenthesize.call(literal))
      end
    end

    context 'when adding valves to the pipeline' do
      # Logger Valve
      let(:logged_steps) { [] }
      let(:log) { ->(inp, lambda, out) { logged_steps << [inp, lambda, out] } }

      # Pipeline with logging
      let(:pipeline_with_valve) do
        (Welder::Pipeline.new | quote | parenthesize) - log
      end

      before { logged_steps.clear }

      it 'gets called at every step in the pipeline' do
        output = 'input' | pipeline_with_valve

        expect(output).to eq('("input")')
        expect(logged_steps).to contain_exactly(
          ['input', anything, '"input"'],
          ['"input"', anything, '("input")']
        )
      end

      it 'can be added to a pipeline along with other valves' do
        times_witnessed = 0
        valve = ->(*) { times_witnessed += 1 }

        1 | pipeline_with_valve - valve - valve
        expect(times_witnessed).to eq(4)
      end

      it 'only affects the pipeline it was originally added to' do
        pipeline = ((Welder::Pipeline.new | quote) - log) | parenthesize
        output = 'input' | pipeline

        expect(output).to eq('("input")')
        expect(logged_steps).to contain_exactly(
          ['input', anything, '"input"']
        )
      end
    end
  end
end
