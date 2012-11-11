(function($){
	//type has [info,warn,success,error]
	function showBigNotification(dom,text,type,next){
		if(!type){
			type='warn';
		}
		$(dom).parents('.upload-item').find('.notification-area .yt-alert-content .yt-alert-message').html(text);
		$(dom).parents('.upload-item').find('.notification-area .yt-alert.yt-alert-actionable').attr('class','yt-alert yt-alert-actionable alert-multi hid yt-alert-'+type);
		$(dom).parents('.upload-item').find('.notification-area .yt-alert.yt-alert-actionable').animate({opacity:'show'},'fast',function(){$(this).removeClass('hid')});
		if(next){
			$(dom).parents('.upload-item').find('.notification-area .multialert-next').attr('class','multialert-next yt-uix-button hid yt-uix-button-alert-'+type);
			$(dom).parents('.upload-item').find('.notification-area .multialert-next').show().removeClass('hid');
		}
	}
	function showNotification(dom,text,type){
		if(!type){
			type='warn';
		}
		$(dom).parents('.upload-item').find('.alert-template-with-close').attr('class','alert-template-with-close yt-alert yt-alert-default yt-alert-'+type);
		$(dom).parents('.upload-item').find('.alert-template-with-close .yt-alert-content .yt-alert-message').html(text);
	}
	$('.yt-alert .close').live('click',function(){
		$(this).parents('.yt-alert').animate({opacity:'hide'},'fast',function(){$(this).addClass('hid');});
	});
	$('.thumbnail-container .close').live('click',function(){
		$(this).parents('.upload-item').animate({opacity:'hide'},'fast');
	});
	$('select.yt-uix-form-input-select-element.metadata-privacy-input').live('change',function(){
		$(this).parents('.upload-item').find('.metadata-status-public,.metadata-status-unlisted,.metadata-status-private').addClass('hid');
		$(this).parents('.upload-item').find('.metadata-status.metadata-status-'+$('option:selected',this).val()).removeClass('hid');
	})
	item = new Array();
	var loading = '<div class="addto-loading loading-content"><img src='+vfl3z5WfW+'><span>正在载入课件锦囊...</span></div>';
	$('ul.tabs > li.tab-header').live('click',function(e){
		if($(this).hasClass('selected')){
			return false;
		}
		var oldtab = $('ul.tabs >li.selected').attr('data-tab-id');
		$('ul.tabs >li.selected').removeClass('selected');
		$(this).parents('.metadata-editor-container').find('.kejian-settings-form div.metadata-tab[data-tab-id="'+oldtab+'"]').addClass('hid').hide();
		$(this).addClass('selected');
		var tabid = $(this).attr('data-tab-id');
		$(this).parents('.metadata-editor-container').find('.kejian-settings-form div.metadata-tab[data-tab-id="'+tabid+'"]').removeClass('hid').show();
		clean_card4();
		return false;
	});
	var collapsed_upload = function (tmp) {
	 tmp.addClass('collapsed-item');
	 tmp.find('.notification-area').next().slideUp();
	 tmp.find('.sub-item-exp-zippy').animate({
		 'margin-top':'=574',
		 'opacity':'hide'
	 },'slow');
	 tmp.find('.expand-collapse-link').html('▼ 展开');
	}
	var expand_upload = function (tmp) {
	 tmp.removeClass('collapsed-item');
	 tmp.find('.notification-area').next().show();
	 tmp.find('.sub-item-exp-zippy').animate({
		 'margin-top': '0',
		 'opacity':'show'
	 },'slow');
	 tmp.find('.expand-collapse-link').html('▲ 折叠');
	}
	$('.expand-collapse-link').live('click',function(){
		var item = $(this).parents('.upload-item');
		if(item.hasClass('collapsed-item')){
			expand_upload(item);
		}else{
			collapsed_upload(item);
		}
	});
	$('span.enable-monetization-field').live('click',function(){
		$(this).parent().find('.monetization-disclaimer').toggleClass('hid');
		if($(this).parent().find('.monetization-disclaimer').hasClass('hid')){
			$(this).find('input.yt-uix-form-input-checkbox.enable-monetization').attr('checked',false);
			if(!$(this).parents('.metadata-tab').find('.monetization-settings').hasClass('hid')){
				$(this).parents('.metadata-tab').find('.monetization-settings').toggleClass('hid');	
			}
		}else{
			if($(this).parents('.metadata-tab').find('.monetization-settings').hasClass('hid')){
				$(this).find('input.yt-uix-form-input-checkbox.enable-monetization').attr('checked',true);
			}else{
				$(this).find('input.yt-uix-form-input-checkbox.enable-monetization').attr('checked',false);
				$(this).parents('.metadata-tab').find('.monetization-settings').toggleClass('hid');	
				$(this).parent().find('.monetization-disclaimer').toggleClass('hid');
			}
		}
	});
	$('.monetization-disclaimer-accept').live('click',function(){
		$(this).parents('.monetization-disclaimer').toggleClass('hid');
		$(this).parents('.metadata-tab').find('.monetization-settings').toggleClass('hid');
	});
	$('.monetization-disclaimer-cancel').live('click',function(){
		$(this).parents('.monetization-disclaimer').toggleClass('hid');
		$(this).find('input.yt-uix-form-input-checkbox.enable-monetization').attr('checked',false);
	})
	$('select').live('change',function(){
		$(this).prev().find('.yt-uix-form-input-select-value').html($(this).find('option:selected').html());
	});
	var card = '<div id="yt-uix-clickcard-card4" class="yt-uix-clickcard-card yt-uix-clickcard-card-visible" style="display:none;"><div class="yt-uix-card-border-arrow yt-uix-card-border-arrow-horizontal" style="bottom: 6px;"></div><div class="yt-uix-clickcard-card-border"><div class="yt-uix-card-body-arrow yt-uix-card-body-arrow-horizontal" style="bottom: 6px;"></div><div class="yt-uix-clickcard-card-body"></div></div></div>'
	$('#the_upload_ytb').append(card)
	
	$('.yt-uix-clickcard').live('click',function(e){
		e.stopPropagation();
		if(!$(this).hasClass('yt-uix-clickcard-active')){
			$('#yt-uix-clickcard-card4').hide();
			var contentx = $('#yt-uix-clickcard-card4 .yt-uix-clickcard-card-body').html();
			$(contentx).hide();
			$('.yt-uix-clickcard.yt-uix-clickcard-active').append(contentx);
			$('.yt-uix-clickcard.yt-uix-clickcard-active').removeClass('yt-uix-clickcard-active');
		}
		$(this).toggleClass('yt-uix-clickcard-active');
		if($(this).hasClass('yt-uix-clickcard-active')){
			var content = $(this).find('.yt-uix-clickcard-content');
			$('#yt-uix-clickcard-card4 .yt-uix-clickcard-card-body').html(content);
			css = {
				'left':($(this).offset().left - $('#yt-uix-clickcard-card4').width() - 13).toString() + 'px',
				'top':($(this).offset().top - $('#yt-uix-clickcard-card4').height() + 26).toString()+ 'px'
			}
			$('#yt-uix-clickcard-card4').css(css).show();
		}else{
			$('#yt-uix-clickcard-card4').hide();
			var content = $('#yt-uix-clickcard-card4 .yt-uix-clickcard-card-body').html();
			$(content).hide();
			$(this).append(content);
		}
	});
	$(document).click(function(e){
		var target = e.target;
		var contentx = $('#yt-uix-clickcard-card4 .yt-uix-clickcard-card-body').html();
		$(contentx).hide();
		$('.yt-uix-clickcard.yt-uix-clickcard-active').append(contentx);
		if($('.yt-uix-clickcard').hasClass('yt-uix-clickcard-active') && !$(target).is('.yt-uix-clickcard'))
		{
			$('#yt-uix-clickcard-card4').hide();
			$('.yt-uix-clickcard.yt-uix-clickcard-active').removeClass('yt-uix-clickcard-active');
		}
		if($('button.addto-button').hasClass('yt-uix-button-active') && !$(target).is('button.addto-button') && !$(target).is('shared-addto-menu')){
				$('button.addto-button').removeClass('yt-uix-button-active');
				$('.shared-addto-menu').hide().addClass('hid');
				$('.shared-addto-menu').each(function(index,box){
					$(box).html(loading);
				})
		}
	});
	$('#yt-uix-clickcard-card4').live('click',function(e){
		e.stopPropagation();
	});
	$('#yt-uix-clickcard-card4 .yt-uix-clickcard-close').live('click',function(e){
		e.stopPropagation();
		clean_card4();
	})
	var clean_card4 = function() {
		$('#yt-uix-clickcard-card4').hide();
		var contentx = $('#yt-uix-clickcard-card4 .yt-uix-clickcard-card-body').html();
		$(contentx).hide();
		$('.yt-uix-clickcard.yt-uix-clickcard-active').append(contentx);
		$('.yt-uix-clickcard.yt-uix-clickcard-active').removeClass('yt-uix-clickcard-active');
	}
	
	$('.kejian-settings-department').live('focus',function(e){
		$(this).toggleClass('department_actived');
	  showWindow('nav', '/forum.php?mod=misc&action=nav&already_inside=1&psvr_g='+$(this).parents('.metadata-container').find('.psvr_g').val()+'&psvr_f='+$(this).parents('.metadata-container').find('.psvr_f').val(), 'get', 0);
		$(this).parents('.upload-item').find('.save-error-message').addClass('critical').html('某些更改尚未保存。');
		$(this).parents('.upload-item').find('.save-changes-button').attr('disabled',false);
	  return false;
	});
	$('select.presentation_teacher_select_dynamic').live('change',function(e){
	  if($('option:selected',this).val() == 'opt_psvr_add_more')
	    $(this).parents('.metadata-container').find('.presentation_other_teacher').show();
	  else
	    $(this).parents('.metadata-container').find('.presentation_other_teacher').hide();
	})
	$('.presentation_version_date').live('click',function(){
	  JTC.setday({format:'yyyy年MM月dd日', readOnly: true});
	});
	$('.recorded-date-today-button').live('click',function(){
		var d = new Date();
		var year = d.getFullYear();
		var month = d.getMonth();
		if(month <= 9)
		    month = '0'+(month+1);
		else
				month = (month+1);
		var day= d.getDate();
		if(day <= 9)
		    day = '0'+day;
		$(this).prev().find('input.presentation_version_date').val(year + '年' + month + '月' + day +'日');
	});
	var swfu;
	var queueLeft = new Array();
	var preQueue = 5;
	jsonArray = new Array();
	jsonTime = new Array();
	function configAjax(count,callback){
		$.ajax({
	  	url:'/ajax/prepare_upload',
			type:'POST',
			data:{'authenticity_token':encodeURIComponent(AUTH_TOKEN),'count':count},
			dataType:'json',
			async:false
	  }).done(function(json){
			jsonArray = jsonArray.concat(json.config);
			jsonTime.push(json.uptime);
			if(callback){
				callback();	
			}
	  });
	};
	configAjax(preQueue);
	var countingdown_upload = 0;
	var remaining_upload_number = 0;
	var remaining_process_number = 0;
	swfu = new SWFUpload({ 
		upload_url : "http://v0.api.upyun.com/ktv-up/", 
		flash_url : "/flash/swfupload.swf",
		flash9_url: "/flash/swfupload_fp9.swf",
		requeue_on_error : false,
		file_size_limit: "1000 MB",
		http_success : [201, 303, 202,200], 
		assume_success_timeout : 0,
	  file_post_name: "file",
	  file_types_description: "Presentation",
	  file_types: "*.pdf; *.djvu; *.ppt; *.pptx; *.doc; *.docx; *.zip; *.rar; *.7z",	
		file_upload_limit : 0, 
		file_queue_limit : 0,
		debug : false, 
		prevent_swf_caching : false, 
		preserve_relative_urls : false,
		button_placeholder_id : "uploader", 
		button_width : $('.starting-box-left-column').width(), 
		button_height :$('.starting-box-left-column').height(), 
		button_action : SWFUpload.BUTTON_ACTION.SELECT_FILES, 
		button_disabled : false, 
		button_cursor : SWFUpload.CURSOR.HAND, 
		button_window_mode : SWFUpload.WINDOW_MODE.TRANSPARENT,
		file_dialog_complete_handler:function(selected,queued,inqueue){
					if(!selected){
						return false;
					}
					remaining_upload_number = selected;
					configAjax(selected - preQueue,function(){
						for(var i=preQueue;i<selected;i++){
							swfu.addFileParam(queueLeft[i-preQueue],'policy',jsonArray[i].policy);
							swfu.addFileParam(queueLeft[i-preQueue],'signature',jsonArray[i].signature);
						}						
					});
					// $('#SWFUpload_0').css({'left':$('.start-upload-button.hide-in-initial').position().left + 15,'top':($('.start-upload-button.hide-in-initial').offset().top),'position':'absolute','float':'left','width': $('.start-upload-button.hide-in-initial').outerWidth(),'height':$('.start-upload-button.hide-in-initial').outerHeight()});
					
					this.startUpload();
		},
		file_queued_handler:function(file){
				if(countingdown_upload > jsonArray.length-1){
					queueLeft.push(file.id);
				}else{
					swfu.addFileParam(file.id,'policy',jsonArray[countingdown_upload].policy);
				 	swfu.addFileParam(file.id,'signature',jsonArray[countingdown_upload].signature);
				}
				if(countingdown_upload  == 0){
					$('#the_upload_ytb #upload-page').attr('class','active-upload-page');	
				}				
				var uptime = parseInt(countingdown_upload/5);
				item[countingdown_upload] = $('#the_upload_ytb #upload-item-template').clone();
				item[countingdown_upload].attr('id','upload-item-'+countingdown_upload);
				item[countingdown_upload].attr('class','upload-item');
				item[countingdown_upload].attr('data-file-id',file.id);
				item[countingdown_upload].find('input.presentation_uptime').val(jsonTime[uptime]+countingdown_upload);
				item[countingdown_upload].find('.pdf_filename').val(file.name);
				if(countingdown_upload!=0){
					 item[countingdown_upload].addClass('collapsed-item');
					 item[countingdown_upload].find('.notification-area').next().hide();
					 item[countingdown_upload].find('.sub-item-exp-zippy').css({'margin-top':'0px','overflow':'hidden','display':'none'})
				}else{
					 item[countingdown_upload].find('.expand-collapse-link').html('▲ 折叠');
				}
				item[countingdown_upload].find('.item-title-area > .item-title').html(file.name);
				item[countingdown_upload].find('.item-sub-title > .upload-status-text').html('正在上传您的课件...');
				item[countingdown_upload].find('.kejian-settings-form  .kejian-settings-title').val(((file.name.lastIndexOf(".") != -1) ? file.name.substring(0, file.name.lastIndexOf(".")) : file.name));
				$('#active-uploads-contain').append(item[countingdown_upload][0]);
				countingdown_upload++;
		},
		upload_progress_handler:function(file,completeBytes,totalBytes){
			var percentage = parseInt(completeBytes/totalBytes*100);
					$('#the_upload_ytb .upload-item[data-file-id="'+file.id+'"]').find('.progress-bar-uploading .progress-bar-progress').css({'width':percentage.toString()+'%'}).parent().find('.progress-bar-percentage').html(percentage.toString()+'%');
					$('#the_upload_ytb .upload-item[data-file-id="'+file.id+'"]').find('input.upload_persentage').val(percentage);
		},
		upload_error_handler:function(file, code, message){
				swfu.cancelUpload(file.id,false);
				var stats = {'dom':'#the_upload_ytb .upload-item[data-file-id="'+file.id+'"] .progress-bar-uploading','text':'','debug':'','type':'error'}
				try {
							switch (code) {
							case SWFUpload.UPLOAD_ERROR.HTTP_ERROR:
								stats.text = "上传错误: " + message;
								stats.debug = "错误提示：http错误，文件名：" + file.name + ", 信息： " + message;
								break;
							case SWFUpload.UPLOAD_ERROR.UPLOAD_FAILED:
								stats.text = "上传失败";
								stats.debug = "错误提示：上传失败，文件名称: " + file.name + ", 文件大小：" + file.size + ", 信息：" + message;
								break;
							case SWFUpload.UPLOAD_ERROR.IO_ERROR:
								stats.text = "服务器错误";
								stats.debug = "错误提示：服务器错误, 文件名称: " + file.name + ", 信息： " + message;
								break;
							case SWFUpload.UPLOAD_ERROR.SECURITY_ERROR:
								stats.text = "安全性错误";
								stats.debug = "错误提示： 安全性错误, 文件名称: " + file.name + ", 信息： " + message;
								break;
							case SWFUpload.UPLOAD_ERROR.UPLOAD_LIMIT_EXCEEDED:
								stats.text = "上传超过限制。";
								stats.debug = "错误提示：上传超过限制,文件名称:  " + file.name + ", 文件大小： " + file.size + ", 信息：" + message;
								break;
							case SWFUpload.UPLOAD_ERROR.FILE_VALIDATION_FAILED:
								stats.text = "验证失败。上传跳过。";
								stats.debug = "错误提示： 验证失败，上传跳过。文件名称: " + file.name + ", 文件大小： " + file.size + ", 信息：" + message;
								break;
							case SWFUpload.UPLOAD_ERROR.FILE_CANCELLED:
								break;
							case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED:
								// stats.text = "停止";
								break;
							default:
								stats.text = "未知错误: " + errorCode;
								stats.debug = "错误提示： " + errorCode + ", 文件名称: " + file.name + ", 文件大小：" + file.size + ", 信息： " + message;
								break;
							}
						} catch (ex) {
						}
						if(stats.text!='')
							showBigNotification(stats.dom,stats.text+'<br/>'+stats.debug,stats.type);
		},
		upload_complete_handler:function(file){
			// showBigNotification('#the_upload_ytb .upload-item[data-file-id="'+file.id+'"] .progress-bar-uploading','xdafdasf','success',1);
			// showNotification('#the_upload_ytb .upload-item[data-file-id="'+file.id+'"] .progress-bar-uploading','xdafdasf','error');
			remaining_upload_number--;
			remaining_process_number++;
			$('#the_upload_ytb .upload-item[data-file-id="'+file.id+'"]').find('.progress-bar-uploading').addClass('hid').parent().find('.progress-bar-processing').removeClass('hid');
			$('#the_upload_ytb .upload-item[data-file-id="'+file.id+'"]').find('.progress-bar-processing .progress-bar-progress').removeClass('hid').css({'width':'0%'}).parent().find('.progress-bar-percentage').html('0%');
			$('#the_upload_ytb .upload-item[data-file-id="'+file.id+'"]').find('.upload-status-text').html('开始为课件转码...');
			$('#the_upload_ytb .upload-item[data-file-id="'+file.id+'"]').find('.item-cancel').addClass('hid');
			$('#the_upload_ytb .upload-item[data-file-id="'+file.id+'"]').find('.addto-button').removeClass('hid');
			$('#the_upload_ytb .upload-item[data-file-id="'+file.id+'"]').find('.save-changes-button').attr('disabled',false);
			$('#the_upload_ytb .upload-item[data-file-id="'+file.id+'"]').find('.item-leave-title').removeClass('hid');
			
			if(!$('#the_upload_ytb .upload-item[data-file-id="'+file.id+'"]').find('input.id').val()){
				auto_ajax_save($('#the_upload_ytb .upload-item[data-file-id="'+file.id+'"]').find('form').serialize()).done(function(json){
					$('#the_upload_ytb .upload-item[data-file-id="'+file.id+'"]').find('input.id').val(json.id);
					$('#the_upload_ytb .upload-item[data-file-id="'+file.id+'"]').find('.watch-page-link').html('您的课件将在以下位置阅读： <a target="_blank" href="http://'+ window.location.host +'/coursewares/'+json.id+'">http://'+ window.location.host +'/coursewares/'+json.id+'</a>');
					update_processing_bar(json.id);
				});
			}else{
	       	update_processing_bar($('#the_upload_ytb .upload-item[data-file-id="'+file.id+'"]').find('input.id').val());
			}
			this.startUpload();
			if(remaining_upload_number<=0){
				window.onbeforeunload = null;	
			}	
		},
	  upload_start_handler: function(file){
			window.onbeforeunload = function(){return "您即将离开此页面。" + "\n\n" + "如果此时您离开此页面可能会丢失您所填的内容。您确定离开？";}
			$('#the_upload_ytb .upload-item[data-file-id="'+file.id+'"]').find('.progress-bar-uploading').removeClass('hid');
	  }
	}); 
	SWFUpload.onload = function () { 
		$('#SWFUpload_0').css({'left':$('.starting-box-left-column').offset().left,'position':'absolute','float':'left'});
	}
	$('#the_upload_ytb .start-upload-button,#the_upload_ytb #multiple-uploads-link').live('click',function(){
		swfu.selectFiles();
	});
	var auto_ajax_save = function(data){
		return $.ajax({
			url:'/upload_page_auto_save',
			type:'POST',
			data:data,
			dataType:'json',
		});
	};
	$('.save-changes-button').live('click',function(){
		tmp = this;
		$(this).parents('.upload-item').find('.save-error-message').removeClass('critical').html('正在保存所有更改...');
		auto_ajax_save($(this).parents('.upload-item').find('form').serialize()).done(function(json){
			$(tmp).parents('.upload-item').find('.save-error-message').removeClass('critical').html('已保存所有更改。');
			$(tmp).attr('disabled',true);
		});
	});
	$('form input,form textarea').live('keyup change paste',function(){
		$(this).parents('.upload-item').find('.save-error-message').addClass('critical').html('某些更改尚未保存。');
		$(this).parents('.upload-item').find('.save-changes-button').attr('disabled',false);
	});
	$('form select').live('change',function(){
		$(this).parents('.upload-item').find('.save-error-message').addClass('critical').html('某些更改尚未保存。');
		$(this).parents('.upload-item').find('.save-changes-button').attr('disabled',false);
	});
	var tag = '<span class="yt-chip"><span></span><span class="yt-delete-chip"></span></span>';
	$('.kejian-settings-tag-chips-container .yt-chip').disableSelection();
	$('.kejian-settings-add-tag').live('keydown',function(event){
		if(event.which==188){
			event.preventDefault();
			var tagg = $(this).val().trim().replace(/,/g,'').replace(/，/g,'');
			if(tagg.length > 0){
				$(this).before('<span class="yt-chip"><span>'+tagg+'</span><span class="yt-delete-chip"></span></span>');
				$(this).val('');
				$(this).parent().find('.kejian-settings-tags').val($(this).parent().find('.kejian-settings-tags').val() + ' '+tagg)
			}
		}else if($(this).val().length==0 && event.which == 8){
			var tagg = $(this).val();
			if(tagg.length == 0){
				var taggx = $(this).prev().find('span:eq(0)').html();
				$(this).val(taggx);
				$(this).select();
				event.preventDefault();
				$(this).prev().find('.yt-delete-chip').trigger('click');
			}
		}
	});
	$('.yt-delete-chip').live('click',function(){
		var tagg = $(this).parents('.yt-chip').find('span:eq(0)').html();
		var tags = $(this).parents('.kejian-settings-tag-chips-container').find('.kejian-settings-tags').val();
		tags = tags.split(' ');
		var index = tags.indexOf(tagg);
		if(index!=-1){
			tags.splice(index,index+1);
			tags = tags.join(' ');
		}
		$(this).parents('.kejian-settings-tag-chips-container').find('.kejian-settings-tags').val(tags);
		$(this).parents('.yt-chip').remove();
	})
	
	var update_processing_bar = function(a){
	  $.ajax({
	      url: "/presentations/" + a + "/status",
				data:{'authenticity_token':encodeURIComponent(AUTH_TOKEN)},
	      dataType: "json",
	      success: function (b) {
	          b.complete < b.total ? (deal_json(a,b), setTimeout(function () {
	              update_processing_bar(a)
	          }, 2e3)) : b.complete === undefined || b.total == 0 ? setTimeout(function () {
	              update_processing_bar(a)
	          }, 2e3) : setTimeout(function () {
								deal_json(a,b);
								$('form input.id[value="'+a+'"]').parents('.upload-item').find('.upload-thumb-container').removeClass('hid');
								$('form input.id[value="'+a+'"]').parents('.upload-item').find('.upload-thumb-img').attr('src','/slide_pic?id='+ a +'&pic=thumb_slide_0.jpg')
								$('form input.id[value="'+a+'"]').parents('.upload-item').addClass('upload-item-finished');
	          }, 2e3)
	      }
	  });           
	};
	var deal_json = function(a,b){
		var percent = parseInt(b.complete/b.total).toString()+'%';
	  $('form input.id[value="'+a+'"]').parents('.upload-item').find('.upload-status-text').html(b.state + b.more);
		$('form input.id[value="'+a+'"]').parents('.upload-item').find('.progress-bar-processing .progress-bar-percentage').html(percent);
		$('form input.id[value="'+a+'"]').parents('.upload-item').find('.progress-bar-processing .progress-bar-progress').css({'width':percent});
	}
	$('.item-cancel').live('click',function(){
		$(this).parents('.upload-item').addClass('upload-item-failed');
		collapsed_upload($(this).parents('.upload-item'));
		$(this).parents('.upload-item').find('.upload-failure').html('上传已取消。');
		fileid = $(this).parents('.upload-item').attr('data-file-id');
		swfu.cancelUpload(fileid,false);
	});
	//#==========================
	$('button.addto-button').live('click',function(e){
		e.stopPropagation();
		$(this).toggleClass('yt-uix-button-active');
		var addto_div = $(this).parents('.upload-item').find('.shared-addto-menu');
		tmp  = this;
		if($(this).hasClass('yt-uix-button-active')){
			cssObj = {
				'min-width': '84px',
				'top':($(this).position().top +$(this).height()*1.7).toString() +'px',
				'left':($(this).parent().position().left+20).toString() + 'px'
			};
			addto_div.css(cssObj);
			addto_div.show().removeClass('hid');
			$.ajax({
				url:'/ajax/get_addto_menu',
				type:'POST',
				data:{'authenticity_token':encodeURIComponent(AUTH_TOKEN)},
				dataType:'json'				
			}).done(function(json){
				if(json.status == 'suc'){
					$(tmp).parents('.upload-item').find('.shared-addto-menu').html(json.html);
				}
			});
			
		}else{
			addto_div.hide().addClass('hid');
			addto_div.html(loading);
		}
	});
	var removeStyle = function(){
		$('.shared-addto-menu > div').each(function(index,div){
			if (!$(div).hasClass('active-panel')) {
				$(div).attr('style','');
			};
		});
	};
	var removeActiveTag = function(){
		$('.shared-addto-menu > div').each(function(index,div){
				$(div).removeClass('active-panel');
		});
	};
	$('.shared-addto-menu').live('click',function(e){
		e.stopPropagation();
	});
	$('div.playlists ul li').live('click',function(){
		tmp = this;
		$.ajax({
			url:'/ajax/add_to_playlist_by_id',
			type:'POST',
			data:{'authenticity_token':encodeURIComponent(AUTH_TOKEN),'pid':$('span',tmp).attr('data-item-id'),'cwid':[$(tmp).parents('.upload-item').find('form input.id').val()]},
			dataType:'json'
		}).done(function(json){
			if(json.status == 'suc'){
				$('#addto-list-panel').animate({'left':'-='+$('#addto-list-panel').width().toString() + 'px',opacity:0},{queue:false,duration:400});
				removeActiveTag();
				$('#addto-list-saved-panel span.message > span').html(json.title);
				$('#addto-list-saved-panel').animate({'left':'-='+$('#addto-list-saved-panel').width().toString() + 'px',opacity:1},{queue:false,duration:400});
				$('.close-note').show().removeClass('hid');
				$('#addto-list-saved-panel').addClass('fade active-panel');
				removeStyle();
				KTV.summonQL(json.playlist_id,'1');
			}else if(json.status == 'onesuc'){
				$('#addto-list-panel').animate({'left':'-='+$('#addto-list-panel').width().toString() + 'px',opacity:0},{queue:false,duration:400});
				removeActiveTag();
				$('#addto-note-input-panel').show().removeClass('hid');
				$('.close-note').show().removeClass('hid');
				$('#addto-note-input-panel .yt-alert-message span.addto-title').html(json.title);
				$('#addto-note-input-panel').animate({'left':'-='+$('#addto-create-panel').width().toString() + 'px',opacity:1},{queue:false,duration:400});
				$('#addto-note-input-panel').addClass('fade active-panel');
				removeStyle();
				KTV.summonQL(json.playlist_id,'1');
			}else if(json.status == 'failed'){
				$('#addto-list-panel').animate({'left':'-='+$('#addto-list-panel').width().toString() + 'px',opacity:0},{queue:false,duration:400});
				removeActiveTag();
				$('#addto-list-error-panel span.error-details').html(json.reason);
				$('#addto-list-error-panel').animate({'left':'-='+$('#addto-list-panel').width().toString() + 'px',opacity:1},{duration:400});
				$('.close-note').show().removeClass('hid');
				$('#addto-list-error-panel').addClass('fade active-panel');	
				removeStyle();
			}
		});
	});
	$('#addto-list-panel > span[data-list-action="watch-later"]').live('click',function(e){
		tmp = this;
		$.ajax({
			url:'/ajax/add_to_read_later_array',
			type:'POST',
			data:{'authenticity_token':encodeURIComponent(AUTH_TOKEN),'cwid':[$(tmp).parents('.upload-item').find('form input.id').val()],'type':'addto'},
			dataType:'json'
		}).done(function(json){
			if(json.status == 'suc'){
				$('#addto-list-panel').animate({'left':'-='+$('#addto-list-panel').width().toString() + 'px',opacity:0},{queue:false,duration:400});
				removeActiveTag();
				$('#addto-list-saved-panel span.message > span').html('稍后阅读');
				$('.close-note').show().removeClass('hid');
				$('#addto-list-saved-panel').animate({'left':'-='+$('#addto-list-saved-panel').width().toString() + 'px',opacity:1},{queue:false,duration:400});
				$('#addto-list-saved-panel').addClass('fade active-panel');
				removeStyle();
				KTV.summonQL(json.playlist_id,'1');
			}else if(json.status == 'failed'){
				$('#addto-list-panel').animate({'left':'-='+$('#addto-list-panel').width().toString() + 'px',opacity:0},{queue:false,duration:400});
				removeActiveTag();
				$('#addto-list-error-panel span.error-details').html(json.reason);
				$('.close-note').show().removeClass('hid');
				$('#addto-list-error-panel').animate({'left':'-='+$('#addto-list-panel').width().toString() + 'px',opacity:1},{duration:400});
				$('#addto-list-error-panel').addClass('fade active-panel');	
				removeStyle();
			}
		});
	});
	$('#addto-list-panel > span[data-list-action="create-playlist"]').live('click',function(e){
		$('#addto-list-panel').animate({'left':'-='+$('#addto-list-panel').width().toString() + 'px',opacity:0},{queue:false,duration:400});
		$('#addto-create-panel').show().removeClass('hid');
		$('#addto-create-panel').animate({'left':'-='+$('#addto-create-panel').width().toString() + 'px',opacity:1},{queue:false,duration:400});
	});
	$('textarea#addto-create-playlist').live('focus',function(){
		if($(this).val().length > 0){
			$('.addto-create-playlist-label').hide().addClass('hid');
		}
	}).live('blur',function(){
		if($(this).val().length == 0){
			$('.addto-create-playlist-label').show().removeClass('hid');
		}
	});
	max = 60;
	$('textarea#addto-create-playlist').live('keyup',function(){
		if($(this).val().length > 0){
			$('.addto-create-playlist-label').hide().addClass('hid');
			$('.create-playlist-button').attr('disabled',false);
		}else{
			$('.addto-create-playlist-label').show().removeClass('hid');
			$('.create-playlist-button').attr('disabled',true);
		}
	  if($(this).val().length > max){
	      $(this).val($(this).val().substr(0, max));
	  }
	  $('.yt-uix-char-counter > .yt-uix-char-counter-remaining').html(max-$(this).val().length);
	});
	$('textarea#addto-note').live('keyup',function(){
		if($(this).val().length > 0){
			$('.addto-note-label').hide().addClass('hid');
			$('.playlist-save-note').attr('disabled',false);
		}else{
			$('.addto-note-label').show().removeClass('hid');
			$('.playlist-save-note').attr('disabled',true);
		}
	  if($(this).val().length > max){
	      $(this).val($(this).val().substr(0, max));
	  }
	  $('.addto-note-box > .yt-uix-char-counter-remaining').html(max-$(this).val().length);
	});
	$('.playlist-save-note').live('click',function(){
		tmp = this;
		$.ajax({
			url:'/ajax/save_note_for_one_cw',
			type:'POST',
			data:{'authenticity_token':encodeURIComponent(AUTH_TOKEN),'title':$('#addto-note-input-panel .yt-alert-message span.addto-title a').html(),'cwid':[$(tmp).parents('.upload-item').find('form input.id').val()],'note':$('#addto-note').val()},
			dataType:'json',
		  beforeSend: function ( xhr ) {
		  				$('#addto-note-input-panel').animate({'left':'-='+$('#addto-note-input-panel').width().toString() + 'px',opacity:0},{queue:false,duration:400});
		  				removeActiveTag();
		  				$('#addto-note-saving-panel').show().removeClass('hid');
		  				$('#addto-note-saving-panel').addClass('fade active-panel');
		  				$('#addto-note-saving-panel').animate({'left':'-='+$('#addto-note-input-panel').width().toString() + 'px',opacity:1},{queue:false,duration:400});
		  				removeStyle();
		  }
		}).done(function(json){
			$('#addto-note-saving-panel').animate({'left':'-='+$('#addto-note-saving-panel').width().toString() + 'px',opacity:0},{queue:false,duration:400});
			// $('#addto-note-input-panel').animate({'left':'-='+$('#addto-note-input-panel').width().toString() + 'px',opacity:0},{queue:false,duration:400});
			removeActiveTag();
			$('#addto-note-saved-panel').show().removeClass('hid');
			$('#addto-note-saved-panel span.message').html('备注已添加至：'+json.title);
			$('#addto-note-saved-panel').animate({'left':'-='+$('#addto-note-saved-panel').width().toString() + 'px',opacity:1},{queue:false,duration:400});
			$('#addto-note-saved-panel').addClass('fade active-panel');
			$('.close-note').show().removeClass('hid');
			removeStyle();
		})
	});
	$('.addto-create-cancel-button').live('click',function(){
		$('.close-note').trigger('click');
	});
	$('.create-playlist-button').live('click',function(){
		tmp = this;
		$.ajax({
			url:'/ajax/create_and_add_to_by_id',
			type:'POST',
			data:{'authenticity_token':encodeURIComponent(AUTH_TOKEN),'title':$('textarea#addto-create-playlist').val(),'is_private':$('input[name="is_private"]:checked').val(),'cwid':[$(tmp).parents('.upload-item').find('form input.id').val()]},
			dataType:'json'
		}).done(function(json){
			if(json.status == 'onesuc'){
				$('#addto-create-panel').animate({'left':'-='+$('#addto-create-panel').width().toString() + 'px',opacity:0},{queue:false,duration:400});
				removeActiveTag();
				$('#addto-note-input-panel').show().removeClass('hid');
				$('#addto-note-input-panel .yt-alert-message span.addto-title').html(json.title);
				$('#addto-note-input-panel').animate({'left':'-='+$('#addto-create-panel').width().toString() + 'px',opacity:1},{queue:false,duration:400});
				$('#addto-note-input-panel').addClass('fade active-panel');
				removeStyle();
				KTV.summonQL(json.playlist_id,'1');
			}else if(json.status == 'suc'){
				$('#addto-create-panel').animate({'left':'-='+$('#addto-create-panel').width().toString() + 'px',opacity:0},{queue:false,duration:400});
				removeActiveTag();
				$('#addto-list-saved-panel span.message > span').html(json.title);
				$('#addto-list-saved-panel').animate({'left':'-='+$('#addto-list-saved-panel').width().toString() + 'px',opacity:1},{queue:false,duration:400});
				$('.close-note').show().removeClass('hid');
				$('#addto-list-saved-panel').addClass('fade active-panel');
				removeStyle();
				KTV.summonQL(json.playlist_id,'1');
			}else if(json.status == 'failed'){
				$('#addto-create-panel').animate({'left':'-='+$('#addto-create-panel').width().toString() + 'px',opacity:0},{queue:false,duration:400});
				removeActiveTag();
				$('#addto-list-error-panel span.error-details').html(json.reason);
				$('#addto-list-error-panel').animate({'left':'-='+$('#addto-list-panel').width().toString() + 'px',opacity:1},{duration:400});
				$('.close-note').show().removeClass('hid');
				$('#addto-list-error-panel').addClass('fade active-panel');	
				removeStyle();
			}
		});
	});
	$('.close-note').live('click',function(){
		$('button.addto-button').removeClass('yt-uix-button-active');
		$(this).parent().hide().addClass('hid').html(loading);
		$(this).hide().addClass('hid');
	});
	$('a.show-menu-link').live('click',function(){
		$('#addto-list-panel').animate({'left':'+='+$('#addto-list-panel').width().toString() + 'px',opacity:1},{queue:false,duration:400});
		$('#addto-list-error-panel').animate({'left':'+='+$('#addto-list-panel').width().toString() + 'px',opacity:0},{queue:false,duration:400});
		$('.close-note').hide().addClass('hid');
	});
	var setDisable = function(){
	    $('.addto-button').attr('disabled',true);
			$('#vm-playlist-remove-kejian').attr('disabled',true);
	};
	var setEnable = function(){
	  $('button.addto-button').attr('disabled',false);
		$('#vm-playlist-remove-kejian').attr('disabled',false);
	}
	$(".post-upload-share").live("click",function(){
		tmp = this;
	  $(this).toggleClass('yt-uix-button-toggled');
	  if($(this).hasClass('yt-uix-button-toggled')){
	    $.ajax({
	       type:"POST",
	       url:'/ajax/get_share_panel',
	       data:{'authenticity_token':encodeURIComponent(AUTH_TOKEN),'cw_id':$(tmp).parents('.upload-item').find('form input.id').val()},
	       dataType: "html"
	    }).done(function(html){
				$(tmp).parents('.upload-item').find('.share-container.yt-rounded').removeClass('hid').show();
	      $(tmp).parents('.upload-item').find('.share-container.yt-rounded .share-container-inner').html(html).removeClass('hid').show();
	    });
	  }else{
			 $(tmp).parents('.upload-item').find('.share-container.yt-rounded').addClass('hid').hide();
			 $(tmp).parents('.upload-item').find('.share-container.yt-rounded .share-container-inner').addClass('hid').hide();
			 $('iframe[src="http://i.jiathis.com/url/jiathis_utility.html"]').remove();
			 $('iframe[src="http://v3.jiathis.com/code_mini/jiathis_utility.html"]').remove();
			 $('.jiathis_style').remove();
			 $('iframe').remove();
			 $('link[href="http://i.jiathis.com/url/css/jiathis_share.css"]').remove();
			 $('link[href="http://v3.jiathis.com/code_mini/css/jiathis_counter.css"]').remove();
			 $('script[src="http://tajs.qq.com/jiathis.php?uid=1351061699325921&dm=cnu.kejian.lvh.me"]').remove();
			 $('script[src*="//i.jiathis.com/url/shares.php"]').remove();
	  }      
	});
})(jQuery);