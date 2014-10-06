#--
# Copyright (c) 2010-2014 Peter Horn metaminded UG
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

module Cruddler::PathHelpers

  def current_index_path
    cruddler_path_from(cruddler.index_path) || if cruddler.nested.present?
      edit_polymorphic_path(current_path_components())
    else
      polymorphic_path(current_path_components(cruddler.resources_name))
    end
  end

  def current_show_path(obj=nil)
    obj ||= cruddler_current_object
    polymorphic_path(current_path_components(obj))
  end

  def current_edit_path(obj=nil)
    obj ||= cruddler_current_object
    edit_polymorphic_path(current_path_components(obj))
  end

  def current_new_path
    new_polymorphic_path(current_path_components(cruddler.resource_name))
  end

  def after_update_path
    cruddler_path_from(cruddler.after_update_path) || current_index_path()
  end

  def after_create_path
    cruddler_path_from(cruddler.after_create_path) || current_index_path()
  end

  def after_destroy_path
    cruddler_path_from(cruddler.after_destroy_path) || current_index_path()
  end

  def locale_key(str)
    (['cruddler'] + current_path_components(cruddler.resource_name,str)).map{|c|
      c.is_a?(String) || c.is_a?(Symbol) ? c : c.class.to_s.underscore
    }.join(".")
  end

  def name_for(record)
    if cruddler.name then record.send cruddler.name
    elsif record.respond_to?(:name) then record.name
    elsif record.respond_to?(:title) then record.title
    else "**unknown**"
    end
  end

  def current_name
    return nil unless current_object
    name_for(current_object)
  end

  def cruddler_path_from(s)
    obj = instance_variable_get(cruddler.model_name)
    case s
    when nil, false then nil
    when String then s
    when :index, 'index' then current_index_path()
    when :show, 'show' then current_show_path(obj)
    when :edit, 'edit' then current_edit_path(obj)
    when :new, 'new' then current_new_path()
    when Proc
      if s.arity == 0
        instance_exec(&s)
      elsif s.arity == 1
        instance_exec(obj, &s)
      else
        raise "Don't know how to deliver more than one parameter."
      end
    when "moo" then raise "haha, sehr witzig"
    else raise "Don't know how to deal with `#{s}`."
    end
  end
end
