# encoding: utf-8

module Cruddler::Controller

  def cruddler(methods, opts={})
    # get the class that's to be used if it can't be guessed from the controller name
    klass = opts[:class] || self.to_s.split("::").last.split("Controller").first.singularize.constantize
    klass_name = klass.to_s.tableize
    pnam = opts[:parameter_name] || klass.to_s.tableize.singularize.gsub('/', '_')
    nam = "@" + pnam

    # if the resource is nested, get the wrapping resources
    # :nested => :masterclass
    # :nested => [:supermasterclassname, :masterclassname]
    # :nested => {:supermasterclassname => SuperMasterClassName, :masterclassname => MasterClassName}
    nested = opts[:nested].presence
    nested = [nested] if nested.is_a?(String) || nested.is_a?(Symbol)
    nested = case nested
    when nil then []
    when Array then Hash[nested.map{|n| [n.to_s, n.to_s.classify.constantize]}]
    when Hash then nested
    else raise "expected :nested Option to get either a list of model-names or a hash name => Class"
    end
    before_filter :cruddler_get_nested if nested
    nested_as = opts[:nested_as] || nested.to_a.last.try(:first)

    # which CRUD methods are to be created?
    methods = case methods
    when :all then [:index, :show, :edit, :update, :new, :create, :destroy]
    when :read then [:index, :show]
    when :none then []
    else [*methods]
    end

    static_path_components = opts[:path_components] || self.to_s.split("::").map(&:underscore)[0..-2]

    define_method :cruddler do
      @_cruddler ||= OpenStruct.new(
          opts: opts,
          model_name: nam,
          klass: klass,
          klass_name: klass_name,
          nested: nested,
          nested_as: nested_as,
          parameter_name: pnam,
          resource_name: self.class.to_s.split("::").last[0..(-11)].tableize.singularize,
          resources_name: self.class.to_s.split("::").last[0..(-11)].tableize,
          find_on: (nested.present? ? cruddler_get_nested.last.send(klass_name.pluralize) : klass)
        )
    end
    private :cruddler

    define_method :resource_name do cruddler.resource_name end
    define_method :resources_name do cruddler.resources_name end
    define_method :cruddler_get_nested do
      nested.map do |nam, nklaz|
        instance_variable_get("@#{nam}") ||
        instance_variable_set("@#{nam}", nklaz.find(params["#{nam}_id"]))
      end
    end

    self.send :include, Cruddler::CrudActions
    %w{index show edit update new create destroy}.each do |method|
      next unless methods.member? method.to_sym
      alias_method method, "cruddler_#{method}_action"
      public method
    end

    # helper
    define_method :current_object do
      instance_variable_get(nam)
    end
    alias_method :cruddler_current_object, :current_object

    define_method :current_path_components do |*args|
      [static_path_components, cruddler_get_nested, args].flatten.compact
    end

    self.send :include, Cruddler::PathHelpers

    helper_method :resource_name, :resources_name,
      :current_index_path, :current_show_path, :current_new_path,
      :current_edit_path,
      :locale_key, :name_for, :current_path_components, :current_name
  end
end

ActionController::Base.send :extend, Cruddler::Controller
