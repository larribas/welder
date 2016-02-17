# Welder

[![Gem Version](https://badge.fury.io/rb/welder.svg)](https://badge.fury.io/rb/welder)
[![Build Status](https://travis-ci.org/rb-welder/welder.svg?branch=master)](https://travis-ci.org/rb-welder/welder)
[![Code Climate](https://codeclimate.com/github/rb-welder/welder/badges/gpa.svg)](https://codeclimate.com/github/rb-welder/welder)
[![Test Coverage](https://codeclimate.com/github/rb-welder/welder/badges/coverage.svg)](https://codeclimate.com/github/rb-welder/welder/coverage)
[![Dependency Status](https://gemnasium.com/rb-welder/welder.svg)](https://gemnasium.com/rb-welder/welder)
[![Inline docs](http://inch-ci.org/github/rb-welder/welder.svg?branch=master)](http://inch-ci.org/github/rb-welder/welder)

**Welder** allows you to define pipelines in a true [Unix style](https://en.wikipedia.org/wiki/Pipeline_(Unix)).

It provides a simple and powerful DSL to define you own pipes and compose them together. You can either define the pipeline and call it later as many times as you want:
```ruby
pipeline = read_file | count_words | pretty_print
pipeline.call('my_book.txt')
# => 3423
```

Or provide some initial input to the pipe and execute it in place:
```ruby
puts "Book 'my_book.txt' has #{'my_book.txt' | read_file | count_words} words"
```



## Why pipelines?

In some use cases, pipelines have several advantages over the natural, imperative style of languages like ruby. Take, for instance, the following example:
```ruby
puts "Book 'my_book.txt' has #{'my_book.txt' | read_file | count_words} words"
```

Here, the alternative way to write the word count would be `count_words(File.read('my_book.txt'))`. Pipelines, in contrast:
* Provide a cleaner syntax that is better at expressing the statement's **order and intent**
* Ease the instrumentation of the whole process (e.g. for debugging and benchmarking purposes)
* Allow for ways to abstract the way the different stages in the pipeline are called. For instance, creating pipelines of remote methods using RPC


## Present and Future

Welder is still at welding school. The next steps in his career will be:
* Learning about pipes and how to connect them together
* Testing and refining her skills
* Getting a nice toolbelt to start her work (extra gems with useful pipes our of the box)
* Creating a professional profile (gem and docs) so that people can hire her


## Contributing to Welder

Welder is open for help in any way.



## License

See LICENSE file