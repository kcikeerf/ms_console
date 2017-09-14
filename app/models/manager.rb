class Manager < ActiveRecord::Base

  attr_accessor :login,:password_confirmation

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable

  validates :name, presence: true, uniqueness: true, format: { with: /\A([a-zA-Z_]+|(?![^a-zA-Z_]+$)(?!\D+$)).{6,50}\z/ }
  
  validates :password, length: { in: 6..19 }, presence: true, confirmation: true, if: :password_required?

  before_destroy :validate_manager_num

  class << self
    def get_list params
      params[:page] = params[:page].blank?? Common::SwtkConstants::DefaultPage : params[:page]
      params[:rows] = params[:rows].blank?? Common::SwtkConstants::DefaultRows : params[:rows]
      conditions = []
      conditions << self.send(:sanitize_sql, ["name LIKE ?", "%#{params[:name]}%"]) unless params[:name].blank?
      conditions << self.send(:sanitize_sql, ["email LIKE ?", "%#{params[:email]}%"]) unless params[:email].blank?
      conditions = conditions.any? ? conditions.collect { |c| "(#{c})" }.join(' AND ') : nil
      result = self.where(conditions).order("updated_at desc").page(params[:page]).per(params[:rows])
      result.each_with_index{|item, index|
        h = {
          :id => item.id,
          :user_name => item.name,
          :email => item.email,
          :updated_at => item.updated_at.strftime("%Y-%m-%d %H:%M")
        }
        result[index] = h
      }
      return result
    end

    # def authenticate(name,password)
    #   manager = Manager.where(name: name).first
    #   manager.try(:valid_password?, password) ? manager : nil
    # end
  end

  def validate_manager_num
    return Manager.count > 1
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    find_user(login, conditions)
  end

  def self.left_menus
    [
      {
        id: 1, icon: 'icon-sys', name: 'Dashbord',
        menus: [
          {id: 101, name: Common::Locale::i18n("activerecord.models.user"), icon: '', url: '/managers/dashbord/user'},
          {id: 102, name: Common::Locale::i18n("activerecord.models.bank_paper_pap"), icon: '', url: '/managers/dashbord/paper'},
          {id: 103, name: Common::Locale::i18n("activerecord.models.bank_quiz_qiz"), icon: '', url: '/managers/dashbord/quiz'},
          {id: 104, name: Common::Locale::i18n("activerecord.models.bank_subject_checkpoint_ckp"), icon: '', url: '/managers/dashbord/checkpoint'},
          {id: 105, name: Common::Locale::i18n("page.reports.report"), icon: '', url: '/managers/dashbord/report'},
          # {id: 205, name: Common::Locale::i18n("managers.menus.zhi_biao_xi_tong_guan_li"), icon: '', url: '/managers/checkpoint_systems'},
          # {id: 205, name: Common::Locale::i18n("managers.menus.bank_test"), icon: '', url: '/managers/bank_tests'}
        ]
      },
      {
        id: 2, icon: 'icon-sys', name: '用户管理',
        menus: [
          {id: 201, name: Common::Locale::i18n("managers.menus.jue_se_guan_li"), icon: '', url: '/managers/roles'},
          {id: 202, name: Common::Locale::i18n("managers.menus.quan_xian_guan_li"), icon: '', url: '/managers/permissions'},
          {id: 203, name: Common::Locale::i18n("managers.menus.tenant_guan_li"), icon: '', url: '/managers/tenants'},
          {id: 204, name: Common::Locale::i18n("managers.menus.di_qu_guan_li"), icon: '', url: '/managers/areas'},
          {id: 205, name: Common::Locale::i18n("managers.menus.project_admin_guan_li"), icon: '', url: '/managers/project_administrators'},
          {id: 206, name: Common::Locale::i18n("managers.menus.fen_xi_yuan_guan_li"), icon: '', url: '/managers/analyzers'},
          {id: 207, name: Common::Locale::i18n("activerecord.models.super_administrator"), icon: '', url: '/managers/managers'},
          {id: 208, name: Common::Locale::i18n("activerecord.models.api_permissions"), icon: '', url: '/managers/api_permissions'},
        ]
      },
      {
        id: 3, icon: 'icon-sys', name: '身份管理',
        menus: [
          {id: 301, name: Common::Locale::i18n("managers.menus.area_admin_guan_li"), icon: '', url: '/managers/area_administrators'},
          {id: 302, name: Common::Locale::i18n("managers.menus.tenant_yong_hu_guan_li"), icon: '', url: '/managers/tenant_administrators'},
          {id: 303, name: Common::Locale::i18n("managers.menus.jiao_shi_guan_li"), icon: '', url: '/managers/teachers'},
          {id: 304, name: Common::Locale::i18n("managers.menus.xue_sheng_guan_li"), icon: '', url: '/managers/pupils'},
        ]
      },
      {
        id: 4, icon: 'icon-sys', name: '资源管理',
        menus: [
          {id: 401, name: Common::Locale::i18n("managers.menus.jiao_cai_ji_mu_lu_guan_li"), icon: '', url: '/managers/node_structures'},
          {id: 402, name: Common::Locale::i18n("managers.menus.jiao_cai_ji_mu_lu_zhi_biao_ti_xi_guan_li"), icon: '', url: '/managers/checkpoints'},
          {id: 403, name: Common::Locale::i18n("managers.menus.ke_mu_zhi_biao_ti_xi_guan_li"), icon: '', url: '/managers/subject_checkpoints'},
          {id: 404, name: Common::Locale::i18n("managers.menus.shi_juan_guan_li"), icon: '', url: '/managers/papers'},
          {id: 405, name: Common::Locale::i18n("managers.menus.zhi_biao_xi_tong_guan_li"), icon: '', url: '/managers/checkpoint_systems'},
          {id: 406, name: Common::Locale::i18n("managers.menus.bank_test"), icon: '', url: '/managers/bank_tests'},
          {id: 406, name: Common::Locale::i18n("managers.menus.union_test"), icon: '', url: '/managers/union_tests'}
        ]
      },
      
    ]
  end

  private

  def self.find_user(login, conditions)
    user = 
      case judge_type(login)
      when 'mobile'
        where("phone = ? and phone_validate = ?", login, true)
      when 'email'
        where("lower(email) = ?", login.downcase)
      else
        where("lower(name) = ?", login.downcase)
      end

    user.where(conditions.to_h).first#.where(["lower(phone) = :value OR lower(email) = :value", { :value => login.downcase }]).first
  end

  def self.judge_type(user_name)
    case user_name
      when /\A1\d{10}\z/ then 'mobile'
      when /\A[^@\s]+@[^@\s]+\z/ then 'email'
      else 'name'
    end
  end
end
