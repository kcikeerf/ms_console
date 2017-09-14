class Managers::RolePermissionsController < ApplicationController

	respond_to :json, :html

	layout 'manager'

	before_action :set_role , only: [:new, :create, :destroy, :destroy_api_permission]
    # skip_before_action :authenticate_person!
    # before_action :authenticate_manager
    
	def new
		@permissions = Permission.where('id not in (?)', @role.permissions.pluck(:id))
		@api_permissions = ApiPermission.where('id not in (?)',@role.api_permissions.pluck(:id))
	end

	def create
		@role.roles_permissions_links.create(permission_params[:permission]) if permission_params[:permission].present?
		@role.roles_api_permissions_links.create(permission_params[:api_permission]) if permission_params[:api_permission].present?
		redirect_to managers_role_path(@role)
	end

	def destroy
		@role_permission = RolesPermissionsLink.find(params[:id])
		@role.roles_permissions_links.destroy(@role_permission)
	end

	def destroy_api_permission
		@api_permission = ApiPermission.find(params[:id])
		@role.api_permissions.destroy(@api_permission)
	end

	private

	def set_role
		@role = Role.find(params[:role_id])
	end

	def permission_params
		params.permit(:role_id, permission: [:permission_id],api_permission: [:api_permission_id])
	end
end
