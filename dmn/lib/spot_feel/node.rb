# frozen_string_literal: true

module SpotFeel
  class Node < Treetop::Runtime::SyntaxNode
  end

  class Addition < Node
    def eval(context = {})
      head.eval(context) + tail.eval(context)
    end
  end

  class BooleanLiteral < Node
    def eval(_context = {})
      case text_value
      when "true"
        true
      when "false"
        false
      end
    end
  end

  class ClosedIntervalEnd < Node
    def eval(_context = {})
      text_value.strip
    end
  end

  class ClosedIntervalStart < Node
    def eval(_context = {})
      text_value.strip
    end
  end

  class Comparison < Node
    def eval(context = {})
      case operator.text_value
      when '<' then left.eval(context) < right.eval(context)
      when '<=' then left.eval(context) <= right.eval(context)
      when '>=' then left.eval(context) >= right.eval(context)
      when '>' then left.eval(context) > right.eval(context)
      when '!=' then left.eval(context) != right.eval(context)
      when '=' then left.eval(context) == right.eval(context)
      end
    end
  end

  class Context < Node
    def eval(context = {})
      if context_entry_list.present?
        context_entry_list.eval(context)
      else
        {}
      end
    end
  end

  class ContextEntryList < Node
    def eval(context = {})
      context_entries.inject({}) do |hash, entry|
        hash.merge(entry.eval(context))
      end
    end

    def context_entries
      [context_entry] + tail.elements.map { |e| e.context_entry }
    end
  end

  class ContextEntry < Node
    def eval(context = {})
      { context_key.eval(context) => context_value.eval(context) }
    end
  end

  class DateTimeLiteral < Node
    def eval(_context = {})
      val = str_val.text_value.strip.delete_prefix('"').delete_suffix('"')
      case keyword.text_value
      when "date and time"
        DateTime.parse(val)
      when "date"
        Date.parse(val)
      when "time"
        Time.parse(val)
      when "duration"
        ActiveSupport::Duration.parse(val)
      end
    end
  end

  class Division < Node
    def eval(context = {})
      head.eval(context) / tail.eval(context)
    end
  end

  class Exponentiation < Node
    def eval(context = {})
      head.eval(context) ** tail.eval(context)
    end
  end

  class FunctionInvocation < Node
    def eval(context = {})
      fn = context[fn_name.text_value.to_sym]
      raise "Undefined function: #{fn_name.text_value}" unless fn

      params = if positional_parameters.present?
        positional_parameters.eval(context)
      else
        []
      end

      fn.call(*params)
    end
  end

  class Interval < Node
    def eval(context = {})
      start = start_token.text_value
      finish = end_token.text_value
      first_val = first.eval(context)
      second_val = second.eval(context)

      case [start, finish]
      when ['(', ')']
        ->(input) { first_val < input && input < second_val }
      when ['[', ']']
        ->(input) { first_val <= input && input <= second_val }
      when ['(', ']']
        ->(input) { first_val < input && input <= second_val }
      when ['[', ')']
        ->(input) { first_val <= input && input < second_val }
      end
    end
  end

  class List < Node
    def eval(context = {})
      if list_entries.present?
        list_entries.eval(context)
      else
        []
      end
    end
  end

  class ListEntries < Node
    def eval(context = {})
      expressions.inject([]) { |arr, exp| arr << exp.eval(context) }
    end

    def expressions
      [expression] + more_expressions.elements.map { |e| e.expression }
    end
  end

  class Multiplication < Node
    def eval(context = {})
      head.eval(context) * tail.eval(context)
    end
  end

  class Name < Node
    def eval(_context = {})
      #head + tail.map{|t| t[1]}.join("")
      puts "Name?"
      puts text_value.strip
      text_value.strip
    end
  end

  class NullLiteral < Node
    def eval(_context = {})
      nil
    end
  end

  class NumericLiteral < Node
    def eval(_context = {})
      if text_value.include?(".")
        text_value.to_f
      else
        text_value.to_i
      end
    end
  end

  class OpenIntervalEnd < Node
    def eval(_context = {})
      text_value.strip
    end
  end

  class OpenIntervalStart < Node
    def eval(_context = {})
      text_value.strip
    end
  end

  class PositionalParameters < Node
    def eval(context = {})
      expressions.inject([]) { |arr, exp| arr << exp.eval(context) }
    end

    def expressions
      [expression] + more_expressions.elements.map { |e| e.expression }
    end
  end

  class QualifiedName < Node
    def eval(context = {})
      if tail.empty?
        context[head.text_value.to_sym]
      else
        tail.elements.flat_map { |element| element.name.text_value.split('.') }.inject(context[head.text_value.to_sym]) do |hash, key|
          hash[key.to_sym]
        end
      end
    end
  end

  class SimpleExpressions < Node
    def eval(context = {})
      [expr.eval(context)] + more_exprs.elements.map { |element| element.eval(context) }
    end
  end

  class SimplePositiveUnaryTest < Node
    def eval(context = {})
      operator = head.text_value.strip
      endpoint = tail.eval(context)
      case operator
      when "<"
        ->(input) { input < endpoint }
      when "<="
        ->(input) { input <= endpoint }
      when ">"
        ->(input) { input > endpoint }
      when ">="
        ->(input) { input >= endpoint }
      else
        ->(input) { input == endpoint }
      end
    end
  end

  class SimplePositiveUnaryTests < Node
    def eval(context = {})
      tests.inject([]) { |arr, exp| arr << exp.eval(context) }
    end

    def tests
      [test] + more_tests.elements.map { |e| e.expression }
    end
  end

  class SimpleUnaryTests < Node
    def eval(context = {})
      if defined?(expr) && expr.present?
        tests = Array.wrap(expr.eval(context))
        if defined?(negate) && negate.present?
          ->(input) { !tests.any? { |test| test.call(input) } }
        else
          ->(input) { tests.any? { |test| test.call(input) } }
        end
      else
        ->(_input) { true }
      end
    end
  end

  class StringLiteral < Node
    def eval(_context = {})
      text_value[1..-2]
    end
  end

  class Subtraction < Node
    def eval(context = {})
      head.eval(context) - tail.eval(context)
    end
  end

  class UnaryOperator < Treetop::Runtime::SyntaxNode
    def eval(_context = {})
      text_value.strip
    end
  end
end
