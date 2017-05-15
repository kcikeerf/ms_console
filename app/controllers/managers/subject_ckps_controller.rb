class Managers::SubjectCkpsController < ApplicationController
	layout false, except: [:index, :list]
  layout 'manager', only: [:index, :list]
  respond_to :json, :html
	
	def index
    @checkpoint_system = CheckpointSystem.where(rid: params[:checkpoint_system_id]).first
    # 学科列表
    @subject_list = Common::Subject::List.map{|k,v| [v,k.to_s]}
    # 学段列表
    @xue_duan_list = Common::Grade::XueDuan::List.map{|k,v| [v,k.to_s]}
    #respond_with({rows: @checkpoint_system, total: @checkpoint_system.total_count})
	end





end
