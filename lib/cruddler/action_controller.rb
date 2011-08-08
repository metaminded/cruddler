# encoding: utf-8

class ActionController::Base

  def self.cruddler(methods, opts={})
    klass = opts[:class] || self.to_s.split("::").last.split("Controller").first.singularize.constantize
    klass_name = klass.to_s.tableize
    nested = opts[:nested].present? ? opts[:nested].to_s : nil
    nested_class = nested ? nested.classify.constantize : nil
    methods = [:index, :show, :edit, :update, :new, :create, :delete] if methods == :all
    methods = [methods] unless methods.is_a?(Array)
    pnam = klass.to_s.tableize.singularize
    nam = "@" + pnam

    # index
    define_method :index do
      if nested
        n = cruddler_get_nested
        instance_variable_set(nam.pluralize, n.send(klass_name.pluralize).find_for_table(params))
      else
        instance_variable_set(nam.pluralize, klass.find_for_table(params))
      end
    end if methods.member? :index

    # show
    define_method :show do
      cruddler_get_nested if nested
      instance_variable_set(nam, klass.find(params[:id]))
    end if methods.member? :show

    # edit
    define_method :edit do
      cruddler_get_nested if nested
      instance_variable_set(nam, klass.find(params[:id]))
    end if methods.member? :edit

    # update
    define_method :update do
      cruddler_get_nested if nested
      t = klass.find(params[:id])
      success = t.update_attributes(params[pnam])
      instance_variable_set(nam, t)
      if success
        flash[:notice] = t(locale_key("update_success"))
        redirect_to current_index_path()
      else
        flash[:alert] = t(locale_key("update_problem"))
        render :edit
      end
    end if methods.member? :update

    # new
    define_method :new do
      s = instance_variable_set(nam, klass.new)
      if nested
        n = cruddler_get_nested
        s.send("#{nested}=", n)
      end
    end if methods.member? :new

    # create
    define_method :create do
      t = klass.new(params[pnam])
      if nested
        n = cruddler_get_nested
        t.send("#{nested}=", n)
      end
      success = t.save
      instance_variable_set(nam, t)
      if success
        flash[:notice] = t(locale_key("create_success"))
        redirect_to current_index_path()
      else
        flash[:alert] = t(locale_key("create_problem"))
        render :new
      end
    end if methods.member? :create

    # delete
    define_method :delete do
      cruddler_get_nested if nested
      s = instance_variable_set(nam, klass.find(params[:id]))
      s.destroy
      flash[:notice] = t(locale_key("delete_success"))
      redirect_to current_index_path()
    end if methods.member? :delete

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
      @current_path_components ||= self.class.to_s.split("::").map(&:tableize).map(&:singularize)[0..-2]
      (@current_path_components + args).compact
    end

    helper_method :resource_name, :resources_name,
      :current_index_path, :current_show_path, :current_new_path,
      :locale_key, :name_for, :current_path_components
  end

end