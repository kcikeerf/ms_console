class Managers::BankTestsController < ApplicationController
	before_action :set_bank_test, only: [:edit, :update]
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
