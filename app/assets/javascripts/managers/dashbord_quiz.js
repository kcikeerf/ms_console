$(function () {

  //初始化角色分类chrat和table
  init_partical('subject','quiz','学科分类')
  init_partical('cat1','quiz','语文题型分类')
  init_partical('cat2','quiz','数学题型分类')
  init_partical('cat3','quiz','英语题型分类')
  init_partical('levelword2','quiz','难度分类')

  //更新数据按钮
  $('#update_button').click(function(){
    update_button('quiz')
  })
})