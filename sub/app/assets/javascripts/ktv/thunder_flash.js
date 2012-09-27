var G_PLAYER_INSTANCE = null;
(function(){
	if(typeof deconcept=="undefined"){var deconcept=new Object();}
if(typeof deconcept.util=="undefined"){deconcept.util=new Object();}
if(typeof deconcept.SWFObjectUtil=="undefined"){deconcept.SWFObjectUtil=new Object();}
deconcept.SWFObject=function(_1,id,w,h,_5,c,_7,_8,_9,_a,_b){
if(!document.createElement||!document.getElementById){return;}
this.DETECT_KEY=_b?_b:"detectflash";
//this.skipDetect=deconcept.util.getRequestParameter(this.DETECT_KEY);
this.skipDetect=true;
this.params=new Object();
this.variables=new Object();
this.attributes=new Array();
if(_1){this.setAttribute("swf",_1);}
if(id){this.setAttribute("id",id);}
if(w){this.setAttribute("width",w);}
if(h){this.setAttribute("height",h);}
if(_5){this.setAttribute("version",new deconcept.PlayerVersion(_5.toString().split(".")));}
this.installedVer=deconcept.SWFObjectUtil.getPlayerVersion(this.getAttribute("version"),_7);
if(c){this.addParam("bgcolor",c);}else{this.addParam("wmode","transparent");}
var q=_8?_8:"high";
this.addParam("quality",q);
this.setAttribute("useExpressInstall",_7);
this.setAttribute("doExpressInstall",false);
var _d=(_9)?_9:window.location;
this.setAttribute("xiRedirectUrl",_d);
this.setAttribute("redirectUrl","");
if(_a){this.setAttribute("redirectUrl",_a);}};
deconcept.SWFObject.prototype={setAttribute:function(_e,_f){
this.attributes[_e]=_f;
},getAttribute:function(_10){
return this.attributes[_10];
},addParam:function(_11,_12){
this.params[_11]=_12;
},getParams:function(){
return this.params;
},addVariable:function(_13,_14){
this.variables[_13]=_14;
},getVariable:function(_15){
return this.variables[_15];
},getVariables:function(){
return this.variables;
},getVariablePairs:function(){
var _16=new Array();
var key;
var _18=this.getVariables();
for(key in _18){
_16.push(key+"="+_18[key]);}
return _16;
},getSWFHTML:function(){
var _19="";
if(navigator.plugins&&navigator.mimeTypes&&navigator.mimeTypes.length){
if(this.getAttribute("doExpressInstall")){this.addVariable("MMplayerType","PlugIn");}
_19="<embed type=\"application/x-shockwave-flash\" src=\""+this.getAttribute("swf")+"\" width=\""+this.getAttribute("width")+"\" height=\""+this.getAttribute("height")+"\"";
_19+=" id=\""+this.getAttribute("id")+"\" name=\""+this.getAttribute("id")+"\" ";
var _1a=this.getParams();
for(var key in _1a){_19+=[key]+"=\""+_1a[key]+"\" ";}
var _1c=this.getVariablePairs().join("&");
if(_1c.length>0){_19+="flashvars=\""+_1c+"\"";}
_19+=" pluginspage=\"http://www.macromedia.com/go/getflashplayer\"/>";
}else{
if(this.getAttribute("doExpressInstall")){this.addVariable("MMplayerType","ActiveX");}
_19="<object id=\""+this.getAttribute("id")+"\" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" width=\""+this.getAttribute("width")+"\" height=\""+this.getAttribute("height")+"\" codebase=\"http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0\">";
_19+="<param name=\"movie\" value=\""+this.getAttribute("swf")+"\" />";
var _1d=this.getParams();
for(var key in _1d){_19+="<param name=\""+key+"\" value=\""+_1d[key]+"\" />";}
var _1f=this.getVariablePairs().join("&");
if(_1f.length>0){_19+="<param name=\"flashvars\" value=\""+_1f+"\" />";}
_19+="</object>";}
return _19;
},write:function(_20){
if(this.getAttribute("useExpressInstall")){
var _21=new deconcept.PlayerVersion([6,0,65]);
if(this.installedVer.versionIsValid(_21)&&!this.installedVer.versionIsValid(this.getAttribute("version"))){
this.setAttribute("doExpressInstall",true);
this.addVariable("MMredirectURL",escape(this.getAttribute("xiRedirectUrl")));
document.title=document.title.slice(0,47)+" - Flash Player Installation";
this.addVariable("MMdoctitle",document.title);}}
if(this.skipDetect||this.getAttribute("doExpressInstall")||this.installedVer.versionIsValid(this.getAttribute("version"))){
var n=(typeof _20=="string")?document.getElementById(_20):_20;
n.innerHTML=this.getSWFHTML();
return true;
}else{
if(this.getAttribute("redirectUrl")!=""){document.location.replace(this.getAttribute("redirectUrl"));}}
return false;}};
deconcept.SWFObjectUtil.getPlayerVersion=function(_23,_24){
var _25=new deconcept.PlayerVersion([0,0,0]);
if(navigator.plugins&&navigator.mimeTypes.length){
var x=navigator.plugins["Shockwave Flash"];
if(x&&x.description){_25=new deconcept.PlayerVersion(x.description.replace(/([a-z]|[A-Z]|\s)+/,"").replace(/(\s+r|\s+b[0-9]+)/,".").split("."));}
}else{try{
var axo=new ActiveXObject("ShockwaveFlash.ShockwaveFlash");
for(var i=15;i>6;i--){
try{
axo=new ActiveXObject("ShockwaveFlash.ShockwaveFlash."+i);
_25=new deconcept.PlayerVersion([i,0,0]);
break;}
catch(e){}}}
catch(e){}
if(_23&&_25.major>_23.major){return _25;}
if(!_23||((_23.minor!=0||_23.rev!=0)&&_25.major==_23.major)||_25.major!=6||_24){
try{_25=new deconcept.PlayerVersion(axo.GetVariable("$version").split(" ")[1].split(","));}
catch(e){}}}
return _25;};
deconcept.PlayerVersion=function(_29){
this.major=parseInt(_29[0])!=null?parseInt(_29[0]):0;
this.minor=parseInt(_29[1])||0;
this.rev=parseInt(_29[2])||0;};
deconcept.PlayerVersion.prototype.versionIsValid=function(fv){
if(this.major<fv.major){return false;}
if(this.major>fv.major){return true;}
if(this.minor<fv.minor){return false;}
if(this.minor>fv.minor){return true;}
if(this.rev<fv.rev){return false;}return true;};
deconcept.util={getRequestParameter:function(_2b){
var q=document.location.search||document.location.hash;
if(q){
var _2d=q.indexOf(_2b+"=");
var _2e=(q.indexOf("&",_2d)>-1)?q.indexOf("&",_2d):q.length;
if(q.length>1&&_2d>-1){
return q.substring(q.indexOf("=",_2d)+1,_2e);
}}return "";}};
if(Array.prototype.push==null){
Array.prototype.push=function(_2f){
this[this.length]=_2f;
return this.length;};}
var getQueryParamValue=deconcept.util.getRequestParameter;
var FlashObject=deconcept.SWFObject; // for backwards compatibility
window.SWFObject=deconcept.SWFObject;
})();
var argumentsToArray = function(args){
	var result = [ ];
	for(var i=0; i<args.length; i++)
		result.push(args[i]);
	return result;
};
Function.prototype.delayApply = function(time, thisObj, argArray){
	var f = this;
	return setTimeout( function() {
		f.apply(thisObj, argArray);
	}, time);
};
Function.prototype.delayCall = function(time, thisObj){
	return this.delayApply(time, thisObj, argumentsToArray(arguments).slice(2))
};
var KankanObj = XL_CLOUD_FX_INSTANCE.Class.extend({
	init: function(){
	},
	mStatSend:function(url){
		var img = new Image(1,1);
		img.src = url;
	},
	trace:function(str,pos){
		if(pos=='onProgress'){
			return false;
		}
		var send_str='kankan=====DEBUG:'+str+','+pos;
		try{
			if(this.showDebugFlag && str.indexOf('downloadProgress.bufferEnd')==-1) console.log(send_str);
		}
		catch(e){}
	},
	getParameter:function(name){
		var pattern = new RegExp("[?&]"+name+"\=([^&#]+)", "g");
		try{
			var matcher = pattern.exec(this.getLoc());
		}catch(e){};
		if(null != matcher){
			return decodeURIComponent(matcher[1]);
		}else{
			return null;
		}
	},
	rand:function(Min,Max){
		var Range = Max - Min;
		var Rand = Math.random();
		return(Min + Math.round(Rand * Range));
	},
	getLoc:function(){
		try{return document.location.href;}catch(e){};
	},
	$:function(s){
		return document.getElementById(s);
	},
	getCookie:function(name){
		try{
			var str = (document.cookie.match(new RegExp("(^"+name+"| "+name+")=([^;]*)"))==null)?"":decodeURIComponent(RegExp.$2);
			if (str != '') {return str;}else {return "";}
		}catch(e){return "";}
	},
	time: function(){
		return new Date().getTime();
	},
	pageRefresh: function(){
		var url = window.location.href;
		var arr = url.split('#');
		if(window.location.href.indexOf("?")>0){
			window.location = arr[0] + '&rd=' +this.time();
		}else{
			window.location = arr[0] + '?rd=' +this.time();
		}
		return true;
	},
	$C:function(tagName){
		return document.createElement(tagName);
	},
	$P:function(child,parent){
		return parent?parent.appendChild(child):document.body.appendChild(child);
	}
});

