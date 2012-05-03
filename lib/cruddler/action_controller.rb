# encoding: utf-8

class ActionController::Base

  def self.cruddler(methods, opts={})
    # get the class that's to be used if it can't be guessed from the controller name
    klass = opts[:class] || self.to_s.split("::").last.split("Controller").first.singularize.constantize
    klass_name = klass.to_s.tableize
    pnam = klass.to_s.tableize.singularize
    nam = "@" + pnam

    # if the resource is nested, get the wrapping resources
    # :nested => :masterclass
    # :nested => [:supermasterclassname, :masterclassname]
    # :nested => {:supermasterclassname => SuperMasterClassName, :masterclassname => MasterClassName}
    nested = opts[:nested].presence
    nested = [nested] if nested.is_a?(String) || nested.is_a?(Symbol)
    nested = case nested
    when nil then nil
    when Array then Hash[nested.map{|n| [n.to_s, n.pluralize.classify.constantize]}]
    when Hash then nested
    else raise "expected :nested Option to get either a list of model-names or a hash name => Class"
    end
    before_filter :cruddler_get_nested if nested

    # which CRUD methods are to be created?
    methods = case methods
    when :all then [:index, :show, :edit, :update, :new, :create, :destroy]
    when :read then [:index, :show]
    when :none then []
    else [*methods]
    end

    current_path_components = opts[:path_components] || self.to_s.split("::").map(&:tableize).map(&:singularize)[0..-2]

    # index
    define_method :index do
      models = if nested
        n = cruddler_get_nested
        n.send(klass_name.pluralize).find_for_table(params)
      else
        klass.find_for_table(params)
      end
      models.each do |m|
        authorize! :read, m
      end if opts[:authorize]
      instance_variable_set(nam.pluralize, models)
    end if methods.member? :index

    # show
    define_method :show do
      cruddler_get_nested if nested
      m = klass.find(params[:id])
      authorize!(:read, m) if opts[:authorize]
      instance_variable_set(nam, m)
    end if methods.member? :show

    # edit
    define_method :edit do
      cruddler_get_nested if nested
      m = klass.find(params[:id])
      authorize!(:update, m) if opts[:authorize]
      instance_variable_set(nam, m)
    end if methods.member? :edit

    # update
    define_method :update do
      cruddler_get_nested if nested
      t = klass.find(params[:id])
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
      if nested
        n = cruddler_get_nested
        s.send("#{nested}=", n)
      end
    end if methods.member? :new

    # create
    define_method :create do
      t = klass.new(params[pnam])
      authorize!(:create, t) if opts[:authorize]
      if nested
        n = cruddler_get_nested
        t.send("#{nested}=", n)
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
      cruddler_get_nested if nested
      m = klass.find(params[:id])
      authorize!(:destroy, m) if opts[:authorize]
      s = instance_variable_set(nam, m)
      s.destroy
      flash[:notice] = t(locale_key("delete_success"))
      redirect_to after_destroy_path()
    end if methods.member? :destroy

    # helper
    define_method :cruddler_get_nested do
      return nil unless nested
      instance_variable_get("@#{nested}") ||
      instance_variable_set("@#{nested}", nested_class.find(params["#{nested}_id"]))
    end

    define_method :resource_name do
      resources_name().singularize
    end

    define_method :resources_name do
      @resources_name ||= self.class.to_s.split("::").last[0..(-11)].tableize
    end

    define_method :current_index_path do
      if nested
        edit_polymorphic_path(current_path_components(cruddler_get_nested))
      else
        polymorphic_path(current_path_components(resources_name))
      end
    end

    define_method :current_show_path do |obj|
      polymorphic_path(current_path_components(obj))
    end

    define_method :current_edit_path do |obj|
      edit_polymorphic_path(current_path_components(cruddler_get_nested,obj))
    end

    define_method :current_new_path do
      new_polymorphic_path(current_path_components(resource_name))
    end

    define_method :after_update_path do
      current_index_path()
    end

    define_method :after_create_path do
      current_index_path()
    end

    define_method :after_destroy_path do
      current_index_path()
    end

    define_method :locale_key do |str|
      (['cruddler'] + current_path_components(resource_name,str)).join(".")
    end

    define_method :name_for do |record|
      if record.respond_to?(:name) then record.name
      elsif record.respond_to?(:title) then record.title
      else "**unknown**"
      end
    end

    define_method :current_path_components do |*args|
      (current_path_components + args).compact
    end

    helper_method :resource_name, :resources_name,
      :current_index_path, :current_show_path, :current_new_path,
      :locale_key, :name_for, :current_path_components
  end

end
