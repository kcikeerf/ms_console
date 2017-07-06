class Mongodb::Dashbord
  include Mongoid::Document
  include Mongodb::MongodbPatch

  before_create :set_create_time_stamp
  before_save :set_update_time_stamp

  field :data, type: Array #分类结果
  field :branch_tp, type: String #分支类别
  field :total_tp, type: String #总类别

  field :dt_add, type: DateTime
  field :dt_update, type: DateTime


  #更新试卷类型中的分类
  def update_paper
    #获取试卷对象按branch_tp分类
    paper = Mongodb::BankPaperPap.only(self.branch_tp.to_sym).group_by(&self.branch_tp.to_sym)
    arr = get_data(paper){|key| get_cn_key(key,self.branch_tp)}
    result = update_data(arr)
    return result
  end

  #更新用户类型中的分类
  def update_user
    #获取user对象按branch_tp分类
    user = User.select(self.branch_tp.to_sym).group_by(&self.branch_tp.to_sym)
    arr = get_data(user){|key| get_cn_key(key,self.branch_tp)}
    result = update_data(arr)
    return result
  end

  #将分组结果转换成hash数组并且按数量从大到小排序
  def get_data(data_group=[],&block)
    arr = []
    data_group.each do |key,value|
      key = proc.call(key)
      new_hash = {}
      new_hash['name'] = key
      new_hash['value'] = value.size
      arr << new_hash
    end
    arr.sort! {|hash1,hash2| hash1['value']<=>hash2['value']}
    arr = arr.reverse
  end

  #将字段名称转换成中文
  def get_cn_key(key,branch)
    case branch
    when 'paper_status'
      key = (Common::Locale::i18n("papers.status.#{key}"))
    when 'grade'
      key = (Common::Locale::i18n("dict.#{key}"))
    when "role_id"
      role = Role.where(id: key).first
      key = role.present? ? Common::Locale::i18n("activerecord.models.#{role.name}") : "none"
    end        
  end

  #更新数据并返回data和时间
  def update_data(arr)
    self.data = arr
    self.save!
    hash = {}
    hash['data'] = self.data
    hash['dt_update'] = self.dt_update.strftime("%Y-%m-%d %H:%M:%S")
    return hash
  end
end