var KankanEventObj = KankanObj.extend({
	init: function(){
		this._super();
		this.attachEvent = this.addEventListener;
		this.detachEvent = this.removeEventListener;
		this.fireEvent = this.dispatchEvent;
	},
	addEventListener:function(oListener, sEvent, fpNotify, tDelay){
		if(!this[sEvent])
			this[sEvent] = [ ];
		if(!(this[sEvent] instanceof Array))
			return false;
		for(var i=0; i<this[sEvent].length; i++)
			if(this[sEvent][i].o == oListener && this[sEvent][i].f == fpNotify)
				return true;
		this[sEvent].push( {o: oListener, f: fpNotify, t: tDelay} );
		return true;
	},
	removeEventListener:function(oListener, sEvent, fpNotify){
		if(!this[sEvent] || !(this[sEvent] instanceof Array))
			return false;
		for(var i=0; i<this[sEvent].length; i++)
			if(this[sEvent][i].o == oListener && (this[sEvent][i].f == fpNotify || !fpNotify)) {
				this[sEvent].splice(i, 1);
				if(0 == this[sEvent].length)
					delete this[sEvent];
				return true;
			}
		return false;
	},
	dispatchEvent:function(sEvent)
	{	
		if(!this[sEvent] || !(this[sEvent] instanceof Array))
			return false;
		var args = [this].concat( argumentsToArray(arguments) );
		var listener = this[sEvent].slice(0);
		for(var i=0; i<listener.length; i++)
			if(typeof(listener[i].t) == "number")
				listener[i].f.delayApply( listener[i].t, listener[i].o, args );
			else
				listener[i].f.apply( listener[i].o, args );
		//G_PLAYER_DEBUG.trace("Leave fireEvent " + sEvent?sEvent:"undefined");
		return true;
	}
});

