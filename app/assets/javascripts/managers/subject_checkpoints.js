//= require ztree/js/jquery.ztree.core
//= require ztree/js/jquery.ztree.excheck
//= require ztree/js/jquery.ztree.exedit
//= require init_ckeditor
//= require_self

var setting = {
		view: {
			addHoverDom: addHoverDom,
			removeHoverDom: removeHoverDom,
			selectedMulti: false
		},
		check: {
			enable: true,
			chkStyle: 'checkbox',
			radioType: "level"
		},
		data: {
			simpleData: {
				enable: true,
				idKey: "rid",
				pIdKey: "pid", //pid父节点唯一标识符属性名称
				rootPId: null
			}
		},
		callback: {
			beforeRemove: zTreeBeforeRemove,
			beforeEditName: zTreeBeforeEditName,
			beforeDrag: zTreeBeforeDrag,
			beforeDrop: zTreeBeforeDrop
//			onDrop: zTreeOnDrop,
			
		},
		edit: {
			enable: true
		}
	};
	/*显示自定义控件和添加事件*/
	function addHoverDom(treeId, treeNode) {
		//tId是每个节点的唯一id字符，跟在什么层级没有关系;
		var sObj = $("#" + treeNode.tId + "_span");
		if (treeNode.editNameFlag || $("#addBtn_" + treeNode.tId).length > 0) return;
		var addStr = "<span class='button add' id='addBtn_" + treeNode.tId + "' title='add node' onfocus='this.blur();'></span>";
		sObj.after(addStr);
		var addBtn = $("#addBtn_" + treeNode.tId);
		var deleteBtn = $("#"+treeNode.tId+"_remove")
		//出现增加节点之后的绑定的事件;
		if (addBtn){
			addBtn.unbind("click");
			addBtn.on("click", function(){
				$('.checkpoint').val('');
				$('.ckp_uid').val("");
				$('.ckp_rid').val("");
				$('.desc').val('');
				$('#advice').val('');
				$('#sort').val('');
				//$('#select-box').val('');
			    $('#dlg').dialog('open');
			    //replace_advice_ckeditor();
			    //clear_form_value();
			    $('.dimesion').val(treeNode.dimesion);
			    $('.str_pid').val(treeNode.rid);
	    		$('.subject').val($(".subject_select").val());
	    		$('.category').val($(".xue_duan_select").val());

			    //CKEDITOR.instances.advice.setData('')
	    		if(treeNode.dimesion == "knowledge"){
					$(".high_level_div").html("");
				}else
				{
					$(".high_level_div").html('<label>高低阶：</label><input type="radio" name="high_level" value="true" id="high"/>&nbsp;高阶&nbsp;<input type="radio"  name="high_level" value="false" id="low"/>&nbsp;低阶');
				}
	            $('#fm')[0]["authenticity_token"].value = $('meta[name="csrf-token"]')[0].content;
			   	$("#save").on('click',function(){
			   			$.post('/managers/subject_checkpoints', $("#fm").serialize(), function(data){
				   		 	if(data.status == 200){
				   		 		var tree = $.fn.zTree.getZTreeObj(treeNode.dimesion + "_tree");
				   		 		tree.addNodes(treeNode, data.data[0]);
				   		 		if (data.data[1] && data.data[1].is_entity == false){
					   		 		treeNode.nocheck = true;
					   		 		tree.updateNode(treeNode);
				   		 		}
				   		 	}else{
				   		 		alert(data.data.message);
				   		 	}

				   		});
			   		
			   		$('.checkpoint').val('');
					$('.desc').val('');
					// $('#select-box').val('');
					$('#save').off('click');
					//clear_form_value();
					$('#dlg').dialog('close');
			   	});
			    return false;
		    });
	    }
	};
	/*删除事件*/
	function zTreeBeforeRemove(treeId, treeNode) {

		var node = treeNode.getParentNode();
		var isOk;
		if(confirm("你确定要删除么？")){	
		
			$.ajax({
				async: false,
				type:"delete",
				url:"/managers/subject_checkpoints/destroy_all",
                data: {uid: treeNode.uid, authenticity_token: $('meta[name="csrf-token"]')[0].content},
                dataType: 'json',
				success:function(data){
					if(data.status == 200){
		   		 		if (data.data.uid){
			   		 		var tree = $.fn.zTree.getZTreeObj(treeNode.dimesion + "_tree");
			   		 		node.nocheck = data.data.nocheck;
			   		 		tree.updateNode(node);
		   		 		};
						isOk = true;
					}else{
						isOk = false;
					}
				},
				error:function(data){
					isOk = false;
				}
			})

			return isOk;
		}
		return false;		

	}
	/*隐藏自定义控件*/
	function removeHoverDom(treeId, treeNode) {
		$("#addBtn_" + treeNode.tId).unbind().remove();
	};
	/*编辑事件*/
	function zTreeBeforeEditName(treeId, treeNode){
		$('#dlg').dialog('open');
		replace_advice_ckeditor();
		$('.checkpoint').val(treeNode.checkpoint);
		treeNode.desc ? $('.desc').val(treeNode.desc):$('.desc').val('');
		treeNode.weights ? $('.weights').val(treeNode.weights):$('.weights').val('');
		//更新既有的建议
		treeNode.advice ? CKEDITOR.instances.advice.setData(treeNode.advice) : CKEDITOR.instances.advice.setData('');
		//treeNode.sort ? $('#sort').val(treeNode.sort) : $('#sort').val('');
		treeNode.uid ? $('.ckp_uid').val(treeNode.uid) : $('.ckp_uid').val('');
		treeNode.uid ? $('.ckp_rid').val(treeNode.rid) : $('.ckp_rid').val('');
		if(treeNode.dimesion == "knowledge"){
			$(".high_level_div").html("");
		}else
		{
			$(".high_level_div").html('<label>高低阶：</label><input type="radio" name="high_level" value="true" id="high"/>&nbsp;高阶&nbsp;<input type="radio"  name="high_level" value="false" id="low"/>&nbsp;低阶');
			$(".high_level").removeAttr("checked");
			if( treeNode.high_level == true || treeNode.high_level == false ){					
				treeNode.high_level ? $("#high").prop("checked","checked") : $("#low").prop("checked", "checked");
			}
		}
	  	$.get("/managers/subject_checkpoints/"+treeNode.uid+"/edit",{},function(data){
			var len = data.data.length;
			var arr=[];
			for(var i=0;i<len;i++){
				arr.push(data.data[i].cat_uid);
			}
			//console.log(arr);
			// $('#select-box').val(arr);
		});
		$('#save').unbind('click');
		$('#save').on('click',function(){
			var nodeName = $('.checkpoint').val();
			var _this = $(this);
            $('#fm')[0]["authenticity_token"].value = $('meta[name="csrf-token"]')[0].content;
	        for ( instance in CKEDITOR.instances ) {
	            CKEDITOR.instances[instance].updateElement();
	        }
	        //更新更改后的建议
	        treeNode.advice = CKEDITOR.instances.advice.getData();
	        // if($(".high_level").is(':checked')){
	        // 	data = $('#fm').serialize();	        	
	        // }else
	        // {
	        // 	data = $('#fm').serialize() + "&high_level=off"
	        // }
	        data = $('#fm').serialize();
			$.ajax({
				type:"put",
				url:"/managers/subject_checkpoints/"+treeNode.uid,
				data: data,
				success:function(data){
					treeNode.checkpoint = nodeName;
					treeNode.high_level = data.data.high_level;
					treeNode.desc = data.data.desc;
					treeNode.advice = data.data.advice;
					treeNode.weights = data.data.weights;
					$("#"+treeNode.tId+"_span").text(nodeName);
					_this.off('click');
				},
				error:function(data){
					_this.off('click');
				}
			});
			//clear_form_value();
			$('#dlg').dialog('close');
		});
		$(".panel-tool-close, #cancel").on('click', function(){
			//clear_form_value();
			$('#dlg').dialog('close');
			$('#save').off('click');

		});
		// $('#dlg').dialog({  
  //   		onClose:function(){
  //   		alert('dlg closed');  
  //       	//clear_form_value();  
  //   		}
  //   	});
	  	return false;
	}
	var DragUid;
	var DragParentUid;
	/*拖拽之前的事件回调函数*/
	function zTreeBeforeDrag(treeId, treeNodes){
		DragUid = treeNodes[0].uid;
		return DragUid;
		
	}
	function zTreeBeforeDrop(treeId, treeNodes, targetNode, moveType){
		var isOk = false;
		DragParentUid = targetNode.uid;
		$.ajax({
			type:"POST",
			dataType:"JSON",
			async:false,
			data:{str_pid:DragParentUid, move_type: moveType, authenticity_token: $('meta[name="csrf-token"]')[0].content},
			url:"/managers/subject_checkpoints/"+DragUid+"/move_node",
			success:function(data){
				if(data.status == 200){
					alert('拖拽成功')
					isOk = true;
					var subject = $('.subject_select').val();
					var xue_duan = $('.xue_duan_select').val();

					if(subject == "all"){
						get_no_dimesion_data_tree(subject, xue_duan)
					}else{					
						get_tree_data(subject, xue_duan);
					}
				}else{
					alert(data.data.message);
				}
			},
			error:function(){
				return;
			}
		});
		return isOk;
	}

	//读取指标
    function get_tree_data(subject, xue_duan){
        var sys_type_id = $('#ckp_system').val();
		if(subject == ''){
			init_tree(null, null, null);
			$('#file_upload').hide();
		}else{
			$.get('/checkpoints/get_tree_date_include_checkpoint_system',{subject: subject, xue_duan: xue_duan, ckp_system_id: sys_type_id},function(data){
				var zNodes_knowledge = data.knowledge.nodes;
				var zNodes_skill = data.skill.nodes;
				var zNodes_ability = data.ability.nodes;
				
				if(zNodes_knowledge.length <= 1){
					init_tree(null, null, null);
					$('#file_upload').show();
			    } else {
					init_tree(zNodes_knowledge, zNodes_skill, zNodes_ability);
					$('#file_upload').hide();
			    }
			})
		}
	}

	function get_no_dimesion_data_tree(subject, xue_duan){
		var sys_type_id = $(".ckp_system").attr("value");
		$.get('/checkpoints/get_tree_date_include_checkpoint_system',{subject: subject, xue_duan: xue_duan, ckp_system_id: sys_type_id},function(data){
				var zNodes_other = data.nodes;
				if(zNodes_other.length <= 1){
					init_other_tree(null);
				}else{			
					init_other_tree(zNodes_other);
				}
			})

	}

	function init_tree(knowledge, skill, ability){
		$.fn.zTree.init($("#skill_tree"), setting, skill);
		$.fn.zTree.init($("#ability_tree"), setting, ability);
		$.fn.zTree.init($("#knowledge_tree"), setting, knowledge);
	}

	function init_other_tree(other){
		$.fn.zTree.init($("#other_tree"), setting, other);

	}

	function replace_advice_ckeditor(){
		CKEDITOR.editorConfig = function( config ) {
			//工具栏配置
			config.toolbar_Mine =[
                { name: 'basicstyles', items: ['Bold', 'Italic', 'Underline', 'Subscript', 'Superscript', 'SpecialChar', 'RemoveFormat','Font', 'FontSize', 'lineheight'] },
                { name: 'paragraph', items: ['TextColor', 'BGColor','JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-', 'Undo', 'Redo', 'Source'] }
		    ];
		    config.toolbar = 'Mine';
		    //初始化高度
		    config.height = 200;
		    //初始化宽度
		    config.width = 400;
		    //禁止拖拽
		    config.resize_enabled = false;
		    //添加中文字体
		    config.font_names='微软雅黑/微软雅黑;宋体/宋体;黑体/黑体;仿宋/仿宋_GB2312;楷体/楷体_GB2312;隶书/隶书;幼圆/幼圆;'+ config.font_names;
		    //图片转码的固定地址
            //config.replaceImgcrc = "/ckeditors/urlimage?src=";
		};
		(CKEDITOR.instances.advice) ? "" : (CKEDITOR.replace("advice"));
	}

	// function clear_form_value()
	// {
	// 	$('.checkpoint').val('');
	// 	$('.desc').val('');
	// 	$('.weights').val('');
	// 			//更新既有的建议
	// 	$('.advice').val('');
	// 	CKEDITOR.instances.advice.setData('');
	// 	//$('#sort').val('');
	// 	$('.ckp_uid').val('');
	// 	$('.ckp_rid').val('');
	// 	//$('.dimesion').val('');
	// 	//$('.subject').val('');
	// 	$('.str_pid').val('');
	// 	//$('.category').val('');
	// 	$(".high_level").prop("checked", false);
	// }

	$(document).ready(function(){
		var subject = $('#subject');
		var xue_duan = $('#xue_duan');	
		subject.on('change',function(){
			$('.subject_select').val(subject.val());
			get_tree_data(subject.val(), xue_duan.val());
		});

		xue_duan.on('change',function(){
			$('.xue_duan_select').val(xue_duan.val());

			get_tree_data(subject.val(), xue_duan.val());
		});

		// $(document).on('click.ckp', '.save_button', function(){
  //           var treeObj_knowledge = $.fn.zTree.getZTreeObj("knowledge_tree");
  //           var treeObj_skill = $.fn.zTree.getZTreeObj("skill_tree");
  //           var treeObj_ability = $.fn.zTree.getZTreeObj("ability_tree");

		// 	var knowledge_nodes = treeObj_knowledge.getCheckedNodes(true);
		// 	var skill_nodes = treeObj_skill.getCheckedNodes(true);
		// 	var ability_nodes = treeObj_ability.getCheckedNodes(true);
		// 	var nodes_arr = knowledge_nodes.concat(skill_nodes).concat(ability_nodes);

		// 	var node_uids = [], node_structure_uid = $('#node_structure_uid').val();
		// 	var catalog_uid = $('#node_catalog_uid').val();

		// 	$.each(nodes_arr, function(_, node){
		// 		node_uids.push(node.uid);
		// 	});

		// 	if(node_uids.length > 0){
		// 		$.post(window.location.pathname + '/add_ckps', 
		// 			{id: (catalog_uid == '' ? node_structure_uid : catalog_uid), subject_checkpoint_ckp_uids: node_uids, authenticity_token: $( 'meta[name="csrf-token"]' ).attr( 'content' )}, 
		// 			function(data){
		// 				if(data.status == 200){
		// 					$.messager.alert({ 
	 //              title: 'Success',
	 //              msg: '添加成功'
	 //            });
	 //            $('#checkpoint_dialog').dialog('close');
		// 				} else {
		// 					$.messager.alert({ 
	 //              title: 'Error',
	 //              msg: '出现错误'
	 //            });
		// 				}
		// 			});
		// 	} else {
		// 		$.messager.alert({ 
	 //              title: '警告',
	 //              msg: '请选择节点'
	 //            });
		// 	}
		// 	$(document).off('click.ckp');
		// });

	})
