$(function () {

  //初始化角色分类chrat和table
  init_partical('subject','danti','学科分类')
  init_partical('cat','danti','题型分类')
  init_partical('levelword2','danti','难度分类')

  //更新数据按钮
  $('#update_button').click(function(){
    update_button('danti')
  })
})