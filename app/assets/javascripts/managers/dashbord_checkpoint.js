var data = {
  group_name: 'category',
}
$(function () {
  data['authenticity_token'] = $('meta[name="csrf-token"]')[0].content
  var chart = echarts.init(document.getElementById('chart')); 
  $('#table').datagrid({
    data: []
  })
  get_data(data,chart)
  //饼图点击下钻
  chart.on('click',function(a){
    if(data.group_name=='category'){
      data.group_name = 'subject'
      data['category'] = a.name
      get_data(data,chart)
    }else if(data.group_name=='subject'){
      data.group_name = 'dimesion'
      data['subject'] = a.name
      get_data(data,chart)
    }
  })
  //返回上级按钮
  $('#back_button').click(function(){
    if(data.group_name =='dimesion'){
      data.group_name = 'subject'
      delete data['subject']
      get_data(data,chart)
    }else if(data.group_name =='subject'){
      data.group_name = 'category'
      delete data['category']
      get_data(data,chart)
    }
  })

  //获取全部checkpoint,并合并单元格
  $.ajax({
    url: '/managers/dashbord/checkpoint_list',
    type: 'post',
    data:{
      authenticity_token: $('meta[name="csrf-token"]')[0].content
    },
    success: function(rs){
      var sum_num = 0
      var xiao = 0
      var chu = 0
      var gao = 0
      for(var i = 0; i<rs.length; i++){
        sum_num = sum_num + rs[i].dimesion_count
        switch(rs[i].category){
          case "小学":
            xiao += 1
            break;
          case "初中":
            chu += 1
            break;
          case "高中":
            gao += 1
            break;
        }
      }
      var subject = []
      for(var i = 0; i<rs.length/3; i++){
        var hash = {
          index: 3*i,
          rowspan: 3
        }
        subject.push(hash)
      }
      $('#sum_num').html(sum_num)
      $('#total_table').datagrid({
        onLoadSuccess:function(){
          var category = [{
            index:0,
            rowspan: xiao
          },{
            index: xiao,
            rowspan: chu
          },{
            index: xiao + chu,
            rowspan: gao
          }];
          for(var i=0; i<category.length; i++){
            $('#total_table').datagrid('mergeCells',{
              index:category[i].index,
              field:'category',
              rowspan:category[i].rowspan
            });
            $('#total_table').datagrid('mergeCells',{
              index:category[i].index,
              field:'category_count',
              rowspan:category[i].rowspan
            });
          }
          for(var i=0; i<subject.length; i++){
            $('#total_table').datagrid('mergeCells',{
              index:subject[i].index,
              field:'subject',
              rowspan:subject[i].rowspan
            });
            $('#total_table').datagrid('mergeCells',{
              index:subject[i].index,
              field:'subject_count',
              rowspan:subject[i].rowspan
            });
          }
        },
        data: rs
      })
    },
    error: function(rs){

    }
  })
})

//分段获取指标
function get_data(data,chart){
  var str = ''
  $.each(data, function(key, val) {
    str = data['category'] +' '+ data['subject']
  });
  str = str.replace(/undefined/g,'')
  $('#message').html(str)

  $.ajax({
    url: '/managers/dashbord/checkpoint_list',
    type: 'post',
    data: data,
    success: function(rs){
      if(typeof(rs)== 'object'){
        var option = {
          tooltip : {
            trigger: 'item',
            formatter: "{a} <br/>{b} : {c} ({d}%)"
          },
          series: [{
            name: '数量',
            type: 'pie',
            radius: '55%',
            data: rs
          }],
        }
        chart.setOption(option,true);
        $('#table').datagrid('loadData',{rows:rs})
      }else if(typeof(rs)== 'string'){
        window.location.reload();
      }
    },
    error: function(rs){

    }
  })
}
