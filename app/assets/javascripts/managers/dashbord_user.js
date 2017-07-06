$(function () {

  //初始化角色分类chrat和table
  init_partical('role_id','user','角色分类')

  //更新数据按钮
  $('#update_button').click(function(){
    update_button('user')
  })
})