var KKPlayerError= KankanEventObj.extend({
	init: function(){
		this._super();
		this.errorMap = {
		//'000':'Flash初始化代码异常|清除浏览器缓存,再刷新页面重试',
		//'001':'dapctrl初始化失败|清除浏览器缓存,再刷新页面重试',    not install tips
		//'002':'检测到高清播放组件版本太低，请更新迅雷看看高清播放组件最新版，<a target="_blank" href="'+this.packages.bigPackageUrl+'">点击升级安装</a>',
		'200':'该文件播放须用迅雷看看播放器，<a href="###" onclick="V.install();return false;">点击安装</a>，安装成功之后刷新此页面即可播放',
		'003':'Flash 初始化失败,清除浏览器缓存,再刷新页面重试',
		'004':'检测到Flash Player控件异常,请先安装最新版本Flash Player。<a href="http://get.adobe.com/cn/flashplayer/" target="_blank">立即下载安装Flash Player</a>',
		'005':'检测到迅雷看看高清播放组件退出，请<font color="#097BB3"><u><a href="javascript:G_PLAYER_INSTANCE.pageRefresh()" target="_self">刷新</a></u></font>页面重试|',
		'006':'抱歉，您当前使用的浏览器与迅雷看看不兼容，请使用IE浏览器',
		'009':'检测到Flash Player控件异常,请先安装最新版本Flash Player。<a href="http://get.adobe.com/cn/flashplayer/" target="_blank">立即下载安装Flash Player</a>',
		'100':'没找到播放地址,请选择播放其他节目|'
		//'014':'检测到高清播放组件版本太低，请更新迅雷看看高清播放组件最新版，<a target="_blank" href="'+this.packages.bigPackageUrl+'">点击升级安装</a>'
		};
		this.lastError = '';
		this.count = 0;
		this.eStatUrl = 'http://kkpgv.xunlei.com/?u=kankan_mp4_logic_error';
		this.dErrorMap = 
		{
			10002:	'临时文件打开失败，请刷新页面重试',
			10003:	'磁盘空间不足，请首先关闭迅雷或看看高清播放组件，再刷新页面重试',
			63533:	'播放地址错误，请刷新页面重试',
			30004:	'无法创建或写缓存，请关闭迅雷或看看高清播放组件，再重新刷新页面',
			30006:	'检测到您的磁盘剩余空间不足，无法保存在线点播所产生的临时文件，\n建议清理出剩余空间大于1G后再刷新页面重试观看。<font color="#FF6600">错误码：30006</font>\n或者升级至最新版本，不再出现 <font color="#097BB3"><u><a href="javascript:G_PLAYER_INSTANCE.windowOpen(\"http://xmp.down.sandai.net/kankan/KankanSetup.exe\")" target="_self">立即升级</a></u></font>',
			31124:	'检测到您的磁盘剩余空间不足，无法保存在线点播所产生的临时文件，\n建议清理出剩余空间大于1G后再刷新页面重试观看。<font color="#FF6600">错误码：31124</font>\n或者升级至最新版本，不再出现 <font color="#097BB3"><u><a href="javascript:G_PLAYER_INSTANCE.windowOpen(\"http://xmp.down.sandai.net/kankan/KankanSetup.exe\")" target="_self">立即升级</a></u></font>',
			1002:	'数据错误，请重试播放',
			1003:	'数据错误，请重试播放',
			1004:	'播放模式错误，请刷新页面重试',
			101:	'接收媒体数据失败，请确认网络连接正常，再重试播放',
			62535:	'接收媒体数据超时，请确认网络连接正常，再刷新页面重试',
			62533:	'系统调用错误，请刷新页面重试',
			65518:	'启动迅雷流媒体服务失败，请确认迅雷或看看高清播放组件是否正常安装。或者尝试重启计算机。',
			65517:	'连接迅雷流媒体服务失败，版本可能过低，请安装最新版本的迅雷看看高清播放组件', 
			65516:	'与协议版本不符合，请关闭迅雷或看看高清播放组件后，刷新页面重试',
			65515:	'<font size="14">启用高清播放组件失败，建议您升级更新高清播放组件或刷新页面重试。<font color="#FF6600">错误码：65515</font>\n<u><a href="javascript:G_PLAYER_ERROR.changeInstallPlay()" target="_self">点击更新高清播放组件</a></u>&nbsp;&nbsp;<u><a href="javascript:G_PLAYER_INSTANCE.pageRefresh()" target="_self">刷新页面重试</a></u></font></font>',
			65514:	'未安装迅雷流媒体服务，请安装迅雷看看高清播放组件', 
			65513:	'迅雷流媒体服务已经退出，请重启迅雷或看看高清播放组件后，再刷新页面重试。或者尝试重启计算机',
			65512:	'你安装的迅雷版本过低，不支持此服务，请安装最新版本的迅雷看看高清播放组件', 
			65511:	'你安装的迅雷非官方版本，不支持此服务，请安装最新版本的迅雷看看高清播放组件', 
			65510:	'获取服务端口失败，请刷新页面重试',
			65509:	'<font size="14">启用高清播放组件失败，建议您升级更新高清播放组件或刷新页面重试。<font color="#FF6600">错误码：65509</font>\n<font color="#097BB3"><u><a href="javascript:G_PLAYER_ERROR.changeInstallPlay()" target="_self">点击更新高清播放组件</a></u>&nbsp;&nbsp;<u><a href="javascript:G_PLAYER_INSTANCE.pageRefresh()" target="_self">刷新页面重试</a></u></font></font>',
			65519:	'获取服务端口失败，请刷新页面重试',
			0x1057:	'高清播放组件读取数据失败，请刷新页面重试或更换其他影片观看',
			0x1197:	'高清播放组件读取数据失败，请刷新页面重试或更换其他影片观看',
			0x1198:	'高清播放组件读取数据失败，请刷新页面重试或更换其他影片观看',
			0x11B3:	'网络题，请检查网络是否连接正常，或刷新页面重试',
			0x11C0:	'无法播放此影片，请刷新页面重试或更换其他影片观看',
			0x11CD:	'高清播放组件异常，请刷新页面重试或更换其他影片观看'
			
		};
		this.debugBuffer = [];
		this.debugShowed = false;
		this.feedbackParam = '';
	},
	reInit:function(){
		this.dapctrlError = false;
		this.bufferError = false;
	},
	dump: function(code,isHide,envDetail){
		this.count++;
		this.trace('------ERROR-CODE:'+code);
		if(code=='000'||code=='001'||code=='002'||code=='003'||code=='004'||code=='006'||code=='007'||code=='009'){
			this.stat.delayCall(0,this,code,false);
		}else{
			this.stat.delayCall(0,this,code,true,envDetail);
		}
		if(isHide){
			return false;
		}
		if(typeof this.errorMap[code] != 'undefined'){
			//this.showError(code,this.errorMap[code]);
			return true;
		}
		return false;
	},
	showError:function(code,str){
		var instance = G_PLAYER_INSTANCE;
		var errArr = str.split('|');
		if(code!=200 && typeof instance != 'undefined'&&instance&&typeof instance.showError != 'undefined'){
			instance.showError(escape(errArr[0]),escape(errArr[1]));
		}else{
			this.showOnPage(errArr[0],code);
		}
	},
	stat:function(code,detail,envDetail){
		var lastError = this.lastError;
		this.lastError = code;
		var instance = G_PLAYER_INSTANCE;
		if(detail){
			if(!envDetail){
				envDetail='';
			}
			var errorInfo = {sid:0,ctype:0,ver:0,lastError:lastError,lastEvent:'',uid:0};
			var clientObj = this.getClientType;
			errorInfo.ctype = clientObj.ctype;
			errorInfo.ver = clientObj.ver;
			if(instance){
				errorInfo.sid = instance.sid;
				errorInfo.lastEvent = instance.lastEvent;
			}
			errorInfo.uid=this.getCookie('KANKANWEBUID');
			var url = this.eStatUrl+'&u1='+code+'&u2='+encodeURIComponent(this.getLoc())+'&u3='+errorInfo.sid+'&u4='+errorInfo.lastEvent+'&u5='+errorInfo.ctype+'_'+errorInfo.ver+'&u6='+errorInfo.uid+'&u7='+errorInfo.lastError+'&u8='+this.count+'&u9='+envDetail+'&rd='+this.time();
		}else{
			var url = this.eStatUrl+'&u1='+code+'&rd='+this.time();
		}
		this.mStatSend(url);
	},
	playCheck:function(code){
		if(!this.errorDetectDelay){
			this.errorHasPlay = false;
			this.errorDetectDelay= true;
			this.playCheckDelay.delayCall(60000,G_PLAYER_ERROR,code);
		}
	},
	playCheckDelay:function(code){
		var instance = G_PLAYER_INSTANCE;
		if(!this.errorHasPlay){
			this.dump('T'+code,true,instance.getEventQueue()+'_'+instance.getBufferBugInfo()+'_'+instance.getPlayPosition());
		}
		this.errorHasPlay = false;
		this.errorDetectDelay= false;
	}
});
var KKPlayerInit= KankanEventObj.extend({
	init: function(){
		this._super();
		this.playerLoaded = false;
		this.flashAvailable = false;
		this.playerPath = 'http://vod.lixian.xunlei.com/flash/PlayerCtrlFlv_2.721.pan.swf';
		this.dapctrl = null;
		this.dapctrlBackup = false;
		this.checkPlayerTime = 0;
		this.bufferStartTime = 0;
		this.bufferEndTimes = 0;
		XL_CLOUD_FX_INSTANCE.init(this);
	},
	printObject:function(container,random,width,height,movieType,flashVars){
		//alert('-----------printObject----js----------');
		var mode = this.getCookie('player_mode');
		this.trace('printObject start');
		this.playerPath += '?v=2.0';
		if(typeof SWFObject=='undefined'){
			G_PLAYER_ERROR.dump('000');
			this.printObjectManually(container,random,width,height);
		}else{
			var so = new SWFObject(this.playerPath, "PlayerCtrl", width, height, "9", "#000000",'js/expressInstall.swf');
			so.addParam("allowScriptAccess", "always");
			so.addParam("allowFullScreen", "true");
			if(this.verFlashplayer&&this.verFlashplayer[0]>=10&&this.verFlashplayer[1]>=2&&mode==5){
			}else{
			}
			so.addParam("wmode", "transparent");
			so.addParam("quality", "high");
			if(flashVars){
				so.addParam("flashVars",flashVars);
			}
			so.skipDetect = false;
			if(!so.write(container)){
				this.fireEvent('onFlashError');
				return false;
			}
		}	
		this.checkPlayer.delayCall(0,this);
	},
	printObjectManually:function(container,random,width,height){
	//alert('-----------printObject----ie----------');
		if(this.isIE){
			var str = '';
			str += '<object width="'+width+'" height="'+height+'" id="PlayerCtrl" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codeBase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=10,0,0,0" >';
			str += '<PARAM NAME="_cx" VALUE="25664"><PARAM NAME="_cy" VALUE="13917"><PARAM NAME="FlashVars" VALUE="">';
			str += '<PARAM NAME="Movie" VALUE="'+this.playerPath+'"><PARAM NAME="Src" VALUE="'+this.playerPath+'"><PARAM NAME="WMode" VALUE="Window">';
			str += '<PARAM NAME="Play" VALUE="0"><PARAM NAME="Loop" VALUE="-1"><PARAM NAME="Quality" VALUE="High"><PARAM NAME="SAlign" VALUE="LT">';
			str += '<PARAM NAME="Menu" VALUE="0"><PARAM NAME="Base" VALUE=""><PARAM NAME="AllowScriptAccess" VALUE="always"><PARAM NAME="Scale" VALUE="NoScale">';
			str += '<PARAM NAME="DeviceFont" VALUE="0"><PARAM NAME="EmbedMovie" VALUE="0"><PARAM NAME="BGColor" VALUE="000000"><PARAM NAME="SWRemote" VALUE="">';
			str += '<PARAM NAME="MovieData" VALUE=""><PARAM NAME="SeamlessTabbing" VALUE="1"><PARAM NAME="Profile" VALUE="-1"><PARAM NAME="ProfileAddress" VALUE="">';
			str += '<PARAM NAME="ProfilePort" VALUE="830362444"><PARAM NAME="AllowNetworking" VALUE="all"><PARAM NAME="AllowFullScreen" VALUE="true">';
			str += '</object>';
			this.$(container).innerHTML = str;
		}else{
			//改FF
			var str = '';
			str += '<object width="'+width+'" height="'+height+'" id="PlayerCtrl" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codeBase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=10,0,0,0" >';
			str += '<embed src="'+this.playerPath+'" quality="high" pluginspage="http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash" type="application/x-shockwave-flash" width="'+width+'" height="'+height+'"></embed>';
			str += '</object>';
			this.$(container).innerHTML = str;
		}
	},	
	checkPlayer:function(){
		if(this.checkPlayerTime>=800){
			this.fireEvent('onLoadFlashError');
			return;
		}
		this.checkPlayerTime++;
		var player = this.$('PlayerCtrl');
		if(typeof player.flv_setPlayeUrl == 'undefined'){
			this.checkPlayer.delayCall(50,this);
		}else{
			G_PLAYER_INSTANCE = new KKPlayerInstance();
			if(!G_PLAYER_INSTANCE){
				this.checkPlayer.delayCall(50,this);
				return false;
			}
			this.fireEvent('onload');
			this.playerLoaded = true;
			this.trace('init success');
			try{
				if(!G_PLAYER_INIT.dapctrlBackup){
					G_PLAYER_INSTANCE.dapctrl.attachEvent("State", G_PLAYER_INSTANCE.dapCtrlHandler);
				}else{
					G_PLAYER_INSTANCE.dapctrl.onState = G_PLAYER_INSTANCE.dapCtrlHandler;
				}
			}catch(e){
			}
		}
		
	}

})
var KKPlayerInstance= KankanEventObj.extend({
	init: function(){
		this._super();
		this.dapctrl = G_PLAYER_INIT.dapctrl;
		this.pobject = this.$('PlayerCtrl');
		this.paramobj = [];
		this.qualitystr = '000';
		this.playMode = null;
		this.setURLTime = 0;
		this.bufferStart = 10;
		this.title = '';
		this.pauseObj = null;
		this.isBuffering = false;
		this.isFixFirstBuf = false;
		this.bufferStartPos = 0;
		this.vlength = 0;
		this.qualitytype = 0;
		this.submovieid = 0;
		this.lastEvent = 'init';
		this.qualitySwitch = false;
		this.qualitySwitchStart = 0;
		this.timeStampObj = {open:0,fopen:0,play:0};
		this.sid = 0;
		this.eventQueue = [0,0,0,0,0,0,0,0,0,0];
		this.preDownloadUrl = {sUrl:'',rUrl:''};
		this.isServer = false;
		this.skipStart = 0;
		this.skipEnd = 0;
		this.bufferTimes = 0;
		this.totleByte = 0;
		this.totleTime = 0;
		this.start = 0;
		this.flashOpenParam ={};
		this.playTimes={};
	},
	close:function(){
		this.playMode ='';
		try{
			this.pobject.flv_close();
		}catch(e){};
		this.setLastEvent('init',0);
		this.preDownloadUrl = {sUrl:'',rUrl:''};
	},
	pause:function(){
		this.pobject.flv_pause();
	},
	play:function(){
		this.pobject.flv_play();
	},
	stop:function(){
		this.pobject.flv_stop();
		this.preDownloadUrl = {sUrl:'',rUrl:''};
	},
	fpstop:function(){
		this.pobject.flv_stop();
	},
	getPlayPosition:function(){
		return this.pobject.getPlayProgress(true);
	},
	getBufferProgress:function(){
		return this.pobject.getBufferProgress()
	},
	setNoticeMsg:function(msg,time,callback,start,length){
		if(parseInt(time)<=0) time = 15;
		if(!callback){
			this.pobject.flv_setNoticeMsg(msg,false,parseInt(time),1);
			callback=null;
		}
		this.pobject.flv_setNoticeMsg(msg,false,parseInt(time),1,callback,start,length);
	},
	getBufferedPos:function(){
		return this.pobject.getBufferEnd();
	},
	flashopen:function(url,isServer,urlObj,autoplay,param,ischange){
		if(this.qualitySwitch){
			this.qualityFlashopen(url);
			return false;
		}
		if(typeof this.playTimes[url]=='undefined')
			this.playTimes[url] = 1;
		else 
			this.playTimes[url]++;
		this.flashOpenParam  = arguments;
		this.bufferTimes = 0;
		var paramobj = eval('[{url:"",start:0,autoplay:1,quality:0,qualitystr:"000",qualitytype:0,subStart:0,subEnd:0,title:"",vcut:0,submovieid:0,skipMovieHeadTime:0,skipMovieEndTime:0,streamtype:0,posterUrl:"",totleByte:0,totleTime:0,sliceTime:0}]');
		paramobj[0].url = url;
		paramobj[0].start = parseInt(this.start);
		paramobj[0].autoplay = autoplay;
		paramobj[0].quality = parseInt(this.quality);
		paramobj[0].qualitystr = this.qualitystr;
		paramobj[0].title = this.title;
		paramobj[0].vcut = this.vcut;
		paramobj[0].qualitytype = this.qualitytype;
		paramobj[0].submovieid = this.submovieid;
		paramobj[0].posterUrl = this.poster;
		if(isServer){
			paramobj[0].totalByte = param.totalByte;//150523213;//this.totalByte;
			paramobj[0].totalTime = param.totalTime;//5530;//1646;//this.totalTime;
			paramobj[0].totleTime = param.totalTime;//5530;//1646;//this.totalTime;
			paramobj[0].sliceTime = 12000;
			paramobj[0].sliceType = param.sliceType;//0;//0字节拼接 转码完成  1时间拼接 转码中
			paramobj[0].start=0;
			if(typeof param.start!='undefined'){
				paramobj[0].start = parseInt(param.start);
				if(isNaN(paramobj[0].start)) paramobj[0].start=0;
				if(paramobj[0].start<0) paramobj[0].start=0;

			}
			paramobj[0].format = param.format;//g 高清 p普请
		}
		if(urlObj){
			paramobj[0].jsonObj = urlObj;
			if(autoplay){
				paramobj[0].autoplay = autoplay;
			}else{
				paramobj[0].autoplay = 2;
			}
		}
		if(isServer){
			this.isServer = true;
			paramobj[0].streamtype = 1;
			paramobj[0].packageUrl = this.packageUrl;
		}else{
			this.isServer = false;
			paramobj[0].streamtype = 0;
		}
		if(this.subEnd>this.subStart){
			paramobj[0].subStart = this.subStart;
			paramobj[0].subEnd = this.subEnd;
		}
		paramobj[0].skipMovieHeadTime = this.skipStart;
		paramobj[0].skipMovieEndTime = this.skipEnd;
		this.paramobj = paramobj;
		this.pobject.setBufferTime(this.bufferStart);

		if(ischange==1){
			this.pobject.flv_setChangeUrl(paramobj);
		}
		else{
			this.pobject.flv_setPlayeUrl(paramobj);
		}
		G_PLAYER_INSTANCE.setURLTime=parseInt(new Date().valueOf());
		this.timeStampObj.fopen=parseInt(new Date().valueOf());
	},
	showError:function(error,suggest){
		try{
			this.pobject.flv_stop();
		}catch(e){};
		if(suggest=='')
		var suggest = "如果还无法观看，请查看<font color='#097BB3'><u><a href='javascript:G_PLAYER_INSTANCE.windowOpen(\"http://www.xunlei.com/help/\")' target='_self'>常见题</a></u></font> 或 <font color='#097BB3'><u><a href='javascript:G_PLAYER_INSTANCE.windowOpen(\"http://www.xunlei.com/help/feedback.html"+G_PLAYER_ERROR.feedbackParam+"\")' target='_self'>反馈给我们</a></u></font>！";
		this.pobject.flv_handleError(error,suggest);
	},
	getPlayStatus:function(){
		var status = this.pobject.getPlayStatus();
		if(status==-1){
			return 'init';
		}else if(status==0){
			return 'playing';
		}else if(status==1){
			return 'pause';
		}else if(status==2){
			return 'stop';
		}else if(status==3){
			return 'replay';
		}else{
			return 'undefined';
		}
	},
	getDownloadSpeed:function(){
		return this.pobject.getDownloadSpeed();
	},
	getDownloadProgress:function(){
		var dapctrl = this.dapctrl;
		var playDuration = dapctrl.Get("DPLAYDURATION");
		var ratio = dapctrl.Get("iDownRatio");
		if(playDuration>0){
			var rpos = ((playDuration-this.subStart)/this.getDuration())*10000;
			if(rpos>=10000||ratio>=10000){
				return 10000;
			}else if(rpos<0){
				return 0;
			}else{
				return parseInt(rpos);
			}
		}else{
			if(this.vcut==1&&this.subEnd>0&&this.vlength>0){
				var pos = dapctrl.Get("iDownRatio");
				var rpos = ((((pos*this.vlength)/10000) - this.subStart)/(this.subEnd-this.subStart))*10000;
				if(rpos>10000){
					return 10000;
				}else if(rpos<0){
					return 0;
				}else{
					return parseInt(rpos);
				}
			}else{
				return dapctrl.Get("iDownRatio");
			}
		}
	},
	updatePlayPos:function(){
		var pos = this.subStart + this.getPlayPosition();
		return pos;
	},
	destory:function(){
		try{
			this.pobject = null;
		}catch(e){};
	},
	setSpolierXml:function(xml){
		this.pobject.flv_setSpolierXml(xml);
	},
	setADParams:function(obj){
		this.pobject.flv_setADParams(obj);
	},
	setPlayPosition:function(time){
		this.pobject.flv_setSeekPos(time);
	},
	cutStreamLink:function(){
		this.pobject.cutStreamLink();
	},
	closeAdPlaying:function(){
		this.pobject.flv_closeAdPlaying();
	},
	getDuration:function(){
		return this.pobject.getDuration();
	},
	getDownloadPos:function(){
		if(this.pobject.getDuration()>0&&this.getDownloadProgressAll()>0){
			return this.pobject.getDuration()*this.getDownloadProgressAll()/10000;
		}else{
			return 0;
		}
	},
	
	closeNotice:function(){
		return this.pobject.flv_closeNotice();
	},
	closeNoticeCallback:function(){
		this.fireEvent('onCloseNotice');
	},
	getErrorInfo:function(){
		return this.pobject.getErrorInfo();
	},
	changeBufferTime:function(time){
		if(time>0){
			this.trace("player changeBufferTime ="+time);
			return this.pobject.flv_changeBufferTime(time);
		}
	},
	setIsSkipMovieHead:function(isSkip){
		return this.pobject.flv_setIsSkipMovieHead(isSkip);
	},
	setIsAutoChangeQuality:function(isAuto){
		return this.pobject.flv_setIsAutoChangeQuality(isAuto);
	},
	getPlayerConfig:function(){
		return this.pobject.flv_getSetStatusInfo();
	},
	getBufferLength:function(){
		return this.pobject.flv_getBufferLength();
	},
	setLastEvent:function(event,num){
		this.lastEvent = event;
		if(num>0){
			this.eventQueue.unshift(num);
			this.eventQueue = this.eventQueue.slice(0,10);
		}
	},
	getEventQueue:function(){
		return this.eventQueue.join('-');
	},
	getBufferBugInfo:function(){
		return this.pobject.flv_getBufferBugInfo();
	},
	getFlashVer:function(){
		//return this.pobject.getVariable('$version').split(" ")[1].split(",");
		return this.pobject.flv_getFlashVersion();
	},
	getStageVideoInfo:function(){
		return this.pobject.flv_stageVideoInfo();
	},
	setFullScreen:function(status){
		return this.pobject.flv_setFullScreen(status);
	},
	setFullScreenBanner:function(url,peerid){
		var bannerObj = {url:url,peerid:peerid};
		bannerObj.url = url;
		bannerObj.peerid = peerid;
		this.pobject.flv_setFullscreenBanner(bannerObj);
		this.trace("player set bannerAD url="+bannerObj.url+", peerid="+bannerObj.peerid);
	},
	setCornerAD:function(value){
		this.pobject.flv_setCornerObject(value);
	},
	closeCorner:function(){
		this.pobject.flv_closeCorner();
	},
	getStickPlayMessage:function(){
		return this.pobject.flv_getStickPlayMessage();
	},
	getCurrentFps:function(){
		return this.pobject.flv_getNsCurrentFps();
	},
	setIsChangeQuality:function(flag){
		return this.pobject.flv_setIsChangeQuality(flag);
	},
	playWithInstall:function(){
		return this.pobject.flv_playWithInstall();
	},
	flvExternalCommand:function(key,value){
		return this.pobject.flv_externalCommand(key,value);
	},
	closeNetStream:function(){
		return this.pobject.flv_closeNetConnection();
	},
	getFormats:function(){
		this.fireEvent('onGetFormats',this,'flash');
	},
	setFormats:function(m){
		return this.pobject.flv_showFormats(m);
	},
	setFormatsCallback:function(format,isdefault){
		this.fireEvent('onSetFormats',this,'flash',format,isdefault);
	},
	setFormatCallback:function(format,isdefault){
		this.fireEvent('onSetFormats',this,'flash',format,isdefault);
	},
	showBufferTip:function(flag){
		return this.pobject.flv_showBufferTip(flag);
	},
	seek:function(start){
		return this.pobject.flv_seek(start);
	},
	getBytes:function(){
		return this.pobject.flv_getStreamBytesLoaded();
	},
	openPlayList:function(){
		this.fireEvent('openPlayListEvent',this);
	},
	showDebug:function(){
		this.showDebugFlag=true;
	},
	setCaptionList:function(list){
		this.pobject.flv_setCaptionList(list);
	},
	setCaptionParam:function(param){
		this.pobject.flv_setCaptionParam(param);
	},
	setToolBarEnable:function(param){
		this.pobject.flv_setToolBarEnable(param);
	},
	windowOpen:function(url){
		try{
			this.dapctrl.Put("iADShowMode",1);
			this.dapctrl.Put("sOpenAdURL", url);
		}catch(e){
			window.open(url);
		};
	},
	setFileList:function(param,type,gcid){//ipad
		this.pobject.flv_setBTFileList(param,type,gcid);
	},
	playOtherFail:function(flag){//ipad
		this.pobject.flv_playOtherFail(flag);
	},
	setFeeParam:function(param){//ipad
		this.pobject.flv_setFeeParam(param);
	},
	setShareParam:function(title,url){//ipad
		this.pobject.flv_setShareLink(title,url);
	},
	/* 获取播放时长 */
	getTimePlayed:function(){	
		return this.pobject.flv_getTimePlayed();
	}

});

