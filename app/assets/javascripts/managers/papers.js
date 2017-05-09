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
