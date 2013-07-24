module Cruddler::CrudActions

  private

  # index
  def cruddler_index_action
    models = if cruddler.use_tabulatr != false && cruddler_find_on.respond_to?(:find_for_table)
      cruddler_find_on.find_for_table(params, (cruddler.stateful_index ? {stateful: session} : {}))
    else
      cruddler_find_on.all
    end
    models.each do |m|
      authorize! :read, m
    end if cruddler.authorize
    instance_variable_set(cruddler.model_name.pluralize, models)
  end

  # show
  def cruddler_show_action
    m = cruddler_find_on.find(params[:id])
    authorize!(:read, m) if cruddler.authorize
    instance_variable_set(cruddler.model_name, m)
  end

  # edit
  def cruddler_edit_action
    m = cruddler_find_on.find(params[:id])
    authorize!(:update, m) if cruddler.authorize
    instance_variable_set(cruddler.model_name, m)
  end

  # update
  def cruddler_update_action
    t = cruddler_find_on.find(params[:id])
    authorize!(:update, t) if cruddler.authorize
    success = t.update_attributes(cruddler_params)
    instance_variable_set(cruddler.model_name, t)
    if success
      flash[:notice] = t(locale_key("update_success"))
      redirect_to after_update_path()
    else
      flash[:alert] = t(locale_key("update_problem"))
      render :edit
    end
  end

  # new
  def cruddler_new_action
    m = cruddler.klass.new
    authorize!(:create, m) if cruddler.authorize
    s = instance_variable_set(cruddler.model_name, m)
    cruddler.nested.to_a.last.try do |name, nklaz|
      m.send("#{cruddler.nested_as}=", instance_variable_get("@#{name}"))
    end
  end

  # create
  def cruddler_create_action
    t = cruddler.klass.new(cruddler_params)
    authorize!(:create, t) if cruddler.authorize
    cruddler.nested.to_a.last.try do |name, nklaz|
      t.send("#{cruddler.nested_as}=", instance_variable_get("@#{name}"))
    end
    success = t.save
    instance_variable_set(cruddler.model_name, t)
    if success
      flash[:notice] = t(locale_key("create_success"))
      redirect_to after_create_path()
    else
      flash[:alert] = t(locale_key("create_problem"))
      render :new
    end
  end

  # delete
  def cruddler_destroy_action
    m = cruddler.klass.find(params[:id])
    authorize!(:destroy, m) if cruddler.authorize
    s = instance_variable_set(cruddler.model_name, m)
    s.destroy
    flash[:notice] = t(locale_key("delete_success"))
    redirect_to after_destroy_path()
  end
end
