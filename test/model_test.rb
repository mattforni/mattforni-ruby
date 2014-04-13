require 'test_helper'

class ModelTest < ActiveSupport::TestCase
  protected

  def test_association_belongs_to(model, field, target)
    clazz = model.class
    assert_respond_to model, field, "#{clazz} cannot find associated #{field}"

    one = model.send(field)
    assert_not_nil one, "#{clazz} does not have associated #{field}"
    assert_equal target, one, "#{field.to_s.capitalize} associated with this #{clazz.to_s.downcase} is not the target #{field}"
  end

  def test_association_has_many(model, field, targets)
    clazz = model.class
    assert_respond_to model, field, "#{clazz} cannot find associated #{field}"

    many = model.send(field)
    assert !(many.nil? || many.empty?), "#{clazz} does not have associated #{field}"
    assert_equal targets.size, many.size, "#{clazz} does not have #{targets.size} associated #{field}"
  end

  # TODO implement support for :allow_nil flag
  def test_delegation(model, delegated_to, delegated)
    clazz = model.class
    assert_respond_to model, delegated, "#{clazz} does not respond to #{delegated}"
    assert_equal delegated_to.send(delegated), model.send(delegated), "Delegated objects do not match"
  end

  # TODO needs more work before being functional
  def test_field_in_range(model, field, range)
    # For each range evaluate validity
    Ranges.get_expressions(range).each_pair do |name, range|
      puts "Evaluating range #{name}"
      # Modify the field in question according to the expression
      model.send("#{field}#{range[:expression]}")

      # Assert the model is invalid and will not save
      clazz = model.class
      assert !model.valid?, "#{clazz} is considered valid"
      assert !model.save, "#{clazz} saved with a #{field} #{range[:message]}"
      assert model.errors[field].any?, "#{clazz} does not have an error on #{field}"
    end
  end

  def test_field_presence(model, field)
    # Null out the field to test
    model.send("#{field}=", nil)

    # Assert the model is invalid and will not save
    clazz = model.class
    assert !model.valid?, "#{clazz} is considered valid"
    assert !model.save, "#{clazz} saved without #{field} field"
    assert model.errors[field].any?, "#{clazz} does not have an error on #{field}"
  end

  def test_field_uniqueness(model, field)
    # Create a duplicate of the model
    dup = model.class.send(:new)
    dup.initialize_dup(model)

    # Assert the duplicate is invalid based on the field
    clazz = dup.class
    assert !dup.valid?, "#{clazz} is considered valid"
    assert !dup.save, "#{clazz} saved with a duplicate #{field}"
    assert dup.errors[field].any?, "#{clazz} does not have an error on #{field}"
  end

  module Ranges
    EXPRESSIONS = {
      greater_than: {expression: '= %{value}', message: 'equal to'},
      greater_than_or_equal_to: {expression: '= %{value}-1', message: 'less than'},
      less_than: {expression: '= %{value}', message: 'equal to'},
      less_than_or_equal_to: {expression: '= %{value}+1', message: 'greater than'},
    }

    def self.get_expressions(range)
      expressions = range.reduce({}) do |expressions, (name, value)|
        if !EXPRESSIONS.has_key?(name)
          puts "There is no range expression for #{name}"
          continue
        end
        expression = EXPRESSIONS[name]
        expressions[name] = {
          expression: expression[:expression] % {value: value},
          message: "#{expression[:message]} #{value}"
        }
      end
      expressions
    end
  end
end

