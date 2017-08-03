# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'
# Rails.application.config.assets.initialize_on_precompile = false

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )


Rails.application.config.assets.precompile += %W{
  default/users.css
  managers/dashbord.css
  users.js
  zhengjuan.css
  init_zhengjuan.js
  ztree.js
  ztree.css
  000016090/paper/zheng_juan.js
  report.css
  init_report.js
  create_report.js
  000016090/report/new_report.css.scss
  000016090/report/init_new_report.js
  00016110/report.css.scss
  00016110/report/init_report.js
  echarts.min.js
  echarts_themes/macarons.js
  echarts_themes/vintage.js
  jquery.remotipart.js
  default/ques-bank.css
  managers/mains.css
  managers/subject_checkpoints.scss
  managers/checkpoints.css
  managers/area.js
  managers/mains.js
  managers/node_catalog_checkpoint_combination.js
  managers/node_catalog_checkpoint_display.js
  managers/node_structure_catalog.js
  managers/node_subject_checkpoints.js
  managers/papers.js
  managers/selected_nodes_tree.js
  managers/subject_checkpoints.js  
  managers/mains.js
  managers/dashbord_paper.js
  managers/dashbord_user.js
  managers/dashbord_quiz.js
  managers/dashbord_checkpoint.js
  managers/dashbord_report.js
  managers/dashbord.js
  managers/area_manage.js
}
