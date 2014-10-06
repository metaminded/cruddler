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

module Cruddler::CrudActions

  module Index
    def index
      if cruddler.authorize
        authorize! :read, cruddler.klass.new
      end
      models = if cruddler.use_tabulatr != false && cruddler_find_on.respond_to?(:tabulatr)
        tabulatr_for cruddler_find_on
      else
        cruddler_find_on.all
      end
      instance_variable_set(cruddler.model_name.pluralize, models)
    end
  end

  module Show
    def show
      m = cruddler_find_on.find(params[:id])
      authorize!(:read, m) if cruddler.authorize
      instance_variable_set(cruddler.model_name, m)
    end
  end

  module Edit
    def edit
      m = cruddler_find_on.find(params[:id])
      authorize!(:update, m) if cruddler.authorize
      instance_variable_set(cruddler.model_name, m)
    end
  end

  module Update
    def update
      t = cruddler_find_on.find(params[:id])
      instance_variable_set(cruddler.model_name, t)
      if cruddler.authorize && !can?(:update, t)
        flash[:notice] = t(locale_key("authorization_problem"))
        return render(:edit)
      end
      success = t.update_attributes(cruddler_params)
      if success
        flash[:notice] = t(locale_key("update_success"))
        redirect_to after_update_path()
      else
        flash[:alert] = t(locale_key("update_problem"))
        render :edit
      end
    end
  end

  module New
    def new
      m = cruddler.klass.new
      authorize!(:create, m) if cruddler.authorize
      s = instance_variable_set(cruddler.model_name, m)
      cruddler.nested.to_a.last.try do |name, nklaz|
        m.send("#{cruddler.nested_as}=", instance_variable_get("@#{name}"))
      end
    end
  end

  module Create
    def create
      t = cruddler.klass.new(cruddler_params)
      instance_variable_set(cruddler.model_name, t)
      if cruddler.authorize && !can?(:create, t)
        flash[:notice] = t(locale_key("authorization_problem"))
        return render(:new)
      end
      cruddler.nested.to_a.last.try do |name, nklaz|
        t.send("#{cruddler.nested_as}=", instance_variable_get("@#{name}"))
      end
      success = t.save
      if success
        flash[:notice] = t(locale_key("create_success"))
        redirect_to after_create_path()
      else
        flash[:alert] = t(locale_key("create_problem"))
        render :new
      end
    end
  end

  module Destroy
    def destroy
      m = cruddler.klass.find(params[:id])
      authorize!(:destroy, m) if cruddler.authorize
      s = instance_variable_set(cruddler.model_name, m)
      s.destroy
      flash[:notice] = t(locale_key("delete_success"))
      redirect_to after_destroy_path()
    end
  end
end
