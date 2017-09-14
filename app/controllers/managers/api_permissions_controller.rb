# -*- coding: UTF-8 -*-

class Managers::ApiPermissionsController < ApplicationController

  layout 'manager_crud'
  respond_to :json, :html

  before_action :set_roles, only: [:create, :update]

  def index
    @api_permissions = ApiPermission.get_list params
    respond_with({rows: @api_permissions, total: @api_permissions.total_count})
  end

  def create
    begin
      ApiPermission.create_ins(api_permission_params,@roles)
      status = 200
      data = {:status => 200, :message => "200" }
    rescue Exception => e
      status = 500
      data = {:status => 500, :message => e.message}
    end
    render common_json_response(status, data)
  end

  def update
    begin
      api_permission = ApiPermission.find(params[:id])
      api_permission.update_ins(api_permission_params,@roles)
      status = 200
      data = {:status => 200, :message => '200' }
    rescue Exception => e
      status = 500
      data = {:status => 500, :message => e.message}
    end
    render common_json_response(status, data)
  end

  def destroy_all
   begin
      api_permissions = ApiPermission.where(:id => params[:id])
      api_permissions.each{|api_permission| api_permission.destroy!}
      status = 200
      data = {:status => 200, :message => '200' }
    rescue Exception => e
      status = 500
      data = {:status => 500, :message => e.message}
    end
    render common_json_response(status, data)
  end

  private
  def api_permission_params
    params.permit(
      :name,
      :method,
      :path,
      :description)
  end

  def set_roles
    @roles = Role.where(name: params[:roles])
  end
end