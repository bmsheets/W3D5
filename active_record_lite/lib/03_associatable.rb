require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
    # ...
  end

  def table_name
    @class_name.constantize.table_name
    # ...
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    self.send(:foreign_key=, "#{name}_id".underscore.to_sym)
    self.send(:class_name=, name.to_s.singularize.camelcase)
    self.send(:primary_key=, :id)

    options.each do |key, value|
      setter = "#{key}="
      self.send(setter, value)
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    self.send(:foreign_key=, "#{self_class_name}_id".underscore.to_sym)
    self.send(:class_name=, name.to_s.singularize.camelcase)
    self.send(:primary_key=, :id)

    options.each do |key, value|
      setter = "#{key}="
      self.send(setter, value)
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method(name) do
      foreign_key = self.class.send(options.foreign_key)
      model_class = options.model_class
      model_class.where(options.primary_key => foreign_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, options)
    define_method(name) do
      model_class = options.model_class
      foreign_key = model_class.send(options.foreign_key)
      where(options.primary_key => foreign_key).first
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
