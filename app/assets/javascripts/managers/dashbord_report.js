$(function () {
  //报告统计
  $("#update_all").click(function(){
    $.ajax({
      url: '/managers/dashbord/report_overall_stat',
      type: 'post',
      data:{
        authenticity_token: $('meta[name="csrf-token"]')[0].content,
      },
      success: function(rs){
        append_message('report','更新成功')
        display_num(rs.data)
      },
      error: function(rs){
        append_message('report','更新失败')
      }
    })
  })

  //单个测试统计
  $(document).on("click","#update_single",function(){
    $.ajax({
      url: '/managers/dashbord/report_single_stat',
      type: 'post',
      data: {
        authenticity_token: $('meta[name="csrf-token"]')[0].content,
        id: $('#test_id').val(),
      },
      success: function(rs){
        append_message('report','统计成功')
        display_num(rs)
      },
      error: function(rs){
        append_message('report','统计失败')
      }
    })
  })

  //显示单个测试情况
  $.ajax({
    url: location.href.replace(/report/,"report_list"),
    type: 'get',
    success: function(rs){
      display_num(rs)
    },
    error: function(rs){

    }
  })
})
//显示各个块中的内容
function display_num(rs){
  $.each(rs, function(key, val) {  
    if(val==null){
      $('#'+key).parent('div').css('background-color','#ff8547')//.parent('div').parent('div').css("display", "block");
    }else{
      $('#'+key).html(val)
    }
  });
}