function flv_playerEvent(event,value){
	var instance = G_PLAYER_INSTANCE;
	var dapctrl = instance.dapctrl;
	var error = G_PLAYER_ERROR;
	if(event=='onbuffering'){
		if(instance.lastEvent!='onSeek'&&instance.lastEvent!='onopen'){
			instance.bufferTimes++;
			instance.bufferBeginTime = parseInt(new Date().valueOf());
			instance.isBufferCalc = true;
		}
		var lastEvent = instance.lastEvent;
		instance.setLastEvent('onbuffering',2);
		instance.isBuffering = true;
		instance.bufferStartTimes++;
		instance.bufferStartTime=parseInt(new Date().valueOf());
		instance.bufferStartPos = instance.updatePlayPos();
		
		var pos = instance.subStart + instance.getPlayPosition();
		try{
			dapctrl.Put('dPlayPos',pos);
			dapctrl.Put("sPlayerOp", "bufstart");
		}catch(e){};
		//errorc
		if(lastEvent=='onplaying'){
			if(instance.playMode!='DC'&&instance.getBufferLength()>30){
				if(!error.bufferError){
					//G_PLAYER_ERROR.dump('012',true);
					error.bufferError = true;
					error.playCheck('012');
				}
			}else if(instance.playMode!='DC'&&instance.getAvailablePlayTime()>90){
				if(!error.bufferError){
					//G_PLAYER_ERROR.dump('013',true);
					error.bufferError = true;
					error.playCheck('013');
				}
			}
		}
		if(lastEvent=='onBuffering'){
			error.dump('014',true);
		}
	}else if(event=='onplaying'){
		error.bufferError = false;
		if(instance.playMode!='DC'){
			instance.bufferEndTime=parseInt(new Date().valueOf());
			instance.trace("bufend__ ...urlToPlayTime="+(instance.bufferEndTime - instance.setURLTime)/1000 +", bufferTime="+(instance.bufferEndTime - instance.bufferStartTime)/1000);
			if(instance.isBuffering&&instance.bufferStartPos>0){
				dapctrl.Put('dPlayPos',instance.bufferStartPos);
				dapctrl.Put("sPlayerOp", "bufend");
			}
			if(!instance.isFixFirstBuf){
				//dapctrl.PlayerEvent("FixFirstBuf", 0);
				instance.isFixFirstBuf = true;
			}
			//dapctrl.Put("sPlayerOp", "resume");

		}
		instance.isBuffering = false;
		instance.setLastEvent('onplaying',3);
		instance.timeStampObj.play = parseInt(new Date().valueOf());
		error.errorHasPlay = true;
		
	}else if(event=='onPause'){
		try{
			instance.updatePlayPos();
			dapctrl.Put("sPlayerOp", "pause");
		}catch(e){};
		instance.setLastEvent('onPause',6);
	}else if (event=='onSeek'){
		instance.setLastEvent('onSeek',4);
		try{
			var pos = instance.subStart + value;
			dapctrl.Put('dPlayPos',pos);
			dapctrl.Put("sPlayerOp", "seek");
		}catch(e){};
	}else if (event=='onopen'){
		instance.setLastEvent('onopen',1);
		//G_PLAYER_INSTANCE.lastEvent = 'onopen';
	}else if (event=='onStop'){
		V.stopPos = G_PLAYER_INSTANCE.getPlayPosition();
		//G_PLAYER_INSTANCE.lastEvent = 'onStop';
		var a='a';
	}else if (event=='onEnd'){
		instance.setLastEvent('onEnd',7);
		G_PLAYER_INSTANCE.close();
		G_PLAYER_INSTANCE.closeNetStream();

	}else if (event=='autoChangeQulity'){
		instance.setLastEvent('autoChangeQulity',8);
		instance.setNoticeMsg('智能切换清晰度已完成');
	}
	else if(event=='onErrorInfo'){//flv_playerEvent('onErrorInfo')
		var start = G_PLAYER_INSTANCE.getPlayPosition();
		var n = new Date();
		var _key = n.getHours() +':' +n.getMinutes();
		if(typeof(G_PLAYER_INSTANCE.playTimes[_key])=='undefined'){
			G_PLAYER_INSTANCE.playTimes[_key] = 1;
		}
		
		var url = G_PLAYER_INSTANCE.flashOpenParam[0];
		instance.fireEvent('onErrorStat',typeof(value)=='undefined'?'1':value);
		if(G_PLAYER_INSTANCE.playTimes[_key]>3){
			G_PLAYER_INSTANCE.close();
			G_PLAYER_INSTANCE.closeNetStream();
			G_PLAYER_INSTANCE.flv_showErrorInfo();
			setTimeout(function(){
				if(typeof(value)=='undefined'){
					var msg = '播放异常，请检查网络连接或重试！';
					var code='';
				}
				else{
					var msg = '播放异常，请检查网络连接或重试！';
					var code = value;
				}
				instance.fireEvent('onErrorExit',code,msg);
			},50);
		}
		else{
			var param = G_PLAYER_INSTANCE.flashOpenParam;
			if(param[4].sliceType==0){
				param[4].start = start;
				//param[5] = 1;
			}
			else{
				param[4].start = start;
			}
			param[3] = 1;
			param[5] = 0;
			setTimeout(function(){
				//G_PLAYER_INSTANCE.closeNetStream();
				if(value==204){
					G_PLAYER_INSTANCE.seek(start);
				}
				else{
					G_PLAYER_INSTANCE.close();
					G_PLAYER_INSTANCE.closeNetStream();
					G_PLAYER_INSTANCE.flashopen.apply(G_PLAYER_INSTANCE,param);
				}
				G_PLAYER_INSTANCE.playTimes[_key]++;
			},50);
		}
	}
	else if(event=='onRePlay'){
		G_PLAYER_INSTANCE.close();
		G_PLAYER_INSTANCE.closeNetStream();
		var param = G_PLAYER_INSTANCE.flashOpenParam;
		param[4].start = 0;
		param[5] = 0;
		param[3] = 1;
		G_PLAYER_INSTANCE.flashopen.apply(G_PLAYER_INSTANCE,param);
	}
	else if(event == 'onShowBufferTip'){//出现缓冲提示
	}
	instance.fireEvent(event);
	instance.trace('flv_playerEvent',event);
}
var G_PLAYER_ERROR =new KKPlayerError();
var G_PLAYER_INIT = new KKPlayerInit();
