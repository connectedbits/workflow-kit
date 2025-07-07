# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Structure

WorkflowKit is a monorepo containing three Ruby gems for business process management:

- **feel/**: FEEL (Friendly Enough Expression Language) - Expression evaluation engine
- **dmn/**: DMN (Decision Model and Notation) - Business rules engine using FEEL
- **bpmn/**: BPMN (Business Process Model and Notation) - Process execution engine using DMN and FEEL

The gems have dependencies: BPMN depends on DMN, and DMN depends on FEEL.

## Development Commands

### Testing

```bash
# Run tests for all gems
rake test

# Run tests for a specific gem
cd feel && rake test
cd dmn && rake test
cd bpmn && rake test
```

### Building and Releasing

```bash
# Build all gems
rake release

# Build a specific gem
cd feel && rake release
cd dmn && rake release
cd bpmn && rake release
```

### Dependencies

```bash
# Install dependencies for all gems
bundle install

# Install dependencies for a specific gem
cd feel && bundle install
cd dmn && bundle install
cd bpmn && bundle install
```

## Architecture Overview

### FEEL (feel/)

- Core expression parser using Treetop grammar
- Evaluates FEEL expressions and unary tests
- Key files: `lib/feel/parser.rb`, `lib/feel/literal_expression.rb`, `lib/feel/unary_tests.rb`
- Grammar definition: `lib/feel/feel.treetop`

### DMN (dmn/)

- Decision table evaluation engine
- Uses FEEL for expression evaluation
- Key files: `lib/dmn/decision_table.rb`, `lib/dmn/decision.rb`, `lib/dmn/definitions.rb`
- Supports XML and JSON input formats via xmlhasher

### BPMN (bpmn/)

- Process execution engine with serializable state
- Supports various task types: UserTask, ServiceTask, BusinessRuleTask, ScriptTask
- Process flow control with gateways: Exclusive, Parallel, Inclusive, Event-based
- Key files: `lib/bpmn/execution.rb`, `lib/bpmn/process.rb`, `lib/bpmn/context.rb`
- Task definitions: `lib/bpmn/task.rb`, `lib/bpmn/event.rb`, `lib/bpmn/gateway.rb`

## Key Concepts

### Process Execution (BPMN)

- Processes can be started with `BPMN.new(sources).start`
- State can be serialized/restored with `execution.serialize` and `BPMN.restore`
- Tasks can be signaled to continue: `step.signal(variables)`

### Decision Evaluation (DMN)

- Decisions evaluated with `DMN.decide(decision_id, definitions_xml:, variables:)`
- Uses FEEL expressions in decision table rules

### Expression Evaluation (FEEL)

- Expressions: `FEEL.evaluate(expression, variables:)`
- Unary tests: `FEEL.test(input, unary_tests, variables:)`

## Test Structure

- Each gem has comprehensive test coverage in `test/` directories
- Fixtures stored in `test/fixtures/files/` with .bpmn, .dmn, and .form files
- Tests use standard Ruby TestCase framework
