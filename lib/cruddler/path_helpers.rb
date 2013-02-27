module Cruddler::PathHelpers

  def current_index_path
    cruddler_path_from(cruddler.opts[:index_path]) || if cruddler.nested.present?
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
    cruddler_path_from(cruddler.opts[:after_update_path]) || current_index_path()
  end

  def after_create_path
    cruddler_path_from(cruddler.opts[:after_create_path]) || current_index_path()
  end

  def after_destroy_path
    cruddler_path_from(cruddler.opts[:after_destroy_path]) || current_index_path()
  end

  def locale_key(str)
    (['cruddler'] + current_path_components(cruddler.resource_name,str)).map{|c|
      c.is_a?(String) || c.is_a?(Symbol) ? c : c.class.to_s.underscore
    }.join(".")
  end

  def name_for(record)
    if cruddler.opts[:name] then record.send cruddler.opts[:name]
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
    when :index then current_index_path()
    when :show then current_show_path(obj)
    when :edit then current_show_path(obj)
    when :new then current_new_path()
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
