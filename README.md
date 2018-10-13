# Cregularity

[![Build Status](https://travis-ci.org/spencerwi/Cregularity.svg?branch=master)](https://travis-ci.org/spencerwi/Cregularity)

A Crystal port of [andrewberls's Regularity gem](https://github.com/andrewberls/regularity/) for Ruby.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  cregularity:
    github: spencerwi/cregularity
```

## Usage

The API basically mirrors the [Regularity gem](https://github.com/andrewberls/regularity/blob/master/README.md), though you instantiate it as `Cregularity.new`.

To borrow one of the original gem's examples:

```crystal
require "cregularity"

re = Cregularity.new
  .start_with(3, :digits)
  .then("-")
  .then(2, :letters)
  .maybe("#")
  .one_of(["a", "b"])
  .between([2,4], "a")
  .end_with("s")

if (re =~ "123-ff#baaas")
  puts "It works!"
end
```

## Development

To run tests: 

```
$ crystal spec
```

## Contributing

1. Fork it (<https://github.com/spencerwi/cregularity/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [spencerwi](https://github.com/spencerwi) - creator, maintainer
- [andrewberls](https://github.com/andrewberls) - the developer of the original gem
