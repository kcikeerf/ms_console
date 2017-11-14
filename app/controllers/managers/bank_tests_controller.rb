class Managers::BankTestsController < ApplicationController
	before_action :set_bank_test, only: [:edit, :update, :combine, :combine_obj, :download_page,:download,:get_binded_stat]
	layout 'manager_crud'

  respond_to :json, :html, :js
	def index
		@bank_tests, total_count = Mongodb::BankTest.get_list params
    respond_with({rows: @bank_tests, total: total_count}) 
	end

	def edit
		@paper = @bank_test.bank_paper_pap
		@checkpoint_system = @bank_test.checkpoint_system
	end

	def update
		begin
			@bank_test.save_bank_test(bank_test_params)
			status = 200
      data = {:status => 200, :message => "200" }
    rescue Exception => ex
      status = 500
      data = {:status => 500, :message => ex.message}
    end

    render common_json_response(status, data)
	end

	def destroy_all
    begin
      @bank_tests = Mongodb::BankTest.where(:_id.in =>  params[:id])
      @bank_tests.each{ |bt| 
      	bt.destroy
      }
      status = 200
      data = {:status => "200"}
    rescue Exception => ex
      status = 500
      data = {:status => 500, :message => ex.message}
    end
    render common_json_response(status, data)
	end

  #获取绑定情况
  def get_binded_stat
    result_hash,result_arr = @bank_test.get_user_binded_stat
    render :json => {result_hash: result_hash,result_arr: result_arr}
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
      @bank_test.combine_bank_user_link params
      status = 200
      data = {:status => "200"}
    rescue Exception => e
      status = 500
      data = {:status => 500, :message => e.message}
    end
    render common_json_response(status, data)
  end

  def download_page
    status = 200
    score_uploads = []
    paper = @bank_test.bank_paper_pap
    @bank_test.score_uploads.each do |su|
      tenant = @bank_test.tenants.where(uid: su.tenant_uid).first
      su_hash = {}
      su_hash[:file_id] = su.id
      su_hash[:file_type] = "score_uploads"
      su_hash[:upload_type] = "usr_pwd_file"
      su_hash[:down_file_name] = "#{tenant.name_cn}_#{paper.heading}_账号密码下载"
      score_uploads << su_hash
    end
    data = {:down_list => score_uploads}
    render common_json_response(status, data) 
  end

  def download
    params.permit!
    if params[:file_type] == "score_uploads"
    file  = ScoreUpload.where(id: params[:file_id]).first
    tenant = @bank_test.tenants.where(uid: file.tenant_uid).first
    paper = @bank_test.bank_paper_pap
    end
    file_path = ""
    file_name = ""
    case params[:upload_type]
    when 'usr_pwd_file'
      file_path = file.usr_pwd_file.current_path
      file_name = tenant.name_cn + "_" + paper.heading +  "_账号密码.xlsx"
    end
    send_file file_path, filename: file_name
  end

	private

		def set_bank_test
			@bank_test = Mongodb::BankTest.where(_id: params[:id]).first		
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
