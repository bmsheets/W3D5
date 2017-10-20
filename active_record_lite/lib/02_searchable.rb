require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_string = params.map do |key, value|
      "#{key} = '#{value}'"
    end.join(" AND ")

    query = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_string}
    SQL

    self.parse_all(query)
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
