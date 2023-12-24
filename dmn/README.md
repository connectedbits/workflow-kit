# Spot Feel

A light-weight DMN FEEL expression evaluator and business rule engine in Ruby.

This gem implements a subset of FEEL (Friendly Enough Expression Language) as defined in the [DMN 1.3 specification](https://www.omg.org/spec/DMN/1.3/PDF) with some additional extensions.

FEEL expressions are parsed into an abstract syntax tree (AST) and then evaluated in a context. The context is a hash of variables and functions to be resolved inside the expression.

Expressions are safe, side-effect free, and deterministic. They are ideal for capturing business logic for storage in a database or embedded in DMN, BPMN, or Form documents for execution in a workflow engine like [spot-flow](https://github.com/connectedbits/spot_flow).

This project was inspired by these excellent libraries:

- [feelin](https://github.com/nikku/feelin)
- [dmn-eval-js](https://github.com/mineko-io/dmn-eval-js)

## Usage

To evaluate an expression:

```ruby
context = { name: "World" }
SpotFeel.eval('"👋 Hello " + name', context:)
# => "👋 Hello World"
```

A slightly more complex example:

```ruby
context = {
  person: {
    name: "Eric",
    age: 59,
  }
}
SpotFeel.eval('if person.age >= 18 then "adult" else "minor"', context:)
# => "adult"
```

Calling a built-in function:

```ruby
SpotFeel.eval('sum([1, 2, 3])')
# => 6
```

Calling a user-defined function:

```ruby
context = {
  "reverse": ->(s) { s.reverse }
}
SpotFeel.eval('reverse("Hello World!")', context:)
# => "!dlroW olleH"
```

To evaluate a unary tests:

```ruby
SpotFeel.test(3, '<= 10, > 50'))
# => true
```

```ruby
SpotFeel.test("Eric", '"Bob", "Holly", "Eric"')
# => true
```

To evaluate a DMN decision table:

```ruby
decisions = SpotFeel.decisions_from_xml(fixture_source("fine.dmn"))
context = {
  violation: {
    type: "speed",
    actual_speed: 100,
    speed_limit: 65,
  }
}
result = SpotFeel::Dmn::Decision.decide('fine_decision', decisions:, context:)
# => { "amount" => 1000, "points" => 7 })
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
- [x] Function Invocation
- [x] Positional Parameters
- [x] If Expression
- [ ] For Expression
- [ ] Quantified Expression
- [ ] Filter Expression
- [ ] Disjunction
- [ ] Conjuction
- [ ] Instance Of
- [ ] Function Definition

### Unary Tests

- [x] Comparison
- [x] Interval/Range (inclusive and exclusive)
- [x] Disjunction
- [x] Negation
- [ ] Expression

### Built-in Functions

- [x] Conversion: `string`, `number`
- [x] Boolean: `is defined`, `get or else`
- [x] String: `substring`, `substring before`, `substring after`, `string length`, `upper case`, `lower case`, `contains`, `starts with`, `ends with`, `matches`, `replace`, `split`, `strip`, `extract`
- [x] Numeric: `decimal`, `floor`, `ceiling`, `round`, `abs`, `modulo`, `sqrt`, `log`, `exp`, `odd`, `even`, `random number`
- [x] List: `list contains`, `count`, `min`, `max`, `sum`, `product`, `mean`, `median`, `stddev`, `mode`, `all`, `any`, `sublist`, `append`, `concatenate`, `insert before`, `remove`, `reverse`, `index of`, `union`, `distinct values`, `duplicate values`, `flatten`, `sort`, `string join`
- [x] Context: `get entries`, `get value`, `get keys`
- [x] Temporal: `now`, `today`, `day of week`, `day of year`, `month of year`, `week of year`

### DMN

- [x] Parse DMN XML documents
- [x] Evaluate DMN Decision Tables
- [ ] Evaluate dependent DMN Decision Tables
- [ ] Evaluate Expression Decisions

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
