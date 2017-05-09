# -*- coding: UTF-8 -*-

class CheckpointSystem < ActiveRecord::Base

  has_many :bank_subject_checkpoint_ckps, foreign_key: 'checkpoint_system_id', dependent: :destroy

  class << self
  	
  end

	def save_ckp_system params
		new_rid = BankRid.get_new_bank_rid self.class.all, "", "100" if self.rid.blank?
  	paramh = {
      :name => params[:name],
    	:rid => self.rid.blank? ? new_rid : self.rid,
      :is_group => params[:is_group],
      :sys_type =>  params[:sys_type] || "",
      :version => params[:version] || "",
      :desc => params[:desc] || "",
    }
    update_attributes(paramh)
    #save!  		
	end

  def bank_tests
  	Mongodb::BankTest.where(checkpoint_system_id: self.id)
  end

end
