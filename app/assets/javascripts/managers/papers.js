//= require jquery_ujs

//回退
function rollbackObj(url, rowIndex) {
  rows  = $('#dg').datagrid('getRows');
  row = rows[rowIndex]
  if (row){
    if (row["paper_status"] == "editted" || row["paper_status"] == "analyzing" || row["paper_status"] == "analyzed"|| row["paper_status"] == "score_importing" || row["paper_status"] == "score_imported" || row["paper_status"] == "report_generating" || row["paper_status"] == "report_completed" ){
      $('#dlg').dialog('open').dialog('setTitle','试卷回退');
      $('#fm').form('clear').attr('action', url);
      $('#fm')[0]["authenticity_token"].value = $('meta[name="csrf-token"]')[0].content;
      $('#fm').form('load',row).attr('action', url + (row.id == undefined ? row.uid : row.id) + "/rollback" );
      $('#manager_method').val('post');
      $('#fm .fckp').css('display','none');
      $("#fm #save_ckp_true").prop("checked", false)
      $("#fm #save_ckp_false").prop("checked", false)
      if (row.paper_status == "editted" ){
        $("#fm .back_to option[value='analyzing']").attr("disabled",true);
        $("#fm .back_to option[value='editted']").attr("disabled",true);

      }else if (row.paper_status == "analyzing"){
        $('#fm .fckp').css('display','block');
        $("#fm #save_ckp_true").prop("checked", true)
        $("#fm .back_to option[value='analyzing']").attr("disabled",true);
      }else{
        $('#fm .fckp').css('display','block');
        $("#fm #save_ckp_true").prop("checked", true)
      }
    }
  }
}

$(function(){
  var select_id = '' //将选择的id放入其中，并用空格隔开
  //table双击，将试卷uid放入下方选择栏，再次双击则移除，并展开试卷分析pannel
  $('#dg').datagrid({
    onDblClickRow: function (rowIndex, rowData) {
      // id_arr = document.getElementById('select_message').getElementsByTagName('p')
      
      // var option = "<div style='float: left;width: 25%;display: inline;text-align: center;'>"+rowData.uid+"<span class= 'l-btn-icon icon-add'></span></div>"
      $("#pap_analsys").accordion("select","试卷分析")
      if(select_id.indexOf(rowData.uid)>=0){
        select_id = select_id.replace(" "+rowData.uid,"")
      }else{
        select_id = select_id +" "+ rowData.uid
      }
      $("#select_message").html(select_id)
    }
  })
  //试卷分析按钮点击
  $('#export_cpk').click(function(){
    $("#pap_analsys").accordion("select","试卷分析")
  })
  //操作栏其他位置点击，关闭展开
  $('#tb').click(function(){
    close()
  })
  //确定按钮点击，将id传到后台，并清空和关闭试卷分析pannel
  $(document).on("click","#sure",function(){
    var id_arr = select_id.split(' ').slice(1)
    select_id = ''
    $("#select_message").html(select_id)
    if (id_arr.length > 0){
      $.ajax({
        url: "/managers/papers/export_ckpz_qzs",
        type: 'post',
        data: {
          authenticity_token: $('meta[name="csrf-token"]')[0].content,
          id_arr: id_arr,
        },
        success: function(rs){
          var file_name = rs.message.split('/')[rs.message.split('/').length-1]
          window.open('http://localhost:3000/'+file_name)
          close()
        },
        error: function(){
          alert('下载失败，请重新选择试卷')
          close()
        }
      })
    }else{
      alert('至少选择一份试卷')
    }
  })
  //关闭试卷分析pannel
  function close(){
    var select_pannel = $('#pap_analsys').accordion('getSelected')
    if(select_pannel){
      select_pannel.panel('collapse')
    }
  }
})