class Managers::RolesController < ApplicationController
	respond_to :json, :html

	layout 'manager_crud', except: [:show]

	

	before_action :set_role, only: [:show, :edit, :update, :update_permission, :update_api_permission]
    # skip_before_action :authenticate_person!
    # before_action :authenticate_manager

	def index
		#@data = {name: '角色', path: '/managers/roles'}

		conditions = []
	  [:name].each{
	    |attr| conditions << Role.send(:sanitize_sql, ["#{attr} LIKE ?", "%#{params[attr]}%"]) unless params[attr].blank? } 
	  conditions = conditions.any? ? conditions.collect { |c| "(#{c})" }.join(' AND ') : nil
		@roles = Role.where(conditions).page(params[:page]).per(params[:rows])
		respond_with({rows: @roles, total: @roles.total_count}) 
	end

	def create
		@role = Role.new(role_params)
		render json: response_json_by_obj(@role.save, @role)
	end

	def show
		@permissions = @role.permissions.sort
		@no_permissions = Permission.where.not(id: @role.permissions.pluck(:id)).sort
		@api_permissions = @role.api_permissions.sort_by(&:path)
		@no_api_permissions = ApiPermission.where.not(id: @role.api_permissions.pluck(:id)).sort_by(&:path)
		render layout: 'manager'
	end

	def update
		render json: response_json_by_obj(@role.update(role_params), @role)
	end

	def destroy_all
		Role.destroy(params[:id])
		respond_with(@role)
	end

  def get_list
    roles = Role.all.select(:name)
    render :json => roles
  end

  def update_permission
  	permission = Permission.find(params[:permission_id])
  	case params[:method_type]
  	when 'add'
  		@role.permissions << permission
  	when 'del'
  		@role.permissions.destroy(permission)
  	end
  	result = permission.attributes
  	result['permission_name'] = permission.permission_name
  	render :json => result
  end

  def update_api_permission
  	api_permission = ApiPermission.find(params[:permission_id])
  	case params[:method_type]
  	when 'add'
  		@role.api_permissions << api_permission
  	when 'del'
  		@role.api_permissions.destroy(api_permission)
  	end
  	@role.delete_role_auth_redis
  	render :json => api_permission
  end

	private

	def set_role
		@role = Role.find(params[:id])
	end

	def role_params
		params.permit(:name, :desc)
	end

end
