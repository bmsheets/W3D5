class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    names.each do |name|

      var = "@#{name}"
      # puts "Name is #{name} and of class #{name.class}"
      # puts "Var is #{var} and of class #{var.class}"
      define_method(name) do
        instance_variable_get(var)
      end

      name = (name.to_s + '=').to_sym
      define_method(name) do |val|
        instance_variable_set(var, val)
      end
    end
  end
end
