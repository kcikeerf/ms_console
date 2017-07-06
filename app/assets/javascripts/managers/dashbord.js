var hash = new Array();

//更新chart,table
function update_dashbord(branch_tp,total_tp){
  var chart = hash[branch_tp]
  var table = $('#'+branch_tp+'_table');
  var data = {
    branch_tp: branch_tp,
    total_tp: total_tp,
    authenticity_token: $('meta[name="csrf-token"]')[0].content,
  }
  $.ajax({
    url: '/managers/dashbord/update_dashbord',
    data: data,
    type: 'post',
    success: function(rs){
      append_message(branch_tp,"更新成功")
      title = chart.getOption().title[0].text
      num = rs.message.data
      time = rs.message.dt_update
      var option = get_option(num,time,title,branch_tp,total_tp)
      chart.setOption(option,true);
      table.datagrid('loadData',{rows:num})
    },
    error: function(){
      append_message(branch_tp,"更新失败")
    },
  })
}

//获取饼图option
function get_option(num,time,title,branch_tp,total_tp){
  var option = {
    toolbox:{
      show: true,
      feature : {  
        myTool: {
          show: true,
          title: '更新数据',
          icon: "image://"+$('#update_path').val(),
          onclick: function(){
            update_dashbord(branch_tp,total_tp)
          }
        },
        myTool1: {
          show: true,
          title: '柱状图',
          icon: "image://"+$('#bar_path').val(),
          onclick: function(){
            var chart = hash[branch_tp]
            num = chart.getOption().series[0].data
            time = chart.getOption().title[0].subtext
            var option = get_bar_option(num,time,title,branch_tp,total_tp)
            chart.setOption(option,true);
          }
        }, 
      }  
    },
    title: {
        text: title,
        subtext: time
    },
    tooltip: {},
    series: [{
        name: '数量',
        type: 'pie',
        radius: '55%',
        data: num
    }]
  }
  return option
}

//获取柱状图option
function get_bar_option(num,time,title,branch_tp,total_tp){
  var x = []
  var y = []
  for(var i = 0; i<num.length; i++){
    x.push(num[i].name)
    y.push(num[i].value)
  }
  var option = {
    toolbox:{
      show: true,
      feature : {  
        myTool: {
          show: true,
          title: '更新数据',
          icon: "image://"+$('#update_path').val(),
          onclick: function(){
            update_dashbord(branch_tp,total_tp)
          }
        },
        myTool2: {
          show: true,
          title: '饼状图',
          icon: "image://"+$('#pie_path').val(),
          onclick: function(){
            var chart = hash[branch_tp]
            var option = get_option(num,time,title,branch_tp,total_tp)
            chart.setOption(option,true);
          }
        },  
        magicType : {
          show: true, 
          type: ['line', 'bar'],
        },
      }  
    },
    title: {
        text: title,
        subtext: time
    },
    tooltip: {},
    xAxis: {
      data: x
    },
    yAxis: {},
    series: [{
        name: '数量',
        type: 'bar',
        data: y
    }]
  }
  return option
}

//初始化chart,table
function init_partical(branch_tp,total_tp,title){
  var chart = echarts.init(document.getElementById(branch_tp));
  var table = $('#'+branch_tp+'_table');
  // hash[branch_tp] = chart
  hash[branch_tp] = chart
  var data = {
    branch_tp: branch_tp,
    total_tp: total_tp,
    authenticity_token: $('meta[name="csrf-token"]')[0].content,
  }
  $.ajax({
    url: 'get_dashbord.json',
    type: 'get',
    data: data,
    success: function(rs){
      num = rs.data
      if(num){
        time = rs.dt_update.split('.')[0].replace(/T/," ")
        append_message(branch_tp,"加载成功")
        var option = get_option(num,time,title,branch_tp,total_tp)
        chart.setOption(option,true);
        table.datagrid({
          data: num
        })
      }else{
        append_message(branch_tp,"暂无数据")
        var option = get_option([],'',title,branch_tp,total_tp)
        chart.setOption(option,true);
        table.datagrid({
          data: []
        })
      }
    },
    error: function(){
      append_message(branch_tp,"加载失败")
    }
  })
}

//显示提示信息
function append_message(id,message){
  var row = "<h5 style='color: green;text-align: center;'>"+message+"</h5>"
  $("#"+id+'_message').append(row)
  setTimeout("$('#"+id+"_message').empty()",1500)
}

//更新数据按钮方法，如果有勾选就更新以勾选的块如果未勾选则更新所有块
function update_button(total_tp){
  var input = $("input[type='checkbox']:checked")
  if(input.length>0){
  }else{
    input = $("input[type='checkbox']")
  }
  for(var i=0; i<input.length; i++){
    var branch_tp = input[i].value
    update_dashbord(branch_tp,total_tp)
  }
}
