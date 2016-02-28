# Welder

[![Gem Version](https://badge.fury.io/rb/welder.svg)](https://badge.fury.io/rb/welder)
[![Build Status](https://travis-ci.org/rb-welder/welder.svg?branch=master)](https://travis-ci.org/rb-welder/welder)
[![Code Climate](https://codeclimate.com/github/rb-welder/welder/badges/gpa.svg)](https://codeclimate.com/github/rb-welder/welder)
[![Test Coverage](https://codeclimate.com/github/rb-welder/welder/badges/coverage.svg)](https://codeclimate.com/github/rb-welder/welder/coverage)
[![Dependency Status](https://gemnasium.com/rb-welder/welder.svg)](https://gemnasium.com/rb-welder/welder)
[![Inline docs](http://inch-ci.org/github/rb-welder/welder.svg?branch=master)](http://inch-ci.org/github/rb-welder/welder)

**Welder** allows you to define pipelines in a true [Unix style](https://en.wikipedia.org/wiki/Pipeline_(Unix)).

It provides a simple and powerful DSL to define you own pipelines and compose them together. You can define a pipeline out of one or more ruby callables:
```ruby
read_file = ->(filename) { File.read(filename) }
count_words = ->(text) { text.split.size }

count_words_from_file = Welder::Pipeline.new | read_file | count_words  # Define a pipeline
puts "My book has #{'my_book.txt' | count_words_from_file} words"       # Execute it with a specific value
```

_Note that, for the pipe operator to work, the first argument has to be a Welder::Pipeline_


## Why pipelines?
In some use cases, pipelines have several advantages over the natural, imperative style of languages like ruby. Take, for instance, the following example:
```ruby
puts "My book has #{'my_book.txt' | read_file | count_words} words"
```

Here, the alternative way to write the word count would be `count_words(read_file('my_book.txt'))`. Pipelines, in contrast:
* Provide a cleaner syntax that is better at expressing the statement's **order and intent**
* Ease the instrumentation of the whole process (e.g. for debugging and benchmarking purposes)
* Allow for ways to abstract the way the different stages in the pipeline are called. For instance, creating pipelines of remote methods using RPC


## Valves
Valves are callables that get called at every step of a pipeline with the input to the step, the function processing it, and the generated output. Valves are useful for logging, debugging and code instrumentation. You set valves like this:
```ruby
logged_steps = []
log = ->(i, l, o) { logged_steps << "Executed step #{l.inspect} with input=#{i.inspect} and got #{o.inspect}" }
count_words_and_log_steps = (Welder::Pipeline.new | read_file | count_words) -log

'my_book.txt' | count_words_and_log_steps
puts logged_steps.size  # => 2
puts logged_steps[0]    # Executed step "..." with input="my_book.txt" and output="this is my book"
puts logged_steps[1]    # Executed step "..." with input="this is my book" and output=4
```


## Present and Future
The next step for Welder will be getting a nice toolbelt to start his work (extra gems with useful pipelines our of the box)


## Contributing to Welder
Welder is open for help in any way.


## License
See LICENSE file