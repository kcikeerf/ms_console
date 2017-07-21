//= require ztree/js/jquery.ztree.core
//= require ztree/js/jquery.ztree.excheck
//= require ztree/js/jquery.ztree.exedit
//= require init_ckeditor
//= require_self


$(function(){
  var zTreeObj,
  setting = {
    view: {
      addHoverDom: addHoverDom,
      removeHoverDom: removeHoverDom,
      selectedMulti: false
    },
    data:{
      simpleData: {
        enable: true,
        idKey: "id",
        pIdKey: "rid",
        rootPId: '001'
      },
      key: {
        name: "name_cn"
      }
    },
    callback: {
      beforeRemove: zTreeBeforeRemove,
      beforeEditName: zTreeBeforeEditName
    },
    edit: {
      enable: true,
      drag: {
        isCopy: false,
        isMove: false
      }
    },
  }
  //获取全部地区,并初始化
  $.ajax({
    url: '/managers/areas/area_list',
    type: 'get',
    success: function(rs){
      zTreeObj = $.fn.zTree.init($("#tree"), setting, rs);
    },
    error: function(rs){

    },
  })
  //取消按钮
  $("#cancel").click(function(){
    $('#dlg').dialog('close');
  })
})
//添加方法
function addHoverDom(treeId, treeNode) {
  var sObj = $("#" + treeNode.tId + "_span");
  if (treeNode.editNameFlag || $("#addBtn_" + treeNode.tId).length > 0) return;
  if(treeNode.level>=3) return;
  var addStr = "<span class='button add' id='addBtn_" + treeNode.tId + "' title='add node' onfocus='this.blur();'></span>";
  sObj.after(addStr);
  var addBtn = $("#addBtn_" + treeNode.tId);
  if(addBtn){
    addBtn.unbind("click");
    addBtn.on("click", function(){
      $('#dlg').dialog('open');
      $('#name_cn').val('');
      //新建保存
      $('#save').unbind('click').click(function(){
        var zTree = $.fn.zTree.getZTreeObj("tree");
        name_cn = $('#name_cn').val();
        $.ajax({
          url: '/managers/areas',
          type: 'post',
          data:{
            id: treeNode.uid,
            name_cn: name_cn,
            authenticity_token: $('meta[name="csrf-token"]')[0].content
          },
          success: function(data){
            if(data.rid){
              var newID = data.rid; 
              zTree.addNodes(treeNode, {id:newID, rid:treeNode.id, name_cn:data.name_cn}); //页面上添加节点
            }else{
              window.location.reload()
            }  
          },
          error: function(){
            alert('新建失败')
          }
        }) 
        $('#dlg').dialog('close');
      })
    })
  }
}
function removeHoverDom(treeId, treeNode){
  $("#addBtn_" + treeNode.tId).unbind().remove();
}

//删除方法
function zTreeBeforeRemove(treeId, treeNode){
  var flag = false
  if(confirm("你确定要删除么？")){
    $.ajax({
      async: false,
      url: '/managers/areas/destroy_all',
      type: 'delete',
      data: {
        id: treeNode.uid,
        authenticity_token: $('meta[name="csrf-token"]')[0].content,
      },
      success: function(rs){
        flag = true
      },
      error: function(rs){
        alert("删除失败")
      }
    })
  }
  return flag
}

//编辑方法
function zTreeBeforeEditName(treeId, treeNode){
  $('#dlg').dialog('open');
  $('#name_cn').val(treeNode.name_cn);
  $('#type').val('edit')
  //编辑保存
  $('#save').unbind('click').click(function(){
    var zTree = $.fn.zTree.getZTreeObj("tree");
    name_cn = $('#name_cn').val();
    $.ajax({
      url: '/managers/areas/'+treeNode.uid,
      type: 'put',
      data:{
        name_cn: name_cn,
        authenticity_token: $('meta[name="csrf-token"]')[0].content
      },
      success: function(data){
        $("#"+treeNode.tId+"_span").text(data.name_cn);
        treeNode.name_cn = data.name_cn
      },
      error: function(){
        alert('更新失败')
      }
    }) 
    $('#dlg').dialog('close');
  })
  return false
}
