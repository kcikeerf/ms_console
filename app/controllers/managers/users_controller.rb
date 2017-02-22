class Managers::UsersController < ApplicationController

  respond_to :json, :html

  layout 'manager_crud'

  before_action :set_user, only: [:update]

  def index
    @users = User.get_list params
    respond_with({rows: @users, total: @users.total_count}) 
  end

  def create
    @user = User.new
    result_flag = @user.save_user(user_params)
    status_code = result_flag ? 200 : 500
    render status: status_code, json: response_json_by_obj(result_flag, @user)
  end

  def update
    result_flag = @user.save_user(user_params)
    status_code = result_flag ? 200 : 500
    render status: status_code, json: response_json_by_obj(result_flag, @user)
  end

  def destroy_all
    User.destroy(params[:id])
    respond_with(@user)
  end

  private

    def set_user
      @user = User.where(id: params[:id]).first
    end

    def user_params
      params.permit(
        :id, 
        :name, 
        :password, 
        :password_confirmation,         
        :real_name,
        :gender,
        :my_number,
        :subject,
        :grade, 
        :role_id, 
        :qq, 
        :phone, 
        :email, 
        :desc,
        :province_rid,
        :city_rid,
        :district_rid,
        :skope_ids => [],
        :tenant_uids => [],
        :loc_uids => []
      )
    end
end
