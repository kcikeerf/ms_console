class Manager < ActiveRecord::Base

  attr_accessor :login,:password_confirmation

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable

  validates :name, presence: true, uniqueness: true, format: { with: /\A([a-zA-Z_]+|(?![^a-zA-Z_]+$)(?!\D+$)).{6,50}\z/ }
  
  validates :password, length: { in: 6..19 }, presence: true, confirmation: true, if: :password_required?

  ########类方法定义：begin#######
  class << self
    def find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      login = conditions.delete(:login)
      find_user(login, conditions)
    end

    def left_menus
      result = []
      menus = [
        {
          :name => "用户管理",
          :icon => "icon-sys",
          :items => %W{
            permissions
            api_permissions
            skopes
            roles
            users
            tenants
            area_administrators
            project_administrators
            tenant_administrators
            analyzers
            teachers
            pupils
          }
        },
        #
        # Role.all.map{|role|
        # 将area_administrators等动态加载}
        #
        {
          :name => "API认证管理",
          :icon => "icon-sys",
          :items => %W{
            auth_domain_white_lists
            oauth2_clients
          }
        },
        {
          :name => "资源管理",
          :icon => "icon-sys",
          :items => %W{
            node_structures
            subject_checkpoints
            checkpoints
          }
        }
      ]
      menus.each_with_index{|group,index|
        result << {
          id: index, 
          icon: group[:icon], 
          name: group[:name],
          menus: group[:items].map{|item|
            {
              name: Common::Locale::i18n("activerecord.models.#{item}"),
              icon: "",
              url: "/managers/#{item}"
            }
          }
        }
      }

      result
    end
  end
  ########类方法定义：end#######

  private

    def self.find_user(login, conditions)
      user = 
        case judge_type(login)
        # when 'mobile'
        #   where("phone = ? and phone_validate = ?", login, true)
        when 'email'
          where("lower(email) = ?", login.downcase)
        else
          where("lower(name) = ?", login.downcase)
        end

      user.where(conditions.to_h).first#.where(["lower(phone) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    end

    def self.judge_type(user_name)
      case user_name
        # when /\A1\d{10}\z/ then 'mobile'
        when /\A[^@\s]+@[^@\s]+\z/ then 'email'
        else 'name'
      end
    end
end
