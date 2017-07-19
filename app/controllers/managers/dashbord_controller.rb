class Managers::DashbordController < ApplicationController
  layout 'manager'
  respond_to :json, :html
  # skip_before_action :authenticate_person!
  # before_action :authenticate_manager

  before_action :set_dashboard, only: [:update_dashbord, :get_dashbord]

  def user
    @result = User.all.size
  end
  
  def paper
    @result = Mongodb::BankPaperPap.all.size
  end

  def quiz
    @result = Mongodb::BankQuizQiz.all.size
  end

  def checkpoint
  end

  def checkpoint_list
    if params[:group_name]
      result = Mongodb::Dashbord.get_group_ckps params
    else
      result = Mongodb::Dashbord.get_all_ckps
    end
    render :json => result
  end

  #更新数据
  def update_dashbord
    begin
      case params[:total_tp]
      when "paper"
        result = @dashbord.update_paper
      when "user"
        result = @dashbord.update_user
      when "quiz"
        result = @dashbord.update_quiz
      end
      status = 200
      data = {:status => 200, :message => result }
    rescue Exception => ex
      status = 500
      data = {:status => 500, :message => ex.message}
    end
    render common_json_response(status, data)
  end

  #获取数据
  def get_dashbord
    if @dashbord
      respond_with(@dashbord)
    else
      respond_with([])
    end
  end
  
  private
    #根据branch_tp和total_tp获取对象如果对象不存在则新建对象
    def set_dashboard
      total_tp = params[:total_tp]
      branch_tp = params[:branch_tp] 
      @dashbord = Mongodb::Dashbord.where(branch_tp: branch_tp,total_tp: total_tp).first
      @dashbord = Mongodb::Dashbord.new(total_tp: total_tp,branch_tp: branch_tp)  if @dashbord.blank?
    end  
end