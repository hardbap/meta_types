# encoding: utf-8
#--
# Copyright (c) 2010-2012 Peter Horn, metaminded UG, metaminded.com
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

class MetaTypes::MetaProperties

  include Enumerable

  attr_accessor :_model
  attr_accessor :_hsname
  attr_accessor :_props

  def initialize(model, hsname)
    self._model = model
    self._hsname = hsname
    self._props = meta_type && meta_type.meta_type_properties.ordered.inject({}) do |h, mp|

      h[mp.sid] = MetaTypes::MetaProperty.new(self, mp.sid)

      self.define_singleton_method mp.sid do
        h[mp.sid].value
      end

      self.define_singleton_method "#{mp.sid}=" do |v|
        h[mp.sid].value = v
      end

      h
    end
  end

  def update_attributes(hashh)
    hash = hashh.dup
    date_keys = hash.keys.select{|k| /\([123]i\)\Z/.match(k) }.map{|k|
      k.split("(").first
    }.uniq.each{|k|
      dats = (1..3).map{|i| hash.delete("#{k}(#{i}i)")}.join("-")
      self.send "#{k}=", dats
    }
    hash.each do |k,v|
      self.send "#{k}=", v
    end
  end

  def valid?
    inject([]) do |e, v|
      v.required && v.value.blank? ?
        e << "#{v.label} must be present" :
        e
    end.join(", ").presence
  end

  def persisted?()
    false
  end

  def each()
    _props.each { |k,v| yield(v) }
  end

  def length
    _props.length
  end
  alias_method :count, :length

  def meta_type()
    _model.meta_type
  end

  def set_value(sid, val)
    _model.send "#{_hsname}=", (_model.send("#{_hsname}") || {}).merge(sid => val)
  end

  def get_value(sid)
    _model.send(_hsname).try :[], sid
  end

  def [](sid)
    _props[sid.to_s]
  end

  def column_for_attribute(sid)
    MetaTypeProperty[sid]
  end

  class << self
    def validators_on(sid)
      MetaTypeProperty[sid].required? ?
        [ActiveModel::Validations::PresenceValidator.new(attributes: [:title])] :
        []
    end
  end
end