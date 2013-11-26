var G_PLAYER_INSTANCE=(function(){
	
	var argumentsToArray = function(args){
		var result = [ ];
		for(var i=0; i<args.length; i++)
			result.push(args[i]);
		return result;
	};
	function _$(obj){
		this.obj = obj;
	}

	extend2(_$.prototype,{
		bind:function(name,handle){
			if(this.obj.addEventListener){
				this.obj.addEventListener(name,handle, false);
			}
			else if(this.obj.attachEvent){
				this.obj.attachEvent("on" + name, handle);
			}
			return this;
		},
		removeClass:function(){
			this.obj.className='';
			return this;
		},
		addClass:function(name){
			this.obj.className = this.obj.className + ' ' + name;
			return this;
		},
		html:function(str){
			this.obj.innerHTML = str;
			return this;
		},
		css:function(param){
			for(var i in param){
				this.obj.style[i] = param[i];
			}
			return this;
		},
		show:function(){
			this.obj.style.display='';
			return this;
		},
		hide:function(){
			this.obj.style.display='none';
			return this;
		},
		attr:function(name,value){
			if(!value){
				return this.obj.getAttribute(name);
			}
			else{
				this.obj.setAttribute(name,value);
				return this;
			}
		}
	});
	

	
	function $(obj){
		if(typeof obj == 'string') return new _$(document.getElementById(obj));
		return new _$(obj);
	}

	Function.prototype.delayApply = function(time, thisObj, argArray){
		var f = this;
		return setTimeout( function() {
			f.apply(thisObj, argArray);
		}, time);
	};
	Function.prototype.delayCall = function(time, thisObj){
		return this.delayApply(time, thisObj, argumentsToArray(arguments).slice(2))
	};

	function extend(subClass,superClass){
		var F = function(){};
		F.prototype = superClass.prototype;
		subClass.prototype = new F();
		subClass.prototype.constructor = subClass;
		subClass.superclass = superClass.prototype;
		if(superClass.prototype.constructor == Object.prototype.constructor){
			superClass.prototype.constructor = superClass;
		}
	}
	function extend2(sup,sub){
		for(var i in sub){
			sup[i] = sub[i];
		}
	}

	function Event(){
		this.attachEvent = this.addEventListener;
		this.detachEvent = this.removeEventListener;
		this.fireEvent = this.dispatchEvent;
		this.events={};
	}
	Event.prototype = {
		addEventListener:function(_n,sEvent,fpNotify,tDelay){
			if(!this.events[sEvent]) this.events[sEvent] = [];
			for(var i=0; i<this.events[sEvent].length; i++)
				if(this.events[sEvent][i].o == this && this.events[sEvent][i].f == fpNotify)
					return true;
			this.events[sEvent].push( {o: this, f: fpNotify, t: tDelay} );
			return this;
		},
		removeEventListener:function(sEvent, fpNotify){
			if(!this.events[sEvent] || !(this.events[sEvent] instanceof Array))
				return false;
			for(var i=0; i<this.events[sEvent].length; i++)
				if(this.events[sEvent][i].o == this && this.events[sEvent][i].f == fpNotify) {
					this.events[sEvent].splice(i, 1);
					if(0 == this.events[sEvent].length)
						delete this.events[sEvent];
					return this;
				}
			return this;
		},
		dispatchEvent:function(sEvent)
		{	
			if(!this.events[sEvent] || !(this.events[sEvent] instanceof Array))
				return false;
			var args = [this].concat( argumentsToArray(arguments) );
			var listener = this.events[sEvent].slice(0);
			for(var i=0; i<listener.length; i++)
				if(typeof(listener[i].t) == "number")
					listener[i].f.delayApply( listener[i].t, listener[i].o, args );
				else
					listener[i].f.apply( listener[i].o, args );
			return this;
		}
	};
	
	function Error(){
		this.msg={
			1:"用户终止播放",
			2:"网络异常，请检查你的网络情况",
			3:"解码错误，请稍候重试",
			4:"播放无效，请稍后重试"
		}
	}

	Error.prototype.m = function(code){
		
	}

	function Log(){
		
	}
	
	function Core(){
		Core.superclass.constructor.call(this);
		this.error = new Error();
		this.currentTime = 0;
		this.init();
		this.isFullScreen = false;
		this.retryTimes={};
	}
	extend(Core,Event);
	
	extend2(Core.prototype,{
		init:function(){
			//XL_CLOUD_FX_INSTANCE.init(this);
		},
		printObject:function(id){
			var that = this;
			var obj = document.getElementById(id);
			obj.innerHTML='<video id="xl_vod_fx_flash_box" width="100%" height="94%" style="z-index: 100;" controls="controls"></video><div id="xl_button_box" style="width:100%;height:6%;line-height:22px;text-align:right;"><button format="p" id="xl_pbutton" style="margin-right:5px;"></button><button format="g" id="xl_gbutton" style="margin-right:5px;"></button><button format="c" id="xl_cbutton" style="margin-right:5px;"></button></div>';
			this.video = document.getElementById('xl_vod_fx_flash_box');
			this.isplay = false;

			setTimeout(function(){
				$(that.video).bind('timeupdate',function(){
					that.currentTime = this.currentTime;
					that.fireEvent('timeupdate');
				})
				.bind('error',function(){
					var code = 	this.error.code;			
					if(this.error.code==2 || this.error.code==4){
						var n = new Date();
						var _key = n.getHours() +':' +n.getMinutes();
						if(typeof(that.retryTimes[_key])=='undefined'){
							that.retryTimes[_key] = 1;
						}
						else that.retryTimes[_key]++;
						var url = that.getUrl();
						if(that.retryTimes[_key]<=3){
							that.debug("重试" + that.retryTimes[_key].toString());
							that.setUrl(url,that.getPlayPosition());
						}
						else{
							that.isplay = false;
							that.stop();
							that.fireEvent('errorexit');
						}
					}
					
					that.fireEvent('error',code);
				})
				.bind('ended',function(){
					that.isplay = false;
					that.fireEvent('ended');
				})
				.bind('play',function(){
					that.isplay = true;
					that.fireEvent('onplaying');
					$('xl_button_box').show();
				})
				.bind('pause',function(){
					that.isplay = false;
					that.fireEvent('pause');
				})
				.bind('seeked',function(){
					that.fireEvent('onSeek');
					console.log('seeked');
					
				}).bind('playing',function(){
					that.isplay = true;
					that.fireEvent('playing');
				})
				.bind('loadedmetadata',function(){
					that.debug('loadedmetadata'+new Date());
					var obj = that.video;
					$(obj).bind('dblclick',function(){
						that.FullScreen();
					});
					//$(document).keypress(function(event){
					//	if(this.isFullScreen && event.charCode==27) that.FullScreen();
					//});
				}).
				bind('canplay',function(){
					that.debug('canplay'+new Date());
				});
				
				$('xl_pbutton').bind('click',function(){
					XL_CLOUD_FX_INSTANCE.setFormats(this,'ipad','p');
				});
				$('xl_gbutton').bind('click',function(){
					XL_CLOUD_FX_INSTANCE.setFormats(this,'ipad','g');
				});
				$('xl_cbutton').bind('click',function(){
					XL_CLOUD_FX_INSTANCE.setFormats(this,'ipad','c');
				});
				that.fireEvent('onload');
			},20);
		},
		setFormats:function(norms){
		
			if(norms.c.enable){
				$('xl_cbutton').attr('disabled',false);
				if(norms.c.checked){
					$('xl_pbutton').html('流畅');
					$('xl_gbutton').html('高清');
					$('xl_cbutton').html('• 超清');
				}
			}
			else{
				$('xl_cbutton').attr('disabled',true);
			}
			
			if(norms.g.enable){
				$('xl_gbutton').attr('disabled',false);
				if(norms.g.checked){
					$('xl_pbutton').html('流畅');
					$('xl_gbutton').html('• 高清');
					$('xl_cbutton').html('超清');
				}
			}
			else{
				$('xl_gbutton').attr('disabled',true);
			}
			
			if(norms.p.enable){
				$('xl_pbutton').attr('disabled',false);
				if(norms.p.checked){
					$('xl_pbutton').html('• 流畅');
					$('xl_gbutton').html('高清');
					$('xl_cbutton').html('超清');
				}
			}
			else{
				$('xl_pbutton').attr('disabled',true);
			}

			
		},
		setUrlTimer:null,
		setUrl:function(url,time){
			try{
				this.stop();
			}
			catch(e){}
			this.video.src = url;
			this.debug("播放地址："+url);
			this.fireEvent("seturl");
			try{
				clearInterval(this.setUrlTimer);
			}
			catch(e){}
			if(time){
				var that = this;
				that.setUrlTimer = setInterval(function(){
					if(!time){
						clearInterval(that.setUrlTimer);
						return;
					}
					try{
						that.video.currentTime = parseInt(time);
						time=0;
						that.play();
						clearInterval(that.setUrlTimer);
					}
					catch(e){}
				},50);
			}
			this.play();
			return this;
		},
		getUrl:function(){
			return this.video.src;
		},
		play:function(){
			if (this.video.ended) this.video.currentTime = 0;
			this.video.play();
			return this;
		},
		pause:function(){
			this.video.pause();
			return this;
		},
		stop:function(){
			try{
				this.video.currentTime = 0;
			}
			catch(e){}
			this.video.pause();
			return this;
		},
		close:function(){
			return this;
		},
		closeNetStream:function(){
			this.video.src='';
			return this;
		},
		seek:function(time){
			this.video.currentTime = time;
			return this;
		},
		getPlayPosition:function(){
			return this.currentTime;
		},
		getDownloadProgress:function(){
			
		},
		getDownloadSpeed:function(){
			return -1;
		},
		setFullScreen:function(status){
			var obj = this.video;
			if (obj.webkitSupportsFullscreen) {
				if(status){
					obj.webkitEnterFullScreen();
				}
				else{
					obj.webkitExitFullscreen();
				}
			}
		},/*
		setBarAvailable:function(flag){
			//console.log('是否禁止拖动:'+flag);
			this.video.controls=flag;
		},*/
		debug:function(msg){
			console.log(msg);
		},
		getPlayUrl:function(){
			return this.video.src;
		},
		setNoticeMsg:function(msg,time){
			var that = this;
			var msgTimer = null;
			if(msg!='')
				$('#trail_tips').html('').html(msg);
			$('#trail_tips_box').show();
			if(parseInt(time)<=0) time = 15;
			this.msgTimer=setTimeout(function(){
				$('#trail_tips_box').fadeOut();
			},time*1000);

		},
		getPlayStatus:function(){
			if(this.video.paused) return 'pause';
			else if(this.video.ended) return 'stop';
			else if(this.isplay) return 'playing';
			else return '';
		},
		setIsChangeQuality:function(){
			return this;
		},
		setCaptionList:function(list){
			console.log('setCaptionList');
			return this;//暂未支持，设置字幕列表
		},
		setToolBarEnable:function(){
			console.log('setToolBarEnable');
			return this;//暂未支持，设置面板是否可用
		},
		setFeeParam:function(){
			console.log('setFeeParam');
			return this;//暂未支持，设置扣费参数
		},
		setFileList:function(){
			console.log('setFileList');
			return this;//暂未支持，设置文件列表
		},
		playOtherFail:function(){
			console.log('playOtherFail');
			return this //暂未支持，设置切换列表文件播放提示
		},
		setShareParam:function(){
			console.log('setShareParam');
			return this; //暂未支持，设置分享参数
		}
	});
	return new Core();
})();
XL_CLOUD_FX_INSTANCE.init(G_PLAYER_INSTANCE);