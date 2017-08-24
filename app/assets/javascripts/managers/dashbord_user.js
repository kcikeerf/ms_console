//= require_tree ./maps
var area_chart
var option
var data
$(function () {

  //初始化角色分类chrat和table
  init_partical('role_id','user','角色分类')

  //更新数据按钮
  $('#update_button').click(function(){
    update_button('user')
  })

  //下级是区的地区
  var city_arr = [
    '北京', '天津', '上海', '重庆','香港'
  ];
  area_chart = echarts.init(document.getElementById('area'));
  data = {
    total_tp: '中国',
    branch_tp: 'province',
  }
  get_data('get_dashbord',data)

  //地图每块点击事件 
  area_chart.on('click', function (params) {
    var block_name = params.name;
    if(option.series[0].mapType == '中国'){
      if(city_arr.indexOf(block_name)>=0){
        data.branch_tp = 'district'
      }else{
        data.branch_tp = 'city'
      }
      data.total_tp = block_name
    }else {
      data.total_tp = '中国'
      data.branch_tp = 'province'
    }
    get_data('get_dashbord',data)
  });  

  //地图更新数据按钮
  $('#update_area').click(function(){
    get_data('user_area_update',data)
  })

})

//获取地图option
function map_option(rs){
  if(rs.data){
    var pupil = rs.data.pupil
    var teacher = rs.data.teacher
    var analyser = rs.data.analyser
    var tenant_admin = rs.data.tenant_admin
    var area_admin = rs.data.area_admin
    var time = rs.dt_update.split('.')[0].replace(/T/," ")
  }else{
    var pupil = []
    var teacher = []
    var analyser = []
    var tenant_admin = []
    var area_admin = []
    var time = ''
  }
  option = {
    title : {
      text: rs.total_tp+'地区人员数量',
      subtext: time,
      x:'center'
    },
    tooltip : {
      trigger: 'item',
      formatter:function(params){
        //定义一个res变量来保存最终返回的字符结果,并且先把地区名称放到里面
        var res=params.name+'<br />';
        //定义一个变量来保存series数据系列
        var myseries=option.series;
        //循环遍历series数据系列
        for(var i=0;i<myseries.length;i++){
          //在内部继续循环series[i],从data中判断：当地区名称等于params.name的时候就将当前数据和名称添加到res中供显示
          for(var k=0;k<myseries[i].data.length;k++){
            //console.log(myseries[i].data[k].name);
            //如果data数据中的name和地区名称一样
            if(myseries[i].data[k].name==params.name){
              //将series数据系列每一项中的name和数据系列中当前地区的数据添加到res中
              res+=myseries[i].name+':'+myseries[i].data[k].value+'<br />';
            }
          }
        }
        return res;                
      },
    },
    legend: {
        orient: 'vertical',
        x:'left',
        data:['学生','老师','分析员','校领导','地区管理员']
    },
    toolbox: {
        show: true,
        orient : 'vertical',
        x: 'right',
        y: 'center',
        feature : {
            mark : {show: true},
            dataView : {show: true, readOnly: false},
            restore : {show: true},
            saveAsImage : {show: true}
        }
    },
    roamController: {
        show: true,
        x: 'right',
        mapTypeControl: {
            'china': true
        }
    },
    series : [
      {
        name: '学生',
        type: 'map',
        mapType: rs.total_tp,
        itemStyle:{
            normal:{label:{show:true}},
            emphasis:{label:{show:true}}
        },
        data: pupil
      },
      {
        name: '老师',
        type: 'map',
        mapType: rs.total_tp,
        itemStyle:{
            normal:{label:{show:true}},
            emphasis:{label:{show:true}}
        },
        data: teacher
      },
      {
        name: '分析员',
        type: 'map',
        mapType: rs.total_tp,
        itemStyle:{
            normal:{label:{show:true}},
            emphasis:{label:{show:true}}
        },
        data: analyser
      },
      {
        name: '校领导',
        type: 'map',
        mapType: rs.total_tp,
        itemStyle:{
            normal:{label:{show:true}},
            emphasis:{label:{show:true}}
        },
        data: tenant_admin
      },
      {
        name: '地区管理员',
        type: 'map',
        mapType: rs.total_tp,
        itemStyle:{
            normal:{label:{show:true}},
            emphasis:{label:{show:true}}
        },
        data: area_admin
      },
    ]
  }
  return option
}

//获取或更新地图数据
function get_data(url,data){
  $.ajax({
    url: '/managers/dashbord/'+url,
    type: 'get',
    data: data,
    success: function(rs){
      if(rs.data){
        $("#area_table").datagrid({ 
          columns:[[
            {field:'name',title:'地区',width:'20%',align:'center'},
            {field:'pupil_value',title:'学生数量',width:'17%',align:'center',formatter: function(value,row,index){
              return rs.data.pupil[index].value
            }},
            {field:'teacher_value',title:'老师数量',width:'17%',align:'center',formatter: function(value,row,index){
              return rs.data.teacher[index].value
            }},
            {field:'tenent_admin_value',title:'校领导数量',width:'17%',align:'center',formatter: function(value,row,index){
              return rs.data.tenant_admin[index].value
            }},
            {field:'analyser_value',title:'分析员数量',width:'17%',align:'center',formatter: function(value,row,index){
              return rs.data.analyser[index].value
            }},
            {field:'area_admin_value',title:'地区管理员数量',width:'17%',align:'center',formatter: function(value,row,index){
              return rs.data.area_admin[index].value
            }},
          ]],
          data: rs.data.pupil
        })
      }else{
        $("#area_table").datagrid({ data: [] })
      }
      option = map_option(rs)
      area_chart.setOption(option,true);
    },
    error: function(){
      append_message('area',"加载失败")
    }
  }) 
}

