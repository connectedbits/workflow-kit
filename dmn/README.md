# Spot Feel

A DMN FEEL implementation in Ruby

This gem implements a subset of FEEL (Friendly Enough Expression Language) as defined in the [DMN 1.3 specification](https://www.omg.org/spec/DMN/1.3/PDF) with some additional extensions.

FEEL expressions are parsed into an abstract syntax tree (AST) and then evaluated in a context. The context is a hash of variables that are available to the expression. Expressions can also invoke built-in and user-defined functions.

Expressions are safe, side-effect free, and deterministic. They are ideal for capturing business logic for storage in a database or embedded in DMN or BPMN documents for execution in a workflow engine like [spot-flow](https://github.com/connectedbits/spot_flow).

This project was inspired by these excellent libraries:

- [feelin](https://github.com/nikku/feelin)
- [dmn-eval-js](https://github.com/mineko-io/dmn-eval-js)

## Usage

To evaluate an expression:

```ruby
SpotFeel.eval('if actual_speed >= 75 then "violation" else "no ticket"', context: { actual_speed: 85, speed_limit: 65 })
# => "violation"
```

To evaluate a unary test:

```ruby
SpotFeel.test(21, '>= 18')
# => true
```

To evaluate a DMN document:

```ruby
decisions = SpotFeel.decisions_from_xml(File.read('fine.xml'))
SpotFeel.decide(decisions, id: 'fine', context: { type: "speed", actual_speed: 100, speed_limit: 65 } })
# => { "amount" => 1000, "points" => 7 }
```

## Supported Features

### Data Types

- [x] Boolean (true, false)
- [x] Number (integer, decimal)
- [x] String (single and double quoted)
- [x] Date, Time, Duration (ISO 8601)
- [x] List (array)
- [x] Context (hash)

### Expressions

- [x] Literal
- [x] Path
- [x] Arithmetic
- [x] Comparison
- [ ] Conjuction & Disjunction
- [x] Function Invocation
- [x] Positional Parameters
- [x] If Expression
- [ ] For Expression
- [ ] Quantified Expression
- [ ] Filter Expression
- [ ] Instance Of

### Unary Tests

- [x] Comparison
- [x] Interval/Range (inclusive and exclusive)
- [x] Disjunction
- [x] Negation
- [ ] Expression

### Built-in Functions

Spot Feel implements the following built-in functions (custom functions can be added to the context)

#### Conversion

- [x] string
- [x] number

#### Boolean

- [x] is defined
- [x] get or else

#### String

- [x] substring
- [x] substring before
- [x] substring after
- [x] string length
- [x] upper case
- [x] lower case
- [x] contains
- [x] starts with
- [x] ends with
- [x] matches
- [x] replace
- [x] split

#### Numeric

- [x] decimal
- [x] floor
- [x] ceiling
- [x] round up
- [x] round down
- [x] abs
- [x] modulo
- [x] sqrt
- [x] log
- [x] exp
- [x] odd
- [x] even
- [x] random

#### List

- [x] list contains
- [x] count
- [x] min
- [x] max
- [x] sum
- [x] product
- [x] mean
- [x] median
- [x] stddev
- [x] mode
- [x] all
- [x] any
- [x] sublist
- [x] append
- [x] concatenate
- [x] insert before
- [x] remove
- [x] reverse
- [x] index of
- [x] union
- [x] distinct values
- [x] duplicate values
- [x] flatten
- [x] sort
- [x] string join

#### Context

- [x] get value
- [x] context put
- [x] context merge

#### Temporal

- [x] now
- [x] today
- [x] day of week
- [x] day of year
- [x] week of year
- [x] month of year

### DMN

- [x] Parse DMN XML
- [x] Evaluate DMN Decision Tables

## Installation

Execute:

```bash
$ bundle add "spot_feel"
```

Or install it directly:

```bash
$ gem install spot_feel
```

### Setup

```bash
$ git clone ...
$ bin/setup
$ bin/guard
```

## Development

[Treetop Doumentation](https://cjheath.github.io/treetop/syntactic_recognition.html) is a good place to start learning about Treetop.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

Developed by [Connected Bits](http://www.connectedbits.com)
