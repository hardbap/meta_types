class MetaTypes::MetaPropertyType

  attr_accessor :sid
  attr_accessor :name

  def initialize(sid, name)
    self.sid = sid
    self.name = name
  end

  Instances = {
    integer: new('integer', 'Integer'),
    string:  new('string',  'String'),
    boolean: new('boolean', 'Boolean'),
    float:   new('float',   'Float'),
    text:    new('text',    'Text')
  }

  BoolTrueReps = %w{1 t true}

  def cast(sval)
    puts ">> cast '#{sid}': '#{sval}'"
    case sid
    when 'integer' then sval.to_i
    when 'string', 'text' then sval
    when 'boolean' then BoolTrueReps.member?(sval.to_s)
    when 'float'   then sval.to_f
    else raise "Don't know how to handle MetaPropertyType with sid '#{sid}'."
    end
  end

  def parse(sval)
    puts ">> parse '#{sid}': '#{sval}'"
    case sid
    when 'integer' then sval.to_s
    when 'string', 'text' then sval.to_s
    when 'boolean' then BoolTrueReps.member?(sval.to_s)
    when 'float'   then sval.to_s
    else raise "Don't know how to handle MetaPropertyType with sid '#{sid}'."
    end
  end

  class << self
    def find(sid)
      Instances[sid.to_sym] || raise("No MetaPropertyType with sid '#{sid}' found.")
    end

    alias_method :[], :find

    def sids() %w{integer string boolean float text} end
  end

end

