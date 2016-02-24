require 'spec_helper'
require 'welder/pipe'

describe Welder::Pipe do
  it 'can be created empty, acting as the identity function' do
    pipeline = Welder::Pipe.new
    expect(pipeline.call(2)).to eq(2)
  end

  it 'can be created from a block' do
    pipe = Welder::Pipe.new { |input| input * 2 }
    expect(pipe.call(2)).to eq(4)
  end

  it 'can be created from an anonymous function' do
    pipe = Welder::Pipe.new(->(input) { input * 2 })
    expect(pipe.call(2)).to eq(4)
  end

  it 'can be created from a function' do
    def some_function(input)
      input * 2
    end

    pipe = Welder::Pipe.new(method(:some_function))
    expect(pipe.call(2)).to eq(4)
  end

  it 'can be created from a module that responds to "call"' do
    module CallableModule
      def self.call(input)
        input * 2
      end
    end

    pipe = Welder::Pipe.new(CallableModule)
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

    pipe = Welder::Pipe.new(CallableClass.new(2))
    expect(pipe.call(2)).to eq(4)
  end

  it 'raises an error when creating it with invalid parameters' do
    [
      [:invalid, :parameters],
      [->(_) { 'valid' }, 'invalid']
    ].each do |params|
      expect { Welder::Pipe.new(*params) }.to(
        raise_error(Welder::Pipe::CallableExpectedError)
      )
    end
  end

  context 'when composing pipes' do
    let(:parenthesize) { Welder::Pipe.new(->(input) { "(#{input})" }) }
    let(:quote)        { Welder::Pipe.new(->(input) { "\"#{input}\"" }) }
    let(:shout)        { Welder::Pipe.new(->(input) { "#{input}!!" }) }

    it 'can compose a series of pipes together using the unix pipe operator' do
      pipeline = parenthesize | quote | shout

      expect(pipeline).to be_a(Welder::Pipe)
      expect(pipeline.call('hello world')).to eq('"(hello world)"!!')
    end

    it 'can automatically execute a pipe when the first element is a literal' do
      result = 'hello world' | parenthesize
      expect(result).to eq('(hello world)')
    end
  end
end
