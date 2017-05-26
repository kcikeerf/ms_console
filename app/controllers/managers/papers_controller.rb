class Managers::PapersController < ApplicationController
	layout 'manager_crud'

  respond_to :json, :html, :js

  #before_action :get_user, only: [:edit, :update]

  def index
    @papers, total_count = Mongodb::BankPaperPap.get_list params
    respond_with({rows: @papers, total: total_count}) 
  end

  def new_paper_test
    @paper = Mongodb::BankPaperPap.where(_id: params[:id]).first
    if @paper.paper_status.present? #&& Common::Locale::StatusOrder[@paper.paper_status.to_sym] >= Common::Locale::StatusOrder[:score_importing]
      @checkpoint_system = CheckpointSystem.where(rid: @paper.checkpoint_system_rid).first
    else
      status = 500
      data = {:status => 500, :message => "can not new paper test"}
      render common_json_response(status, data)
    end
  end

  def create_paper_test
    @paper = Mongodb::BankPaperPap.where(_id: params[:id]).first
    bank_test = Mongodb::BankTest.new
    begin
      bank_test.bank_paper_pap_id = @paper._id
      bank_test.save_bank_test(bank_test_params)

      status = 200
      data = {:status => 200, :message => "200" }
    rescue Exception => ex
      status = 500
      data = {:status => 500, :message => ex.message}
    end

    render common_json_response(status, data)
  end
  
  def rollback
    @paper = Mongodb::BankPaperPap.where(_id: params[:id]).first

    if params[:save_ckp]
      save_ckp = params[:save_ckp].to_bool 
    else
      save_ckp = true
    end
    status = 403
    data = {:status => 403 }

    begin
      if params[:back_to].blank?
        data = {:status => 403, :message => I18n.t("papers.messages.error.no_choose_status") }
      else
        @paper.rollback_status(params[:back_to], save_ckp)
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
    status = 403
    data = {:status => 403 }

    begin
      @papers = Mongodb::BankPaperPap.where(:_id.in =>  params[:id])
      @papers.each{ |paper| 
        paper.delete_paper_pap
      }
      status = 200
      data = {:status => "200"}
    rescue Exception => ex
      status = 500
      data = {:status => 500, :message => ex.message}
    end
    render common_json_response(status, data)
  end

  def down_file
    status = 403
    data = {:status => 403 }
    render common_json_response(status, data)
  end
  
private
  def bank_test_params
    params.permit(
      :name,
      :start_date,
      :quiz_date,
      :quiz_type,
      :is_public,
      :checkpoint_system_rid,
      :province_rid,
      :city_rid,
      :district_rid,
      :tenant_uids => []

      )
  end

end
