module Managers::MainsHelper
  def page_info_item
    case controller_name
    when "area_administrators"
      title = I18n.t("activerecord.models.area_administrator")
      path = "/managers/area_administrators"      
    when "analyzers"
      title = I18n.t("activerecord.models.analyzer")
      path = "/managers/analyzers"
    when "permissions"
      title = I18n.t("activerecord.models.permission")
      path = "/managers/permissions"
    when "pupils"
      title = I18n.t("activerecord.models.pupil")
      path = "/managers/pupils"
    when "project_administrators"
      title = I18n.t("activerecord.models.project_administrator")
      path = "/managers/project_administrators"
    when "roles"
      title = I18n.t("activerecord.models.role")
      path = "/managers/roles"
    when "teachers"
      title = I18n.t("activerecord.models.teacher")
      path = "/managers/teachers"
    when "tenants"
      title = I18n.t("activerecord.models.tenant")
      path = "/managers/tenants"
    when "tenant_administrators"
      title = I18n.t("activerecord.models.tenant_administrator")
      path = "/managers/tenant_administrators"
    when "node_structures"
      title = I18n.t("activerecord.models.bank_nodestructure")
      path = "/managers/node_structures"
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
    when "papers"
      title = "#{I18n.t('activerecord.models.bank_paper_pap')}"
      path = "/managers/papers"
    when "checkpoint_systems"
      title = "#{I18n.t('activerecord.models.checkpoint_system')}"
      path = "/managers/checkpoint_systems"
    when "bank_tests"
      title = "#{I18n.t('managers.menus.bank_test')}"
      path = "/managers/bank_tests"
    when "managers"
      title = I18n.t("activerecord.models.super_administrator")
      path = "/managers/managers"
    else
      title = I18n.t("dict.unknown")
      path = "/managers/"
    end
    result = {
      :title => title,
      :path => path
    }
    result
  end

  def manager_multiple_tenant_select?
    (current_manager && ["project_administrators", "papers", "bank_tests"].include?(controller_name))
  end

  def target_test_group_arr _test_top_group
    index = _test_top_group==nil ? Common::Report::Group::ListArr.length-1 : Common::Report::Group::ListArr.index(_test_top_group)
    Common::Report::Group::ListArr[0..index] 
  end
end
