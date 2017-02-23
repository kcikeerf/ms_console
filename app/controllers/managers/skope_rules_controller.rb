class Managers::SkopeRulesController < ApplicationController
  respond_to :json, :html

  layout 'manager_crud'

  before_action :set_skope, only: [:index]
  before_action :set_skope_rule, only: [:create, :update]

  def index
    skope_rules = @skope.skope_rules.order(category: :asc, priority: :desc, rkey: :asc)
    total_count = skope_rules.count
    data = Kaminari.paginate_array(skope_rules).page(params[:page]).per(params[:rows])
    respond_with({rows: data, total: total_count})    
  end

  def create
    @skope_rule = SkopeRule.new
    result_flag = @skope_rule.save_ins(skope_rule_params)
    status_code = result_flag ? 200 : 500
    render status: status_code, json: response_json_by_obj(result_flag, @skope_rule)    
  end

  def update
    result_flag = @skope_rule.save_ins(skope_rule_params)
    status_code = result_flag ? 200 : 500
    render status: status_code, json: response_json_by_obj(result_flag, @skope_rule) 
  end

  def destroy_all
    SkopeRule.destroy(params[:id])
    respond_with(@skope_rule)
  end

  private

    def set_skope
      @skope = Skope.where(id: params[:skope_id]).first
    end

    def set_skope_rule
      @skope_rule = SkopeRule.where(id: params[:id]).first
    end

    def skope_rule_params
      params.permit(:id, :name, :category, :priority, :rkey, :rvalue, :desc, :skope_id)
    end
end
