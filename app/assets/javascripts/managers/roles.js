$(function(){
  $(document).on('click',"input[type='checkbox']",function(){
    var method_type 
    if($(this)[0].checked){
      method_type = 'add'
    }else{
      method_type = 'del'
    }
    update_permission(method_type,$(this)[0].name,$(this)[0].value,$("#role_id").val())
  })
})
function update_permission(method_type,model,permission_id,role_id){
  $.ajax({
    url: '/managers/roles/update_'+model,
    data: {
      authenticity_token: $('meta[name="csrf-token"]')[0].content,
      permission_id: permission_id,
      id: role_id,
      method_type: method_type,
    },
    type: 'post',
    success: function(rs){
      var inner_html = ''
      if(method_type=="add"){
        inner_html = inner_html + " checked='checked'> "
      }else{
        inner_html = inner_html + "> "
      }
      if(rs.permission_name){
        inner_html = inner_html + rs.permission_name
      }else{
        inner_html = inner_html + rs.path
      }
      $("#"+model+"_"+rs.id).parent('li').remove();
      var row = "<li>"+
      "<input type='checkbox' name='"+model+"' id='"+model+"_"+rs.id+"' value="+rs.id+inner_html
      "</li>"
      $("#"+model+"_"+method_type).append(row)
    },
    error: function(){}
  })
}
