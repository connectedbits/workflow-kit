# Spot Feel

A DMN FEEL implementation in Ruby

This gem implements a subset of FEEL (Friendly Enough Expression Language) as defined in the [DMN 1.3 specification](https://www.omg.org/spec/DMN/1.3/PDF) with some additional extensions.

FEEL expressions are parsed into an abstract syntax tree (AST) and then evaluated in a context. The context is a hash of variables that are available to the expression. Expressions can also invoke built-in and user-defined functions.

Expressions are safe, side-effect free, and deterministic. They are ideal for capturing business logic for storage in a database or embedded in DMN or BPMN documents for execution in a workflow engine like [SpotFlow](https://github.com/connectedbits/spot_flow).

This project was inspired by these excellent libraries:

- [feelin](https://github.com/nikku/feelin)
- [dmn-eval-js](https://github.com/mineko-io/dmn-eval-js)

## Usage

To evaluate an expression:

```ruby
SpotFeel.eval('"Paul" in ["John", "Paul", "George", "Ringo"]')
# => true

SpotFeel.eval('if (actual_speed - speed_limit) > 5 then "violation" else "no ticket"', context: { actual_speed: 85, speed_limit: 65 })
# => "violation"
```

To evaluate a unary test:

```ruby
SpotFeel.test(21, '>= 18, <= 65')
# => true
```

To evaluate a DMN document:

```ruby
decisions = SpotFeel.decisions_from_xml(File.read('dinner.xml'))
SpotFeel.decide(decisions, id: 'beverages', context: { season: 'Fall', guests: 4, children: true })
# => { beverages: ['Bourbon', 'Apple Juice'] }
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

### Unary Tests

### Built-in Functions

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
