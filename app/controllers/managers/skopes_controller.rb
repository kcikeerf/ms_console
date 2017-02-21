class Managers::SkopesController < ApplicationController

  respond_to :json, :html

  layout 'manager_crud'

  before_action :set_skope, only: [:update]

  def index
    @skopes = Skope.page(params[:page]).per(params[:rows])
    respond_with({rows: @skopes, total: @skopes.total_count}) 
  end

  def create
    @skope = Skope.new(skope_params)
    render json: response_json_by_obj(@skope.save, @skope)
  end

  def update
    @skope.update(skope_params)
    render json: response_json_by_obj(@skope.update(skope_params), @skope)
  end

  def destroy_all
    Skope.destroy(params[:id])
    respond_with(@skope)
  end

  private

    def set_skope
      @skope = Skope.where(id: params[:id]).first
    end

    def skope_params
      params.permit(:id, :name, :desc)
    end
end
