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
end

