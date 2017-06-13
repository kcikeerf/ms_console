class TkBaseJob
  attr_accessor :phases, :phases_rollback

  def initialize
    @phases = self.methods.grep(/(phase)[0-9]{1,}$/)
    @phases_rollback = self.methods.grep(/(phase)[0-9]{1,}_rollback$/)
  end

  def execute
    result = false
    begin
      current_state = 0
      @phases.each_with_index{|phase, index|
        current_state = index
        self.send(phase)
      }
      result = true
    rescue Exception => ex
      @phases_rollback[0..current_state].reverse.each{|phase_rollback|
        self.send(phase_rollback)
      }
    end
    return result
  end
end