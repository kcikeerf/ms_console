$(function () {

  //初始化年级，状态分类chart和tabel
  init_partical('grade','paper','年级分类')
  init_partical('paper_status','paper','状态分类')
  // init_partical('school','paper','学校分类')
  init_partical('subject','paper','科目分类')
  init_partical('term','paper','学期分类')

  
  // 更新数据按钮
  $('#update_button').click(function(){ 
    update_button('paper')
  })

})
