require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    cols = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        '#{table_name}'
      LIMIT
        0
    SQL
    @columns = cols.first.map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
        self.attributes[column]
      end

      define_method("#{column}=") do |val|
        self.attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
    # ...
  end

  def self.table_name
    return @table_name if @table_name
    self.to_s.downcase + 's'
    # ...
  end

  def self.all
    rows = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    self.parse_all(rows)
    # puts "rows is of class #{rows.class}"
    # puts "row is of class #{rows.first.class}"
    # rows.map do |row|
    #   Cat.new(row.to_h)
    # end
    #self.parse_all(rows)
  end

  def self.parse_all(results)
      results.map do |result|
        Cat.new(result)
      end
  end

  def self.find(id)
    # ...
    result = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = #{id}
    SQL
    if result.empty?
      result = nil
    else
      result = self.new(result.first)
    end
    result
  end

  def initialize(params = {})
    params.each do |key, value|
      setter = "#{key}=".to_sym
      if self.class.columns.include?(key.to_sym)
        self.send(setter, value)
      else
         puts "Current class is #{self.class}"
         puts "Columns: #{self.class.columns}"
         puts "Key: #{key}"
        raise "unknown attribute '#{key}'" unless attributes[key]
      end
    end
  end

  def attributes
    @attributes ||= {}
    # ...
  end

  def attribute_values
    @attributes.values
    # ...
  end

  def insert
    values = self.attribute_values.map do |val|
      "'#{val}'"
    end
    query = DBConnection.execute(<<-SQL)
      INSERT INTO
        #{self.class.table_name} (#{self.attributes.keys.join(", ")})
      VALUES
        (#{values.join(", ")})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_string = self.attributes.map do |key, value|
      "#{key} = '#{value}'"
    end[1..-1].join(", ")
    query = DBConnection.execute(<<-SQL)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_string}
    SQL
  end

  def save
    if self.id
      update
    else
      insert
    end
  end
end
