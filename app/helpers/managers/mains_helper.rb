module Managers::MainsHelper
  def page_info_item

    title = I18n.t("dict.unknown")
    path = "/managers/"

    case controller_name
    when "node_catalogs"
      nd = BankNodestructure.where(uid: params[:node_structure_id]).first
      arr = [
        nd.version_cn,
        nd.subject_cn,
        nd.grade_cn,
        nd.term_cn,
      ]
      title = "#{I18n.t('activerecord.models.bank_node_catalog')}(#{arr.join('/')})"
      path = "/managers/node_structures/#{params[:node_structure_id]}/node_catalogs"
    when "skope_rules"
      skope = Skope.where(id: params[:skope_id]).first
      title = "#{I18n.t('activerecord.models.skope_rules')}(#{skope.name})"
      path = "/managers/skopes/#{params[:skope_id]}/skope_rules"
    else
      # do nothing
    end

    controller_arr = %W{
      api_permissions
      area_administrators
      analyzers
      auth_domain_white_lists
      oauth2_clients
      permissions
      pupils
      project_administrators
      roles
      skopes
      teachers
      tenants
      tenant_administrators
      node_structures
      users
    }

    if controller_arr.include?(controller_name)
      title = I18n.t("activerecord.models.#{controller_name}")
      path = "/managers/#{controller_name}"
    end

    result = {
      :title => title,
      :path => path
    }
    result
  end

  def http_method_list
    %W{GET POST PUT OPTIONS HEAD TRACE DELETE}
  end

  def role_list
    Role.order(name: :asc).select(:id,:name)
  end

  def skope_list
    Skope.order(name: :asc).select(:id,:name)
  end

  def priority_list
    [*1..100]
  end

  def skope_rkey_default_list
    [
      {rkey: "province", rkey_label: "省"},
      {rkey: "city", rkey_label: "市"},
      {rkey: "district", rkey_label: "区"},
      {rkey: "tenant", rkey_label: "租户（学校）"},
      {rkey: "klass", rkey_label: "班级"},
      {rkey: "pupil", rkey_label: "学生"},
      {rkey: "subject", rkey_label: "学科"},
      {rkey: "grade", rkey_label: "年级"}
    ]
  end
  
  def skope_rvalue_default_list
    [
      {rvalue: "-1", rvalue_label: "所有无效"},
      {rvalue: "1", rvalue_label: "所属范围访问有效"},
      {rvalue: "99", rvalue_label: "所有有效"}
    ]
  end
end
