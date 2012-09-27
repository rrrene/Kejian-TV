var mg = {
	source: null,
	qwindow: null,
	videoids: null,
	videoidsE: null,
	v_m_p:null,
	init: function() {
		var KTV_Manage = $$('[_uc="mg"]')[0];
		if(!KTV_Manage) return;
		Event.observe(KTV_Manage, 'click', this.handler_event.bind(this));
		this.edit_init();
		this.list_init();
		this.parsev();
	},
	edit_init: function(){
		if(typeof $$('[_ucpage="editvideo"]')[0] == 'undefined')return;
		var videoTags = $('videoTags');
		videoTags.down('ul').select('a').each(function(o){
			o.onclick = function(){
				var vtags = $('vtags');
				if(vtags.value == ''){
					$('vtags').value = o.innerHTML;
				}else{
					$('vtags').value += ' ' + o.innerHTML;
				}
				o.up('li').remove();
				$('vtags').focus();
			};
		}.bind(this));
		$('video_edit_form').select('input','textarea').each(function(o){
			o.onfocus = function(){
				$('isvaluechange').innerHTML = 1;
			}
		}.bind(this));
		window.onbeforeunload = function(e){ 
			if($('isvaluechange').innerHTML == 1){			
				if(Prototype.Browser.IE){
					return "当前内容尚未保存，是否放弃？";
				}else{
					e.returnValue="当前内容尚未保存，是否放弃？";
					return "当前内容尚未保存，是否放弃？";
				}
			}
		};
	},
	list_init: function(){
		if(typeof $$('[_ucpage="listvideo"]')[0] == 'undefined')return;
		//this._changeheight();
		var videolist = $('videolist'),pageType='success',posttips;
		if(!videolist)return;
		if (window.location.href.match(/lost/i))pageType='lost';
		videolist.select('.check input').each(function(o){
			o.onclick = function(){
				if(o.checked == true){
					if(videolist.select('.check input:checked').length == videolist.select('.check input').length){
						$('check_all').checked = true;
						$('check_all_foot').checked = true;
					}
					o.up('tr').addClassName('highlight');
				}else{
					o.up('tr').removeClassName('highlight');
					$('check_all').checked = false;
					$('check_all_foot').checked = false;
				}
			};
		}.bind(this));
		
		videolist.select('tr').each(function(o){
			var share = o.down(".action .jiathis_style"),del = o.down(".action .del"),action = o.down(".action"),ktipscookie = Nova.Cookie.get('ktips');
			if(share)share.style.display = 'none';
			if(del)del.style.display = 'none';
			
			o.onmouseover = function(){
				if(share)share.style.display = 'block';
				if(del)del.style.display = 'inline-block';
			};
			o.onmouseout = function(){
				if(share)share.style.display = 'none';
				if(del)del.style.display = 'none';
			};
			
	        // if(!ktipscookie || ktipscookie != 1){
	       //      if(posttips !=1 && action && action.down('a[_hz="edit"]')){
	       //          var tipshtml = "<div class='post-tips' ><div class='con'><div class='arrow'></div><div class='cl' onclick=\"this.parentNode.parentNode.style.display='none'\"></div><p>新增自选封面功能，快来试试吧！</p><a href='javascript:;'>知道了!</a></div></div>";
	       //          action.insert(tipshtml);
	       //          posttips =1;
	       //          var tips = action.down(".post-tips"),knowtips = tips.down("a"),closetips = tips.down(".cl");
	       //          Event.observe(knowtips, 'click', function(){
	       //              tips.remove();
	       //              Nova.Cookie.set('ktips', 1, 365, '/u/', window.location.host);
	       //              return false;
	       //          }.bind(this));
	       //          Event.observe(closetips, 'click', function(){
	       //              tips.style.display = 'none';
	       //              return false;
	       //          }.bind(this));
	       //      }
	       //  }
			
		}.bind(this));
		
		videolist.select('.m_stat .stat_cont').each(function(o){
			var timer,tipcard,isHzOpen=1;
			o.onmouseover = function(){
				var data = o.readAttribute('data'),tips = o.down('.tips'),objRefer;
				if(!data || !tips)return;
				data = ('{'+decodeURIComponent(data)+'}').evalJSON(1);
				objRefer = o.down(1);
				
					if(data.type == 1 && !data.gethd){
						nova_request(function(res) {
							res = typeof res == 'object' ? res : res.stripScripts().evalJSON(true);
								//alert(res.error+'---'+res.status[data.vid].hd+'---'+res.status[data.vid].hd2+'---'+data.vid);
							if(data.hd == 1){
								if(res.status[data.vid].hd2 > 0){
									//bar0
									data.type = 10;
								}else{
									//无
								}
							}else{
								if(res.status[data.vid].hd > 0){
									if(res.status[data.vid].hd2 > 0){
										//bar1
										data.type = 11;
									}else{
										//bar3
										data.type = 13;
									}
								}else{
									//无
								}					
							}
							if(data.type >= 10){
								switch(data.type){
									case 10:
										tips.down('.process_stat').innerHTML = '<span>上传</span><span>转码</span><span>审核</span><span>高清</span><span>超清</span>';
										tips.down('.process_bar').addClassName('bar0');
										tips.down('.process_result').innerHTML = '超清转码中...';
										addMouseEvent();
										break;
									case 11:
										tips.down('.process_stat').innerHTML = '<span>上传</span><span>转码</span><span>审核</span><span>高清</span><span>超清</span>';
										tips.down('.process_bar').addClassName('bar1');
										tips.down('.process_result').innerHTML = '高清转码中...';
										addMouseEvent();
										break;
									case 13:
										tips.down('.process_stat').innerHTML = '<span>上传</span><span>转码</span><span>审核</span><span>高清</span>';
										tips.down('.process_bar').addClassName('bar3');
										tips.down('.process_result').innerHTML = '高清转码中...';
										addMouseEvent();
										break;
									default:
										tips.remove();
										break;				
								}
							}else{
								tips.remove();
							}
							data.gethd = 1; //不再请求高清借口标志
							data = encodeURIComponent(JSON.stringify(data).replace(/[{}]/g, ''));
							//data = encodeURIComponent(JSON.stringify(data).replace(/[{}]/g, ''));
							//o.setAttribute('data', data);
							o.writeAttribute('data', data);
						}.bind(this), '/u/videos/videohdquery', {ids:data.vid}, 'get');
					}else{
						addMouseEvent();
					}
				
					function addMouseEvent(){
						if(!tips)return;

						if(timer){ clearTimeout(timer); }
						timer = setTimeout(function(){
							if(!tipcard){
								tipcard = new Qcard();
							}
							tipcard
							.setRefer(objRefer)
							.setContent('html', tips.innerHTML)
							.show();
						if(isHzOpen == 1){
							if(pageType == 'lost'){
								try{hz.handler_object(1,'lost_status')}catch(e){};
							}else{
								try{hz.handler_object(1,'status')}catch(e){};
							}
							isHzOpen = 0;
						}

							tipcard.getNode().onmouseover = function(){clearTimeout(timer);tipcard.show();isHzOpen=0;};
							tipcard.getNode().onmouseout = function(){tipcard.hide(); isHzOpen = 0;};
						},200);
					}
				}.bind(this);
				o.onmouseout  = function(){
						if(timer){ clearTimeout(timer); }
						if(tipcard){
							timer = setTimeout(function(){ tipcard.hide();isHzOpen=1; },200);
						}
				}.bind(this);						
		}.bind(this));
	},
	handler_event: function(event) {
		var cmd;
		this.source = Element.extend(Event.element(event));
		if((cmd = this.source.getAttribute('_click'))) {
			try {mg[cmd](event);Event.stop(event);} catch(e) {alert(e)};
		}else{
			this.source = this.source.up('[_click]',0);
			if(this.source && (cmd = this.source.getAttribute('_click'))) {
				try {mg[cmd](event);Event.stop(event);} catch(e) {alert(e)};
			}
		}
	},
	parsev: function() {
		var players=$$('[_mg="player"]'), len=players.length, p, data, pbox={};
		if(!len) return;
		function _player(moviename) {
			return $(moviename?moviename:playerId);
			if (navigator.appName.indexOf("Microsoft") != -1)return window[moviename?moviename:playerId];
			return document[moviename?moviename:playerId];
		};
		function isPlayerLoading(){
			player = _player(playerId);
			mg.player = player;
			if(player != null){
				clearInterval(intervalId);
				$('add_swf_loading').style.display = 'none';
				//$('shot_btn').removeClassName('btn_disable');
			}else{
				//$('add_swf_loading').style.display = 'none';
				//$('shot_btn').removeClassName('btn_disable');
			}
		}
		var playerId="pswf_screenshot",intervalId;

			p = players[0];
			pbox.elm = p;
			if(!pbox.elm) return;
			data = decodeURIComponent('{'+pbox.elm.getAttribute('data')+'}').evalJSON(1);
			data.show_ce=0;
			data.showsearch=0;
			if(!data || !data.player) return;
			pbox.id = pbox.elm.id = 'pbox_screenshot';
			st.addswf(pbox.id, data);
			//setTimeout(function(){st.addswf(pbox.id, data);}.bind(this),5000);
			intervalId = setInterval(isPlayerLoading, 1000); 
	},
	chtab: function(event){
		this.source = Element.extend(Event.element(event));
		var titleEs = this.source.up('ul').select('li');
		if(navigator.userAgent.indexOf('Chrome')== -1 && mg.player && this.source.innerHTML =='系统封面')mg.player.pauseVideo(true);
		titleEs.each(function(o) {
			if(titleEs.indexOf(o) == 0){
				if(o.hasClassName("current")){
					titleEs[0].removeClassName('current');
					titleEs[0].innerHTML = '<a _click="chtab">' + titleEs[0].down('span').innerHTML + '</a>';
					titleEs[1].addClassName('current');
					titleEs[1].innerHTML = '<span>' + titleEs[1].down('a').innerHTML + '</span>';
					$$('[_mg="screenshot"]')[0].style.display='none';
					$$('[_mg="view"]')[0].style.display='block';
				}else{
					titleEs[0].addClassName('current');
					titleEs[0].innerHTML = '<span>' + titleEs[0].down('a').innerHTML + '</span>';
					titleEs[1].removeClassName('current');
					titleEs[1].innerHTML = '<a _click="chtab">' + titleEs[1].down('span').innerHTML + '</a>';
					$$('[_mg="screenshot"]')[0].style.display='block';
					$$('[_mg="view"]')[0].style.display='none';
				}
			}
		}.bind(this));
	},
	chlogo: function(event){
		this.source = Element.extend(Event.element(event));
		var imgEs = $$('[_mg="view"]')[0].down('ul').select('li');
		imgEs.each(function(o) {
			o.removeClassName('current');
		});
		this.source.up('li').addClassName('current');
		$('logo_e').down('img').src = this.source.src;
		$('logo_e').down('img').writeAttribute('_logo',this.source.readAttribute('_logo'));

		var klogocookie = Nova.Cookie.get('klogo');
		if(!klogocookie || klogocookie != 1){
			if($('logo_e').down('.post-tips'))$('logo_e').down('.post-tips').style.display = 'block';
		}
		$('logorevert').innerHTML = '<a href="javascript:;" _click="revertlogo">还原</a>';
		$('isvaluechange').innerHTML = 1;
	},
	revertlogo: function(event){
		this.source = Element.extend(Event.element(event));
		$('logorevert').innerHTML = '<span>还原</span>';
		var imglogo = $('logo_e').readAttribute('_logo'),imgsrc = $('logo_e').down('img').src;		
		$('logo_e').down('img').src = imgsrc.replace(/[^\/]+$/ig, imglogo);	
		$('logo_e').down('img').writeAttribute('_logo',imglogo);
		if($('loglists')){
			$('loglists').select("li").each(function(o){
				if(o.down("img").readAttribute('_logo') == imglogo){
					o.addClassName('current');
				}else{
					o.removeClassName('current');
				}
			}.bind(this));
		}
	},
	knowlogo: function(event){
		this.source = Element.extend(Event.element(event));
		this.source.up(1).remove();
		Nova.Cookie.set('klogo', 1, 365, '/u/', window.location.host);	
	},
	copy2Clipboard: function(obj){	
    	var tempval = $(obj).up(".item").down("input"),copyerror = $(obj).up(".managershare").down(".copyerror");
        try{
			copyerror.style.display = 'block';
            if(KTVUC.copy2ClipboardExec(tempval.value)!=false){  
				copyerror.innerHTML = '复制成功！';
            }else{
			   copyerror.innerHTML = '复制失败，请选中文字，在右键菜单中选择复制或按Ctrl+C复制';
        	   tempval.select();
            }
    	}catch(e){
		   copyerror.innerHTML = '复制失败，请选中文字，在右键菜单中选择复制或按Ctrl+C复制';
    	   tempval.select();
    	 }
    },
	svdel: function(event){
		try{hz.handler_object(1,'del_simple_video')}catch(e){};
		var ele = Element.extend(Event.element(event)),eleIsTrue;
		var inputlist = $("videolist").select('.check input');
		inputlist.each(function(o){
			if(o.checked == true){
				o.checked = false;
				o.istrue  = 1;
			}
		});
		
		ele.up("tr").down(".check input").checked = true;
		this.deletevideo(event);
		try{	
			inputlist.each(function(o){
				if(o.istrue == 1){
					o.checked = true;
					o.istrue  = null;
				}
			});
		}catch(e){};
	},
	screenshot: function(){
		try{hz.handler_object(1,'screenshot')}catch(e){};
		var isplay,fstat,vstat,isPause,playerId="pswf_screenshot",screenshot=$$('[_mg="screenshot"]')[0],loading = '<span class="ico__loading_16" style="width:20px;margin-left:10px;"></span>';
		//this.source = Element.extend(Event.element(event));
		function _player(moviename) {
			return $(moviename?moviename:playerId);
			if (navigator.appName.indexOf("Microsoft") != -1)return window[moviename?moviename:playerId];
			return document[moviename?moviename:playerId];
		};
		//isPause = _player().isPause();
		isPause = false; //暂停也可截图
		if(isPause){
			if(!this.qwindow)this.qwindow = this._createwin();
			this.qwindow
			.setSize(320,120)
			.setContent("html", document.getElementById("video_tips").innerHTML)
			.showHandle()
			.show();
			
		}else{
			_player().pauseVideo(true);
			fstat = _player().getPlayerState();
			fstat = fstat.split(/\|/);
			/*			
			if(parseInt('0x'+fstat[0].substr(10,8)) < 1335715200){
				if(!this.qwindow)this.qwindow = this._createwin();
				this.qwindow
				.setSize(240,110)
				.setContent("html", document.getElementById("cont5").innerHTML)
				.showHandle()
				.show();
				return;
			}
			*/
			vstat = _player().getNsData();
			screenshot.down('.mask').style.display = 'block';
			//screenshot.down('.pic').style.display = 'block';
			screenshot.down('.loading').style.display = 'block';
			mg._screenshot_able('no');
			nova_request(function(res) {
				//mg._screenshot_able('ok');
				if(!res) return;
				res = typeof res == 'object' ? res : res.stripScripts().evalJSON(true);
				if(res.error == 1){
					screenshot.down('.panel').style.display = 'block';
					screenshot.down('.pic').innerHTML = '<img src="' + res.src + '" _logo="' + res.id + '">';
					screenshot.down('.pic').style.display = 'block';
					screenshot.down('.loading').style.display = 'none';
				}else{
					alert('失败');
					screenshot.down('.mask').style.display = 'none';
					screenshot.down('.pic').style.display = 'none';
					screenshot.down('.loading').style.display = 'none';
				}
			}.bind(this), '/u/videos/shot', {"p":vstat.vid,"ts":fstat[fstat.length-1],"s":'big',"f":fstat[0]}, 'post');
			
			//alert(fstat[2]+'---'+fstat[4]+'--'+fstat[0]);
			
		}
	},
	_screenshot_able: function(type){
		if(type == 'ok'){
			$('shot_btn').removeClassName('btn_disable');
			$('shot_btn').onclick = function(){
				mg.screenshot();
			};
		}else{
			$('shot_btn').addClassName('btn_disable');
			$('shot_btn').onclick = function(){
			};
		}
	},
	shotok: function(event){
		this.source = Element.extend(Event.element(event));
		try{hz.handler_object(this.source)}catch(e){};
		mg._screenshot_able('ok');
		var screenshot=$$('[_mg="screenshot"]')[0];
		this.source = Element.extend(Event.element(event));
		screenshot.down('.mask').style.display = 'none';
		screenshot.down('.pic').style.display = 'none';
		screenshot.down('.panel').style.display = 'none';
		$('logo_e').down('img').src = screenshot.down('.pic').down('img').src;
		$('logo_e').down('img').writeAttribute('_logo',screenshot.down('.pic').down('img').readAttribute('_logo'));
		
		var klogocookie = Nova.Cookie.get('klogo');
		if(!klogocookie || klogocookie != 1){
			if($('logo_e').down('.post-tips'))$('logo_e').down('.post-tips').style.display = 'block';
		}
		$('logorevert').innerHTML = '<a href="javascript:;" _click="revertlogo">还原</a>';
		$('isvaluechange').innerHTML = 1;
	},
	shotno: function(event){
		this.source = Element.extend(Event.element(event));
		try{hz.handler_object(this.source)}catch(e){};
		mg._screenshot_able('ok');
		var screenshot=$$('[_mg="screenshot"]')[0];
		this.source = Element.extend(Event.element(event));
		screenshot.down('.mask').style.display = 'none';
		screenshot.down('.pic').style.display = 'none';
		screenshot.down('.panel').style.display = 'none';
	},
	setpass: function(event){
		//this.source = Element.extend(Event.element(event));
		$('lockPasswd').style.display = 'inline-block';
	},
	setnopass: function(event){
		//this.source = Element.extend(Event.element(event));
		$('lockPasswd').style.display = 'none';
	},
	edit_submit: function(event){
		if(event && event == 'ok'){
			$('isvaluechange').innerHTML = '';
			$('video_edit_form').submit();
		}else{
			try{hz.handler_object(1,'edit_commit')}catch(e){};
			this._modifyVideoInfo();
		}
	},
	edit_cancel: function(event){
		try{hz.handler_object(1,'edit_cancle')}catch(e){};
        window.opener=null;
        window.open('', '_self', ''); 
        window.close(); 
/*		
		if(!this.qwindow)this.qwindow = this._createwin();
		this.qwindow
		.setSize(330,110)
		.setContent("html", document.getElementById("submit_tips").innerHTML)
		.show();
*/
	},
	cancelok: function(event){
		window.opener=null;
		window.open("","_self") 
		window.close();
	},
	cancelno: function(event){
		this.qwindow.hide(event);
	},
	//list func
	check_all: function(id){
		var ele;
		if(id == 2){
			ele = $('check_all_foot');
		}else{
			ele = $('check_all');
		}
		
		var videolist = $('videolist');
		if(!videolist)return;
		if(ele.checked == true){
			videolist.select('.check input').each(function(o){
				if(o.disabled == false){
					o.checked = true;
					o.up('tr').addClassName('highlight');
				}
			}.bind(this));
			$('check_all').checked = true;
			$('check_all_foot').checked = true;
		}else{
			videolist.select('.check input').each(function(o){
				o.checked = false;
				o.up('tr').removeClassName('highlight');
			}.bind(this));
			$('check_all').checked = false;
			$('check_all_foot').checked = false;
		}
	},
	checkall2: function(){
	alert(12);
	},
	dropmenu: function(event){
		this.source = Element.extend(Event.element(event));
		var panel = $('panel');
		function toggle(o){
			if(!o)return;
			if(o.style.display == 'none'){
				o.style.display = 'block';
			}else{
				o.style.display = 'none';
			}
		}
		toggle(panel);
		document.body.onclick = function(){
			$('panel').style.display = 'none';
		}
		Event.stop(event);
	},
	deletevideo: function(event){
		this.source = Element.extend(Event.element(event));
        // try{hz.handler_object(this.source)}catch(e){};
		var videolist = $('videolist'),videoids = new Array(),videoidsE = new Array(),videoidsStr='';
		if(!videolist){
		    alert('您还没有勾选课件');
			return;
		}
      
		videolist.select('.check input').each(function(o){
			if(o.checked == true){
				videoids.push(o.value);
				videoidsStr += o.value + ',';
				videoidsE.push(o.up('tr'));
			}
		}.bind(this));
		this.videoids   = videoidsStr.replace(/\|$/ig, "");
		this.videoidsE = videoidsE;
		
		if(videoids.length >= 1){
				if(videoids.length == 1){
                      if(confirm('您确定要删除此课件么？')){
                           new Ajax.Request('/mine/delete',{
                                method:'post',
                                parameters:{'kj_ids':this.videoids},
                                onLoading: function(){
                                  document.getElementById('tmpdel').innerHTML = "Loading";
                                },
                                onSuccess: function(transport) {
                                    alert('Succeed');
                                },
                                onFailure: function(transport) {
                                  var response =  transport.responseText || "连接错误.";
                                  // alert(response);
                                }
                            });
                     }
				}else{
				    if(confirm('您将删除'+videoids.length+'个视频，请确认。')){
				         new Ajax.Request('/mine/delete',{
                                  method:'post',
                                  parameters:{'kj_ids':this.videoids},
                                  onLoading: function(){
                                    document.getElementById('tmpdel').innerHTML = "Loading";
                                  },
                                  onSuccess: function(transport) {
                                      alert('Succeed');
                                  },
                                  onFailure: function(transport) {
                                    var response =  transport.responseText || "连接错误.";
                                    // alert(response);
                                  }
                              });
				    }
				}
		}else{
              alert('您还没有勾选课件');
    		  return;
		}
	},
	deletevideook: function(act){
		if(!act)return;
		switch(act){
			case 'single' :
				return;
			case 'some' :
				var passwd = $(this.qwindow.dom.winbody).down('.form_input').value;
				nova_request(function(res) {
					if(1 == res){
						Nova.Cookie.set('v_m_p', 1, 1/24, '/u/', window.location.host);
					}
					if(1 == this.v_m_p || 1 == res){
							nova_request(function(res) {
								this.qwindow.hide();
								if(res != 1){
									this.qwindow
									.setSize(240,110)
									.setContent("html", document.getElementById("cont5").innerHTML)
									.showHandle()
									.show();
									/*$(this.qwindow.dom.winbody).down('.tips_title').innerHTML = '<span class="ico__fail"><em>提示</em></span>删除失败';
									setTimeout(function(){
										this.qwindow.hide();
									}.bind(this), 3000);
									*/
								}else{
									for(i=0; i<this.videoidsE.length; i++){
										if(this.videoidsE[i].readAttribute("_mgrecoment")){
											this.videoidsE[i].down(".l_b_v_c").innerHTML = "正在推荐&#12288;<em></em>不可删除";
										}else{
											this.videoidsE[i].remove();
										}
									}
									this.qwindow
									.setSize(130,60)
									.setContent("html", document.getElementById("cont4").innerHTML)
									.hideHandle()
									.hideMask()
									.show();
									setTimeout(function(){
										this.qwindow.hide();
									}.bind(this), 3000);
									var tempvideolist = $('videolist').select("tr");
									if(tempvideolist.length>0){
										for(i=0; i<tempvideolist.length; i++){
											if(i%2 == 0){
												tempvideolist[i].removeClassName("manager_even");
											}else{
												tempvideolist[i].addClassName("manager_even");
											}
										}
									}else{
									  if ( window.location.href.match(/videos\/lost/im)) {
											window.location="/u/videos/lost";
										} else {
											window.location="/u/videos";
										}
									}
								}
								return;	
							}.bind(this), '/u/videos/delete', {"vids":this.videoids}, 'post');
							return;	
					}else{
							var passE = $(this.qwindow.dom.winbody).down('.form_input'),passErrorE = $(this.qwindow.dom.winbody).down('.error');
							passErrorE.style.display = 'block';
							if(passwd == ''){passErrorE.innerHTML = '请输入密码';}else{passErrorE.innerHTML = '密码错误，请检查';};
							this.qwindow.setSize(360,170);
							passE.addClassName('form_input_error');
							passE.onfocus = function(o){
								passE.removeClassName('form_input_error');
								this.qwindow.setSize(360,150);
								passErrorE.style.display  = 'none';
							}.bind(this);
							return;	
					}
				}.bind(this), '/u/videos/verifypass', {"passwd":passwd}, 'post');
				return;	
			default :
				return;
		}
	},
	getPlaylit: function(o){
		this.source = $(o);
		try{hz.handler_object(1,'add_playlist')}catch(e){};
		var page = this.source.readAttribute('_p'),videosMaxNum=200,avilableNum=0;
		if(page == 0){
			var videoids='',videolist = $('videolist');
			if(!videolist){
				if(!this.qwindow)this.qwindow = this._createwin();
				this.qwindow
					.setSize(190,60)
					.setContent("html", document.getElementById("cont3").innerHTML)
					.hideHandle()
					.hideMask()
					.show();
					$(this.qwindow.dom.winbody).down('.tips_title').innerHTML = '<span class="ico__fail"><em>提示</em></span>您还没有勾选视频';
				
				setTimeout(function(){
					this.qwindow.hide();
				}.bind(this), 3000);
				return;
			}
			this.videosNum=0;
			videolist.select('.check input').each(function(o){
				if(o.checked == true){
					videoids += o.value + '|';
					++this.videosNum;
				}
			}.bind(this));
			videoids = videoids.replace(/\|$/ig, "");
			if(videoids == ''){
				if(!this.qwindow)this.qwindow = this._createwin();
				this.qwindow
				.setSize(190,60)
				.setContent("html", document.getElementById("cont3").innerHTML)
				.hideHandle()
				.hideMask()
				.show();
				$(this.qwindow.dom.winbody).down('.tips_title').innerHTML = '<span class="ico__fail"><em>提示</em></span>您还没有勾选视频';
				setTimeout(function(){this.qwindow.hide();}.bind(this),3000);
				return;
			}

			if(!this.PlaylistW)this.PlaylistW= this._createwin();
			this.PlaylistW
			.setSize(650,560)
			.setContent("html", document.getElementById("listEditBox").innerHTML)
			.showHandle();
			this.PlaylistW.submit = function(){
				var playlistids='',l_b_select = $(this.PlaylistW.dom.winbody).down('.l_b_select');			
				l_b_select.select('li input').each(function(o){
					if(o.checked == true){
						playlistids += o.value + '|';
					}
				}.bind(this));
				playlistids = playlistids.replace(/\|$/ig, "");
				if(playlistids == ''){
					alert('你没有选择任何专辑！');
					return;
				}
				nova_request(function(res) {
					/*
					if(res.error == 1){
						alert('成功添加到专辑！');
					}else{
						alert('失败，请刷新页面重试！');
					}
					*/
					/*
					this.qwindow
						.setSize(130,60)
						.setContent("html", document.getElementById("cont4").innerHTML)
						.hideHandle()
						.show();
					setTimeout(function(){
					this.qwindow.hide();
					}.bind(this), 3000);
					*/
						this.PlaylistW.hide();
						if ( window.location.href.match(/success\/unsort/im)) {
							videolist.select('.check input').each(function(o){
								if(o.checked == true){
									o.up('tr').remove();
								}
							}.bind(this));
								var tempvideolist = $('videolist').select("tr");
									if(tempvideolist.length<1)
										window.location="/u/videos/success/unsort";
						} else {
							videolist.select('.check input').each(function(o){
								if(o.checked == true){
									o.checked = false;
									o.up('tr').removeClassName('highlight');
								}
							}.bind(this));					
						}
						$('check_all').checked = false;
						$('check_all_foot').checked = false;
						
						if(!this.qwindow)this.qwindow = this._createwin();
						this.qwindow
							.setSize(130,60)
							.setContent("html", document.getElementById("cont4").innerHTML)
							.hideHandle()
							.hideMask()
							.show();
							$(this.qwindow.dom.winbody).down('.tips_title').innerHTML = '<span class="ico__success"><em>提示</em></span>添加成功';
						
						setTimeout(function(){
							this.qwindow.hide();
						}.bind(this), 3000);
				}.bind(this), '/u/videos/addvideo2folder', {"vids":videoids,"pids":playlistids}, 'post');
			}.bind(this);
		}
		if(!page || page < 1)page=1;
		nova_request(function(res) {
		    //初始化
			$(this.PlaylistW.dom.winbody).down('.l_b_Pager').innerHTML = res.pager;
			var htmlstr = '',l_b_all = $(this.PlaylistW.dom.winbody).down('.l_b_all'),l_b_select = $(this.PlaylistW.dom.winbody).down('.l_b_select'),l_b_ex = $(this.PlaylistW.dom.winbody).down('.l_b_ex'),l_b_sub = $(this.PlaylistW.dom.winbody).down('.l_b_sub'),disableStr,disableStr2,disableStr3;
			for(var i = 0;i < res.list.length;i++){
				avilableNum = videosMaxNum - res.list[i].contentTotal;
				disableStr = avilableNum >= this.videosNum ? '': ' disable';
				disableStr2 = avilableNum >= this.videosNum ? '': ' disabled';
				disableStr3 = avilableNum >= this.videosNum ? '': ' _num="'+res.list[i].contentTotal+'"';
				if(i%2 == 0){
					htmlstr +='<li class="odd'+ disableStr +'" '+disableStr3+'><div><input '+disableStr2+' type="checkbox" value="'+ res.list[i].folderId +'"></div><span title="'+res.list[i].folderName+'">'+res.list[i].folderShortName+'<span class="num">('+res.list[i].contentTotal+')</span></span></li>';
				}else{
					htmlstr +='<li class="even'+ disableStr +'" '+disableStr3+'><div><input '+disableStr2+' type="checkbox" value="'+ res.list[i].folderId +'"></div><span title="'+res.list[i].folderName+'">'+res.list[i].folderShortName+'<span class="num">('+res.list[i].contentTotal+')</span></span></li>';
				}
			}
			l_b_ex.innerHTML = '将'+this.videosNum+'个视频添加到专辑';
			l_b_all.innerHTML = htmlstr;
			l_b_all.select('li').each(function(o){
				checkint = 0;
				l_b_select.select('li').each(function(o2){
					if(o.down('input').value == o2.down('input').value)checkint = 1;
				}.bind(this));
				if(checkint == 1){
					o.down('input').checked = true;
				}else{
					o.down('input').checked = false;
				}
			}.bind(this));
			
			//添加事件
			l_b_all.select("li").each(function(o){
				o.down('input').onclick = function(){
					if(o.down('input').checked == true){
						l_b_select.innerHTML = '<li class="odd">'+o.innerHTML+'</li>';
						l_b_select.select("li").each(function(os){os.down('input').checked = true;});
						l_b_all.select("li").each(function(oo){
							if(o.down('input').value != oo.down('input').value){
								oo.addClassName('disable');
								oo.down('input').disabled = true;	
							}
						}.bind(this));
					}else{
						l_b_select.innerHTML = '';
						l_b_all.select("li").each(function(oo){
							if(oo.readAttribute('_num')){
								oo.addClassName('disable');
								oo.down('input').disabled = true;
							}else{
								oo.removeClassName('disable');
								oo.down('input').disabled = false;
							}
						}.bind(this));
					}
					mg._playlist_isdata();
				}
			});
			
			if(l_b_select.select('li').length > 0){
				l_b_all.select('li').each(function(o){
					if(o.down('input').checked != true){
						o.addClassName('disable');
						o.down('input').disabled = true;
					}
				}.bind(this));
			}
			mg._playlist_isdata();
			this.PlaylistW.show();
		}.bind(this), '/u/videos/listfolder', {"pl":page}, 'get');
	},
	PlaylistS: function(type){
		if(!this.PlaylistW)return;
		var checkint = 0,l_b_all = $(this.PlaylistW.dom.winbody).down('.l_b_all'),l_b_select = $(this.PlaylistW.dom.winbody).down('.l_b_select'),l_b_sub = $(this.PlaylistW.dom.winbody).down('.l_b_sub'),
		l_b_Pager = $(this.PlaylistW.dom.winbody).down('.l_b_Pager'),menus = $(this.PlaylistW.dom.winbody).down('.menus');
		if(type == 1){
			menus.innerHTML = '<li><a onclick="mg.PlaylistS(0);">全部</a></li><li class="current"><span>已选</span></li>';
			l_b_all.style.display = 'none';
			l_b_Pager.style.display = 'none';
			l_b_select.style.display = 'block';
			l_b_select.select('li').each(function(o){
				o.onclick = function(){o.remove();mg._playlist_isdata();}.bind(this);
			}.bind(this));
		}else{
			menus.innerHTML = '<li class="current"><span>全部</span></li><li><a onclick="mg.PlaylistS(1);">已选</a></li>';
			l_b_all.style.display = 'block';
			l_b_Pager.style.display = 'block';
			l_b_select.style.display = 'none';
			
			l_b_all.select('li').each(function(o){
			
				if(o.readAttribute('_num')){
					o.addClassName('disable');
					o.down('input').disabled = true;
				}else{
					o.removeClassName('disable');
					o.down('input').disabled = false;
				}
				o.down('input').checked = false;
				l_b_select.select('li').each(function(o2){
					if(o.down('input').value == o2.down('input').value && o2.down('input').checked == true){
						o.down('input').checked = true;
					}else{
						o.down('input').checked = false;
					}
				}.bind(this));
			}.bind(this));
			if(l_b_select.select('li').length > 0){
				l_b_all.select('li').each(function(o){
					if(o.down('input').checked != true){
						o.addClassName('disable');
						o.down('input').disabled = true;
					}
				}.bind(this));
			}
		}
		mg._playlist_isdata();
	},
	_playlist_isdata: function(){
		var l_b_all = $(this.PlaylistW.dom.winbody).down('.l_b_all'),l_b_select = $(this.PlaylistW.dom.winbody).down('.l_b_select'),l_b_sub = $(this.PlaylistW.dom.winbody).down('.l_b_sub');
	if(l_b_select.select('li').length > 0){
			l_b_sub.removeClassName('form_btn_disabled');
			l_b_sub.onclick = function(){
				mg.PlaylistW.submit();
			};
		}else{
			l_b_sub.addClassName('form_btn_disabled');
			l_b_sub.onclick = function(){
					//
			};
		}
	},
	unrecommend: function(){
		if(!this.qwindow)this.qwindow = this._createwin();
		this.qwindow
		.setSize(340,200)
		.setContent("html", document.getElementById("cont2").innerHTML)
		.showHandle()
		.show();
	},
	unrecommendok: function(){
		this.qwindow.hide();
		window.open('http://www.youku.com/service/feed/subtype/4');
	},
	//inner func
	_createwin: function(){
		qwindow = new Qwindow({
			'zindex': 2000,
			'elements': 'select',			
			'showmask': true
		});
		return qwindow;
	},
	_alert: function(title,msg,eleid,eleids){
		if(eleids){
			$(eleids.ele).scrollTo();
			$(eleids.pos).insert({after: $('input_error')});
			$('input_error').style.display = 'block';
			$('input_error').innerHTML = msg;
			$(eleids.eclick).onclick = function(o){
				$('input_error').style.display = 'none';
			}
		}else{
			if(eleid){
				$(eleid).addClassName('form_input_error');
				$(eleid).onfocus = function(o){
					$(eleid).removeClassName('form_input_error');
					$('input_error').style.display = 'none';
				}
				$(eleid).insert({after: $('input_error')});
				$('input_error').style.display = 'block';
				$('input_error').innerHTML = msg;
				$(eleid).scrollTo();
			}
		}
	},
	_modifyVideoInfo: function(){
        // 视频标题
        var vtitle = trim($F('vtitle'));
        if(empty(vtitle)){
            mg._alert('错误','请填写视频标题','vtitle');
            return;
        }
		// 视频标签
        var vtags = trim($F('vtags'));
        if(empty(vtags)){
            mg._alert('错误','请填写标签！','vtags');
            return;
        }

        // 视频分类
        var syscate = document.getElementsByName('v_syscate[]');
        if(null == syscate || 0 == syscate.length){
            mg._alert('错误','获得分类信息失败！','v_catepannel',{"pos":"cate_err","ele":"v_catepannel","eclick":"v_catepannel"});
            return;
        }

        var cateid = null;
        for(var i=0; i<syscate.length; ++i){
            if(syscate[i].checked) cateid = syscate[i].value;
        }
        if(cateid === null){
            mg._alert('错误','请选择一个类别！','v_catepannel',{"pos":"cate_err","ele":"v_catepannel","eclick":"v_catepannel"});
            return;
        }
		
       // 视频版权
        var sourceType = $('sourceType0').checked ? $('sourceType0').value : $('sourceType1').value;

        // 隐私设置
        var publictype = $('publictypeOpen').value;
        var lockPasswd = $('lockPasswd').value;
        if ($('publictypePass').checked){
            if(empty(lockPasswd)) {
				mg._alert('错误','没有输入密码!','lockPasswd');
                return;
            }
            publictype = $('publictypePass').value;
        }else if($('publictypeFriend').checked){
            publictype = $('publictypeFriend').value;
        }

        // 视频截图
        var logo = $('logo_e').down('img').readAttribute('_logo');
        if(!logo){
        	mg._alert('错误','获取视频logo失败，重新截图或刷新重新编辑试一试！','logo_e');
            return;
        }
		logo = trim(logo);
		nova_request(function(res) {
        	switch(parseInt(res)){
        		case -1 : mg._alert('错误','请填写标签','vtags'); return;
        		case -2 : mg._alert('错误','最多可以设置10个标签','vtags'); return;
        		case -3 : mg._alert('错误','单个标签最少2个字','vtags'); return;
        		case -4 : mg._alert('错误','单个标签最多6个字','vtags'); return;
        		case -5 : mg._alert('错误','单个标签最少2个字','vtags'); return;
        		case -6 : mg._alert('错误','单个标签最多6个字','vtags'); return;
        		case -7 : mg._alert('错误','标签含有禁忌词，不能提交！','vtags'); return;
        		default : nova_request(function(res) {
								switch(res){
						        case -1 : mg._alert('错误','视频标题含有禁忌词！请重新填写视频标题！','vtitle'); return;
						        case -2 : mg._alert('错误','视频简介含有禁忌词！请重新填写视频简介！','vmemo'); return;
						        case -3 : mg._alert('提示','视频已被网站推荐，不能修改信息！请与网站内容部门联系！','vmemo'); return;
						        case 'ok' : mg.edit_submit('ok');return;  // 跳至成功页
						        default : mg._alert('错误','视频信息修改失败！请及时与管理员联系。',null);
						    }
						}.bind(this), '/u/videos/update', {'vid':$F('videoid'),'title':vtitle,'tags':vtags,'cateid':cateid,'memo':$F('vmemo'),'logo':logo,'sourcetype':sourceType, 'sourceTypeOrig':0, 'publictype':publictype,'ispkvideo':0, 'password': lockPasswd}, 'post');
        	}
		}.bind(this), '/u/videos/verifytags', {"tags":vtags}, 'post');
		return;
	},
	_changeheight:function(){
		function findDimensions(){ //函数：获取尺寸 
			//获取窗口宽度 
			if (window.innerWidth) 
				winWidth = window.innerWidth; 
			else if ((document.body) && (document.body.clientWidth)) 
				winWidth = document.body.clientWidth; 
			
			//获取窗口高度 
			if (window.innerHeight) 
				winHeight = window.innerHeight; 
			else if ((document.body) && (document.body.clientHeight)) 
				winHeight = document.body.clientHeight; 
		
           //通过深入Document内部对body进行检测，获取窗口大小 
			if (document.documentElement && document.documentElement.clientHeight && document.documentElement.clientWidth){ 
				winHeight = document.documentElement.clientHeight; 
				winWidth = document.documentElement.clientWidth; 
			} 
				//结果输出至两个文本框 
			return {'width':winWidth,'height':winHeight}; 
		}
		
		$$(".KTV_body")[0].style.minHeight = '300px';
		var size = findDimensions(),m_conE = $$(".manager_con")[0],m_con_bdE = $$(".manager_con")[0].down('.bd');
		//alert(size.height);
		//alert(m_conE.getHeight());
		if(size.height - 210 < m_conE.getHeight()){
			if(size.height - 210 > 184){
				m_conE.style.height = (size.height - 210) + 'px';
				m_con_bdE.style.height = (size.height - 234) + 'px';
			}else{
				m_conE.style.height = '184px';
				m_con_bdE.style.height = '160px';
			}
		}
		//alert(m_conE.getHeight());
	}
};
function onPlayerStart(){
	mg._screenshot_able('ok');
};
function onPlayerComplete(){
	mg._screenshot_able('no');
}
function ready_init_mg() {
	mg.init();
}
ready_init_mg.defer();
