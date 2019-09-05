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

module Cruddler::ApiCrudActions

  module ApiCruddlerData
    def cruddler_coerce_for_json(val)
      case val
      when BigDecimal then val.to_f
      else val
      end
    end

    def cruddler_to_hash(record, attributes)
      return {} unless record
      if record.respond_to?(:map)
        return record.map{|r| cruddler_to_hash(r, attributes)}
      end
      res = {}
      [*attributes].each do |attribute|
        case attribute
        when Symbol then res[attribute.to_sym] = cruddler_coerce_for_json(record.try(attribute))
        when String
          chain = attribute.split('.')
          if chain.length == 1
            res[attribute.to_sym] = cruddler_coerce_for_json(record.try(attribute))
          else
            h = chain[0..-2].inject(res) do |a,e|
              a[e.to_sym] ||= {}
              a[e.to_sym]
            end
            h[chain.last.to_sym] = cruddler_coerce_for_json(chain.inject(record) {|a,e| a.try(e)})
          end
        when Hash
          attribute.each do |k,v|
            res[k.to_sym] = if v.is_a?(Proc)
              if v.arity == 0
                v.()
              else
                v.(record)
              end
            else
              nr = if !record.respond_to?(k) && k.to_s.end_with?('_attributes')
                rr = record.try(k.to_s.split('_attributes').first)
                if rr.nil? then nil
                elsif rr.respond_to?(:to_a)
                  Hash[
                    record.try(k.to_s.split('_attributes').first).map do |assoc|
                      [assoc.id, cruddler_to_hash(assoc, v)]
                    end
                  ]
                else
                  cruddler_to_hash(rr, v)
                end
              else
                record.try(k)
                cruddler_to_hash(nr, v)
              end
            end
          end
        else raise "What is #{attribute} (#{attribute.clas})?"
        end
      end
      res
    end

    def cruddler_render_api_response(data, status=200)
      respond_to do |format|
        format.json { render json: data, status: status }
        format.xml  { render xml: data, status: status }
        format.html { render html: '<h1>Unsupported Format</h1><p>only <tt>application/json</tt> or <tt>application/xml</tt>.</p>'.html_safe, status: 406 }
      end
    end

    def cruddler_render_api_error(data, status)
      cruddler_render_api_response(data, status)
    end
  end

  module Index
    def cruddler_data_for_index
      connection = ActiveRecord::Base.connection
      order_by = params[:order_by] || cruddler.order_by
      order = params[:order] || cruddler.ordder || 'asc'
      limit = params[:limit] || cruddler.limit
      filter = params[:filter].try(:permit!).try(:to_hash) || cruddler.filter || {}
      @data = cruddler_find_on
      filter.symbolize_keys.each do |k, vv|
        k = connection.quote_column_name(k[/[\w\.]*/])
        if vv.is_a?(Hash)
          vv.each do |op, v|
            case op
            when *%w{= < <= > >= <>} then @data = @data.where("#{k} #{op} ?", v)
            when *%w{like ilike} then @data = @data.where("#{k} #{op} ?", "%#{v}%")
            else raise "illegal operand #{op}"
            end
          end
        else
          @data = @data.where(k => vv.to_s)
        end
      end
      @data = @data.order(order_by => order)
      @data = @data.limit(limit) if limit
      # @data = @data.map{|record| cruddler_to_hash(record, cruddler.index_params)}
      @data
    end

    def index
      if cruddler.authorize
        authorize! :read, cruddler.klass.new
      end
      data = cruddler_to_hash cruddler_data_for_index, cruddler.index_attributes
      cruddler_render_api_response(data)
    end
  end

  module Show
    def show
      # return render('/cruddler/describe', layout: false) if params[:id] == 'describe'
      m = cruddler_find_on.find(params[:id])
      authorize!(:read, m) if cruddler.authorize
      data = cruddler_to_hash m, cruddler.show_attributes
      cruddler_render_api_response(data)
    end
  end

  module Update
    def update
      t = cruddler_find_on.find(params[:id])
      if cruddler.authorize && !can?(:update, t)
        return cruddler_render_api_error('not permitted', 401)
      end
      success = nil
      begin
        success = t.update_attributes(cruddler_params)
      rescue Exception => e
        return cruddler_render_api_error(e.message, 500)
      end
      if success
        data = cruddler_to_hash t, cruddler.show_attributes
        cruddler_render_api_response(data)
      else
        data = t.errors.full_messages
        cruddler_render_api_error(data, 422)
      end
    end
  end

  module Create
    def create
      t = cruddler.klass.new(cruddler_params)
      instance_variable_set(cruddler.model_name, t)
      if cruddler.authorize && !can?(:create, t)
        return cruddler_render_api_error('not permitted', 401)
      end
      cruddler.nested.to_a.last.try do |name, nklaz|
        t.try("#{cruddler.nested_as}=", instance_variable_get("@#{name}"))
      end
      success = nil
      begin
        success = t.save
      rescue Exception => e
        return cruddler_render_api_error(e.message, 500)
      end
      if success
        data = cruddler_to_hash t, cruddler.show_attributes
        cruddler_render_api_response(data)
      else
        data = t.errors.full_messages
        cruddler_render_api_error(data, 422)
      end
    end
  end

  module Destroy
    def destroy
      s = cruddler.klass.find(params[:id])
      authorize!(:destroy, s) if cruddler.authorize
      begin
        s.destroy
      rescue Exception => e
        return cruddler_render_api_error(e.message, 500)
      end
      return cruddler_render_api_response('deleted')
    end
  end


end
