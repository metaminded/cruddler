# encoding: utf-8

class ActionController::Base

  def self.cruddler(methods, opts={})
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

    static_path_components = opts[:path_components] || self.to_s.split("::").map(&:tableize).map(&:singularize)[0..-2]

    define_method :cruddler_find_on do
      find_on = if nested.present?
        n = cruddler_get_nested.last
        n.send(klass_name.pluralize)
      else
        klass
      end
    end

    # index
    define_method :index do
      models = if cruddler_find_on.respond_to? :find_for_table
        cruddler_find_on.find_for_table(params, (opts[:stateful_index] ? {stateful: session} : {}))
      else
        cruddler_find_on.all
      end
      models.each do |m|
        authorize! :read, m
      end if opts[:authorize]
      instance_variable_set(nam.pluralize, models)
    end if methods.member? :index

    # show
    define_method :show do
      m = cruddler_find_on.find(params[:id])
      authorize!(:read, m) if opts[:authorize]
      instance_variable_set(nam, m)
    end if methods.member? :show

    # edit
    define_method :edit do
      m = cruddler_find_on.find(params[:id])
      authorize!(:update, m) if opts[:authorize]
      instance_variable_set(nam, m)
    end if methods.member? :edit

    # update
    define_method :update do
      t = cruddler_find_on.find(params[:id])
      success = t.update_attributes(params[pnam])
      authorize!(:update, t) if opts[:authorize]
      instance_variable_set(nam, t)
      if success
        flash[:notice] = t(locale_key("update_success"))
        redirect_to after_update_path()
      else
        flash[:alert] = t(locale_key("update_problem"))
        render :edit
      end
    end if methods.member? :update

    # new
    define_method :new do
      m = klass.new
      authorize!(:create, m) if opts[:authorize]
      s = instance_variable_set(nam, m)
      nested.to_a.last.try do |name, nklaz|
        m.send("#{nested_as}=", instance_variable_get("@#{name}"))
      end
    end if methods.member? :new

    # create
    define_method :create do
      t = klass.new(params[pnam])
      authorize!(:create, t) if opts[:authorize]
      nested.to_a.last.try do |name, nklaz|
        t.send("#{nested_as}=", instance_variable_get("@#{name}"))
      end
      success = t.save
      instance_variable_set(nam, t)
      if success
        flash[:notice] = t(locale_key("create_success"))
        redirect_to after_create_path()
      else
        flash[:alert] = t(locale_key("create_problem"))
        render :new
      end
    end if methods.member? :create

    # delete
    define_method :destroy do
      m = klass.find(params[:id])
      authorize!(:destroy, m) if opts[:authorize]
      s = instance_variable_set(nam, m)
      s.destroy
      flash[:notice] = t(locale_key("delete_success"))
      redirect_to after_destroy_path()
    end if methods.member? :destroy

    # helper
    define_method :cruddler_get_nested do
      nested.map do |nam, nklaz|
        instance_variable_get("@#{nam}") ||
        instance_variable_set("@#{nam}", nklaz.find(params["#{nam}_id"]))
      end
    end

    define_method :resource_name do
      resources_name().singularize
    end

    define_method :resources_name do
      @resources_name ||= self.class.to_s.split("::").last[0..(-11)].tableize
    end

    define_method :current_index_path do
      cruddler_path_from(opts[:index_path]) || if nested.present?
        edit_polymorphic_path(current_path_components())
      else
        polymorphic_path(current_path_components(resources_name))
      end
    end

    define_method :current_show_path do |obj|
      polymorphic_path(current_path_components(obj))
    end

    define_method :current_edit_path do |obj|
      edit_polymorphic_path(current_path_components(obj))
    end

    define_method :current_new_path do
      new_polymorphic_path(current_path_components(resource_name))
    end

    define_method :after_update_path do
      cruddler_path_from(opts[:after_update_path]) || current_index_path()
    end

    define_method :after_create_path do
      cruddler_path_from(opts[:after_create_path]) || current_index_path()
    end

    define_method :after_destroy_path do
      cruddler_path_from(opts[:after_destroy_path]) || current_index_path()
    end

    define_method :locale_key do |str|
      (['cruddler'] + current_path_components(resource_name,str)).map{|c|
        c.is_a?(String) || c.is_a?(Symbol) ? c : c.class.to_s.underscore
      }.join(".")
    end

    define_method :name_for do |record|
      if opts[:name] then record.send opts[:name]
      elsif record.respond_to?(:name) then record.name
      elsif record.respond_to?(:title) then record.title
      else "**unknown**"
      end
    end

    define_method :cruddler_path_from do |s|
      obj = instance_variable_get(nam)
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
          instance_exec(obj) &s
        else
          raise "Don't know how to deliver more than one parameter."
        end
      when "moo" then raise "haha, sehr witzig"
      else raise "Don't know how to deal with `#{s}`."
      end
    end

    define_method :current_path_components do |*args|
      [static_path_components, cruddler_get_nested, args].flatten.compact
    end

    helper_method :resource_name, :resources_name,
      :current_index_path, :current_show_path, :current_new_path,
      :current_edit_path,
      :locale_key, :name_for, :current_path_components
  end
end
