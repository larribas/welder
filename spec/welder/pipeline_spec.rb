require 'spec_helper'
require 'welder/pipeline'

describe Welder::Pipeline do
  it 'can be created empty, acting as the identity function' do
    pipeline = Welder::Pipeline.new
    expect(pipeline.call(2)).to eq(2)
  end

  it 'can be created from a block' do
    pipe = Welder::Pipeline.new { |input| input * 2 }
    expect(pipe.call(2)).to eq(4)
  end

  it 'can be created from an anonymous function' do
    pipe = Welder::Pipeline.new(->(input) { input * 2 })
    expect(pipe.call(2)).to eq(4)
  end

  it 'can be created from a function' do
    def some_function(input)
      input * 2
    end

    pipe = Welder::Pipeline.new(method(:some_function))
    expect(pipe.call(2)).to eq(4)
  end

  it 'can be created from a module that responds to "call"' do
    module CallableModule
      def self.call(input)
        input * 2
      end
    end

    pipe = Welder::Pipeline.new(CallableModule)
    expect(pipe.call(2)).to eq(4)
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

    pipe = Welder::Pipeline.new(CallableClass.new(2))
    expect(pipe.call(2)).to eq(4)
  end

  it 'raises an error when creating it with invalid parameters' do
    [
      [:invalid, :parameters],
      [->(_) { 'valid' }, 'invalid']
    ].each do |params|
      expect { Welder::Pipeline.new(*params) }.to(
        raise_error(Welder::Pipeline::CallableExpectedError)
      )
    end
  end

  context 'when composing pipes' do
    let(:parenthesize) { Welder::Pipeline.new(->(input) { "(#{input})" }) }
    let(:quote)        { Welder::Pipeline.new(->(input) { "\"#{input}\"" }) }
    let(:shout)        { Welder::Pipeline.new(->(input) { "#{input}!!" }) }

    it 'composes a series of pipelines using the unix pipe operator' do
      pipeline = parenthesize | quote | shout

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
        expect(literal | parenthesize).to eq(parenthesize.call(literal))
      end
    end
  end

end
