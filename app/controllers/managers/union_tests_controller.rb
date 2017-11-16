# -*- coding: UTF-8 -*-

class Managers::UnionTestsController < ApplicationController
  layout 'manager_crud',except: [:show]
  respond_to :json, :html

  def index
    @union_tests,total_count = Mongodb::UnionTest.get_list(params)
    respond_with({rows: @union_tests, total: total_count})
  end

  def destroy_all
    begin
      union_tests = Mongodb::UnionTest.where(:_id.in => params[:id])
      union_tests.each{|union_test| union_test.destroy!}
      status = 200
      data = {:status => union_tests}
    rescue Exception => e
      status = 500
      data = {:status => 500, :message => e.message}
    end
    render common_json_response(status, data)
  end

  # def show
  #   @union_test = Mongodb::UnionTest.find(params[:id])
  #   @bank_tests = @union_test.bank_tests
  #   render layout: 'manager'
  # end
end