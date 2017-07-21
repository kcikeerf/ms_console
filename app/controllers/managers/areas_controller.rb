class  Managers::AreasController < ApplicationController
  layout 'manager'
  respond_to :json, :html

  before_action :get_area, only: [:create, :update, :destroy_all]

  def index
  end

  def area_list
    result = Area.area_list
    respond_with(result)
  end

  def create
    begin 
      data = @area.new_area params
      status = 200
    rescue Exception => ex
      status = 500
      data = {:status => 500, :message => ex.message}
    end
    render common_json_response(status, data)
  end

  def update
    begin 
      data = @area.update_area params
      status = 200
    rescue Exception => ex
      status = 500
      data = {:status => 500, :message => ex.message}
    end
    render common_json_response(status, data)
  end

  def destroy_all
    begin
      @area.destroy_area
      status = 200
      data = {:status => 200 }
    rescue Exception => ex
      status = 500
      data = {:status => 500, :message => ex.message}
    end
    render common_json_response(status, data)
  end

  def get_province
    params.permit!
    country_rid = Common::Area::CountryRids["zhong_guo"]
    @country = Area.provinces country_rid
    render :json => @country.children_h.to_json
  end

  def get_city
  	params.permit!
    province_rid = params[:province_rid]

    result =  Area.default_option

    unless params[:province_rid].blank?
      current_province = Area.where("rid = '#{province_rid}'").first
      result = current_province.children_h if current_province 
    end
    render :json => result.to_json
  end

  def get_district
    params.permit!
    city_rid = params[:city_rid]

    result = Area.default_option

    unless params[:city_rid].blank?
      current_city = Area.where("rid = '#{city_rid}'").first
      result = current_city.children_h if current_city
    end
    render :json => result.to_json
  end

  def get_tenants
    params.permit!
    
    result = []

    unless params[:area_rid].blank?
      areas = Area.where("rid LIKE '#{params[:area_rid]}%'")
      result = areas.map{|a| a.tenants}.flatten
      result = result.map{|item| {tenant_uids: item.uid, name_cn: item.name_cn}}
    end

    result.unshift({tenant_uids: "", name_cn: Common::Locale::i18n("managers.messages.tenant.select")})
    render :json => result.to_json
  end

  private
  def get_area
    @area = Area.find(params[:id])
  end

end