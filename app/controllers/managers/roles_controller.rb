class Managers::RolesController < ApplicationController
	respond_to :json, :html

	layout 'manager_crud', except: [:show]

	

	before_action :set_role, only: [:show, :edit, :update]
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
		@permissions = @role.roles_permissions_links.includes(:permission)
		render layout: 'manager'
	end

	def update
		render json: response_json_by_obj(@role.update(role_params), @role)
	end

	def destroy_all
		Role.destroy(params[:id])
		respond_with(@role)
	end

	private

	def set_role
		@role = Role.find(params[:id])
	end

	def role_params
		params.permit(:name, :desc)
	end

end
