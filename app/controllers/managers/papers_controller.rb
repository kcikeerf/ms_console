class Managers::PapersController < ApplicationController
	layout 'manager_crud'

  respond_to :json, :html, :js

  before_action :set_paper, only: [:new_paper_test, :create_paper_test, :rollback, :export_file, :combine_obj,:download,:download_page]

  #before_action :get_user, only: [:edit, :update]

  def index
    @papers, total_count = Mongodb::BankPaperPap.get_list params
    respond_with({rows: @papers, total: total_count}) 
  end

  def new_paper_test
    #@paper = Mongodb::BankPaperPap.where(_id: params[:id]).first
    if @paper.paper_status.present? #&& Common::Locale::StatusOrder[@paper.paper_status.to_sym] >= Common::Locale::StatusOrder[:score_importing]
      @checkpoint_system = CheckpointSystem.where(rid: @paper.checkpoint_system_rid).first
    else
      status = 500
      data = {:status => 500, :message => I18n.t("papers.messages.error.cannot_new_test")}
      render common_json_response(status, data)
    end
  end

  def create_paper_test
    #@paper = Mongodb::BankPaperPap.where(_id: params[:id]).first
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
    #@paper = Mongodb::BankPaperPap.where(_id: params[:id]).first

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

  def download
    file_path, file_name = @paper.export_paper_associated_ckps_file    
    send_file file_path, filename: file_name
  end

  def download_page
    status = 200
    score_uploads = []
    if ["analyzed", "score_importing", "score_imported", "report_generating", "report_completed"].include?(@paper.paper_status)
      paper_hash = {}
      paper_hash[:file_id] = params[:id]
      paper_hash[:file_type] = "ckps_file" #三维解析下载
      paper_hash[:upload_type] = ""
      paper_hash[:down_file_name] = Common::Locale::i18n("activerecord.models.bank_paper_pap")+Common::Locale::i18n("page.quiz.three_dimensiona_digital_analysis")#"试卷三维解析下载"
      score_uploads << paper_hash
    end
    data = {:down_list => score_uploads}
    render common_json_response(status, data) 
  end

  def export_ckpz_qzs
    begin
      result = Mongodb::BankPaperPap.export_pap_ckpz_qzps params
      status = 200
      data = {:status => "200",:message => result}
    rescue Exception => e
      status = 500
      data = {:status => 500, :message => e.message}
    end
    render common_json_response(status, data)
  end

#   def new_import
#     status = 200
#     html = '
# <form action="" accept-charset="UTF-8" method="post" id="refrom" class="dlg-form" enctype="multipart/form-data">
# <input type="hidden" name="authenticity_token" value="">
#   <div class="ffile">
#     <label>题型:</label>
#     <input type="file" name="file_name">
#   </div>
#   <div class="fheading">
#     <label>标题:</label>
#     <input type="text" name="heading" id="heading" value="">
#   </div>
#   <div class="fsubheading">
#     <label>副标题:</label>
#     <input type="text" name="subheading" id="subheading" value="">
#   </div>
#   <div class="frid">
#     <label>指标体系:</label>
#     <input type="text" name="checkpoint_system_rid" id="checkpoint_system_rid" value="">
#   </div>
# </form>'  
#     data = {:html => html}
#     render common_json_response(status, data)
#   end

  def import
    params.permit!
    begin     
      bank_paper = Mongodb::BankPaperPap.new
      bank_paper.import_paper_structure(params)
      status = 200
      data = {:status => "200"}
    rescue Exception => e
      status = 500
      data = {:status => 500, :message => e.message}
    end
    render common_json_response(status, data)

  end


  def export_file
    params.permit!    
    unless @paper.blank?
      file_path, file_name = @paper.export_paper_strucutre params[:down_type]
      send_file file_path, filename: file_name, disposition: 'attachment'
    end
  end


  # def combine
  #   status = 200
  #   html = '
  # <form action="" accept-charset="UTF-8" method="post" id="refrom" class="dlg-form" enctype="multipart/form-data">
  # <input type="hidden" name="authenticity_token" value="">
  #   <div class="ffile">
  #     <label>文件:</label>
  #     <input type="file" name="file_name">
  #   </div>
  # </form>'  
  #   data = {:html => html}
  #   render common_json_response(status, data)
  # end
  
  def combine_obj
    params.permit!
    begin
      raise SwtkErrors::ParameterInvalidError.new(Common::Locale::i18n("swtk_errors.parameter_invalid_error", :message => "no file")) if params[:file_name].blank?
      @paper.combine_paper_structure_checkpoint params
      status = 200
      data = {:status => "200"}
    rescue Exception => e
      status = 500
      data = {:status => 500, :message => e.message}
    end
    render common_json_response(status, data)
  end
private
  def set_paper
    @paper = Mongodb::BankPaperPap.where(_id: params[:id]).first
  end


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
