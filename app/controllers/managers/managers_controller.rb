# -*- coding: UTF-8 -*-

class Managers::ManagersController < ApplicationController
  layout 'manager_crud'
  respond_to :json, :html

  before_action :get_manager, only: [:update]

  def index
    @managers = Manager.get_list(params)
    respond_with({rows: @managers, total: @managers.total_count})
  end

  def create
    manager = Manager.new(user_params)
    begin
      manager.save!
      status = 200
      data = {:status => 200, :message => "200" }
    rescue Exception => ex
      status = 500
      data = {:status => 500, :message => ex.message}
    end
    render common_json_response(status, data)
  end

  def update
    begin
      if params[:id] == current_manager.id.to_s
        status = 500
        data = {:status => 500, :message => "can not update self"}
      else
        @manager.update!(user_params)
        status = 200
        data = {:status => 200, :message => "200" }
      end
    rescue Exception => ex
      status = 500
      data = {:status => 500, :message => ex.message}
    end
    render common_json_response(status, data)
  end

  def destroy_all
    begin
      if params[:id].include?(current_manager.id.to_s)
        status = 500
        data = {:status => 500, :message => "can not delete self"}
      else
        managers = Manager.where(:id => params[:id])
        managers.each{|manager| manager.destroy!}
        status = 200
        data = {:status => "200"}
      end
    rescue Exception => ex
      status = 500
      data = {:status => 500, :message => ex.message}
    end
    render common_json_response(status, data)
  end

  private
  def get_manager
    @manager = Manager.find(params[:id])
  end

  def user_params
    if params[:user_name]
      params[:name] = params[:user_name]
    end
    params.permit(
      :password,
      :password_confirmation,
      :name,
      :email)
  end
end