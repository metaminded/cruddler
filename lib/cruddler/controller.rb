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

module Cruddler::Controller

  def cruddler(methods,
      klass:              nil,
      parameter_name:     nil,
      nested:             nil,
      nested_as:          nil,
      resources_name:     nil,
      resource_name:      nil,
      path_components:    nil,
      stateful_index:     nil,
      authorize:          nil,
      index_path:         nil,
      after_destroy_path: nil,
      after_create_path:  nil,
      after_update_path:  nil,
      name:               nil,
      use_tabulatr:       nil,
      permit_params:      nil,
      default_order:      nil,
      default_scope:      nil,
      &params_block)
    # get the class that's to be used if it can't be guessed from the controller name
    klass ||= self.to_s.split("::").last.split("Controller").first.singularize.constantize
    klass_name = klass.to_s.tableize
    parameter_name  ||=  klass.to_s.tableize.singularize.gsub('/', '_')
    nam = "@" + parameter_name

    # if the resource is nested, get the wrapping resources
    # :nested => :masterclass
    # :nested => [:supermasterclassname, :masterclassname]
    # :nested => {:supermasterclassname => SuperMasterClassName, :masterclassname => MasterClassName}
    nested = nested.presence
    nested = [nested] if nested.is_a?(String) || nested.is_a?(Symbol)
    nested = case nested
    when nil then []
    when Array then Hash[nested.map{|n| [n.to_s, n.to_s.classify.constantize]}]
    when Hash then nested
    else raise "expected :nested Option to get either a list of model-names or a hash name => Class"
    end
    before_action :cruddler_get_nested if nested
    nested_as ||= nested.to_a.last.try(:first)

    # which CRUD methods are to be created?
    methods = case methods
    when :all then [:index, :show, :edit, :update, :new, :create, :destroy]
    when :read then [:index, :show]
    when :none then []
    else [*methods].flatten
    end

    resources_name  ||= self.to_s.split("::").last[0..(-11)].tableize
    resource_name   ||= resources_name.singularize
    path_components ||= self.to_s.split("::").map(&:underscore)[0..-2]

    # This module will be included later on
    mod = Module.new

    if block_given?
      raise "Don't give :permit_params option if block is given" if permit_params
      mod.send :define_method, "#{parameter_name}_params" do
        self.instance_eval &params_block
      end
      # private "#{parameter_name}_params"
    elsif permit_params == :all
      mod.send :define_method, "#{parameter_name}_params" do
        params.required(parameter_name.to_sym).permit!
      end
    elsif permit_params.is_a? Proc
      mod.send :define_method, "#{parameter_name}_params" do
        pp = self.instance_exec(&permit_params)
        params.required(parameter_name.to_sym).permit(pp)
      end
    elsif permit_params
      mod.send :define_method, "#{parameter_name}_params" do
        if(klass.respond_to?(:translated_attrs))
          permit_params = Array(permit_params).flatten
          translatable_attrs = klass.translated_attrs.select{|a| permit_params.include?(a)}
          permit_params += klass.translation_names_for(translatable_attrs)
        end
        params.required(parameter_name.to_sym).permit(permit_params)
      end
    else
      if klass.respond_to? :permitted_attributes
        mod.send :define_method, "#{parameter_name}_params" do
          params.required(parameter_name.to_sym).permit(klass.permitted_attributes)
        end
      end
    end

    mod.send :define_method, :cruddler_params do
      if self.respond_to? "#{parameter_name}_params"
        self.send "#{parameter_name}_params"
      else
        raise "Either give a block to cruddler, the :permit_params option, add `permitted_attributes` in the model, or implement method `#{parameter_name}_params`."
      end
    end
    # private :cruddler_params

    mod.send :define_method, :cruddler do
      @_cruddler ||= OpenStruct.new(
          model_name:         nam,
          klass:              klass,
          klass_name:         klass_name,
          nested:             nested,
          nested_as:          nested_as,
          parameter_name:     parameter_name,
          resource_name:      resource_name,
          resources_name:     resources_name,
          stateful_index:     stateful_index,
          authorize:          authorize,
          index_path:         index_path,
          after_destroy_path: after_destroy_path,
          after_create_path:  after_create_path,
          after_update_path:  after_update_path,
          name:               name,
          use_tabulatr:       use_tabulatr,
          default_order:      default_order,
          default_scope:      default_scope,
        )
    end

    mod.send :define_method, :cruddler_find_on do
      rel = if !nested.present?
        klass
      else
        (cruddler_get_nested.last.send(klass_name.pluralize) rescue klass)
      end
      if default_scope && default_scope.respond_to?(:call)
        rel = default_scope.call(rel)
      elsif default_scope
        rel = rel.send(default_scope)
      end
      rel
    end

    mod.send :define_method, :resource_name do cruddler.resource_name end
    mod.send :define_method, :resources_name do cruddler.resources_name end
    mod.send :define_method, :cruddler_get_nested do
      nested.map do |nam, nklaz|
        next unless params["#{nam}_id"]
        instance_variable_get("@#{nam}") ||
        instance_variable_set("@#{nam}", nklaz.find(params["#{nam}_id"]))
      end
    end

    # helper
    mod.send :define_method, :current_object do
      instance_variable_get(nam)
    end
    mod.send :alias_method, :cruddler_current_object, :current_object

    mod.send :define_method, :current_path_components do |*args|
      l = [path_components, cruddler_get_nested, args].flatten.compact
      l.map{|a| a.is_a?(String) ? a.to_sym : a}
    end

    self.send :include, Cruddler::PathHelpers
    self.send :include, mod

    # inlude the desired CRUD actions. There's always just one method per module
    %w{index show edit update new create destroy}.each do |method|
      next unless methods.member? method.to_sym
      include "Cruddler::CrudActions::#{method.capitalize}".constantize
    end

    helper_method :resource_name, :resources_name,
      :current_index_path, :current_show_path, :current_new_path,
      :current_edit_path, :cruddler, :current_object,
      :locale_key, :name_for, :current_path_components, :current_name
  end
end

ActionController::Base.send :extend, Cruddler::Controller
