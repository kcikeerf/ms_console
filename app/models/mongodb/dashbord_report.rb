class Mongodb::DashbordReport
  include Mongoid::Document
  include Mongodb::MongodbPatch

  before_create :set_create_time_stamp
  before_save :set_update_time_stamp

  field :exclude_test_id, type: Array
  field :total_data, type: Integer  
  field :project_data, type: Integer
  field :school_data, type: Integer 
  field :klass_data, type: Integer 
  field :pupil_data, type: Integer 

  field :dt_add, type: DateTime
  field :dt_update, type: DateTime


  def count
    self.dt_update = "1980-01-01" if self.dt_update.blank?
    add_test_state = Mongodb::BankTestState.where(:dt_add.gte => self.dt_update)
    add_test_state.each do |state|
      self.total_data = self.total_data.to_i + state.total_data
      self.project_data = self.project_data.to_i + state.project_data
      self.school_data = self.school_data.to_i + state.school_data
      self.klass_data = self.klass_data.to_i + state.klass_data
      self.pupil_data = self.pupil_data.to_i + state.pupil_data
    end
    exclude_test_state = Mongodb::BankTestState.in(test_id: self.exclude_test_id)
    exclude_test_state.each do |state|
      self.total_data = self.total_data - state.total_data
      self.project_data = self.project_data - state.project_data
      self.school_data = self.school_data - state.school_data
      self.klass_data = self.klass_data - state.klass_data
      self.pupil_data = self.pupil_data - state.pupil_data
    end
    self.exclude_test_id = []
    self.save!
    return self
  end

  def add_exclude_id(id)
    self.exclude_test_id << id
    self.save!
  end
end