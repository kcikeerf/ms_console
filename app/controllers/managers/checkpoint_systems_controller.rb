class Managers::CheckpointSystemsController < ApplicationController
	layout 'manager_crud', only: [:index]

  respond_to :json, :html
  before_action :get_checkpoint_system, only: [:edit, :update]

	
	def index
    @checkpoint_systems = CheckpointSystem.page(params[:page]).per(params[:rows])
    respond_with({rows: @checkpoint_systems, total: @checkpoint_systems.total_count})
	end

  def create

    status = 403
    data = {:status => 403 }

    @checkpoint_system = CheckpointSystem.new
    begin
      @checkpoint_system.save_ckp_system(checkpoint_system_params)
      status = 200
      data = {:status => 200 }
    rescue Exception => ex
      status = 500
      data = {:status => 500, :message => ex.message}
    end

    render common_json_response(status, data)
  end


	def update
		status = 403
    data = {:status => 403 }

    begin
      @checkpoint_system.save_ckp_system(checkpoint_system_params)
#      result_flag = new_user.id.nil?? false : (new_user.analyzer.nil?? false : true)
      status = 200
      data = {:status => 200, :message => "200" }
    rescue Exception => ex
      status = 500
      #p ex.backtrace
      data = {:status => 500, :message => ex.message}
    end

    render common_json_response(status, data)
	end

	# 删除ckp_system
  def destroy_all
    params.permit(:id)

    status = 403
    data = {:status => 403 }

    begin
      checkpoint_systems = CheckpointSystem.where(:rid => params[:id])
      checkpoint_systems.each{|sys|  sys.destroy }
      status = 200
      data = {:status => "200"}
    rescue Exception => ex
      status = 500
      data = {:status => 500, :message => ex.message}
    end

  	render common_json_response(status, data)
  end

  def delete_checked
    params.permit(:id, :delete_ckp)
    status = 403
    data = {:status => 403 }

    begin
      checkpoint_systems = CheckpointSystem.where(:rid => params[:id])
      if params[:delete_ckp]
        checkpoint_systems.each{|sys|
          sys.bank_subject_checkpoint_ckps.destroy_all 
          sys.destroy 
       }
      else
        checkpoint_systems.each{|sys|  sys.destroy }
      end
      status = 200
      data = {:status => "200"}
    rescue Exception => ex
      status = 500
      data = {:status => 500, :message => ex.message}
    end

    render common_json_response(status, data)    
  end

	private

	def get_checkpoint_system
		@checkpoint_system = CheckpointSystem.where(rid: params[:id]).first
	end

	def checkpoint_system_params
    if params[:is_group]
	    params[:is_group] = (params[:is_group]  == "true") ? true : false 
	  end
		params.permit(
			:name,
			:rid,
			:is_group,
			:sys_type,
			:version,
			:desc
		)
	end
end
