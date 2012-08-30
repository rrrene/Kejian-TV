// Like Rails DataHelper
var DateHelper = {
    timeAgoInWords: function(from) {
        return this.distanceOfTimeInWords(new Date().getTime(), from);
    },

    distanceOfTimeInWords: function(to, from) {
        seconds_ago = ((to  - from) / 1000);
        minutes_ago = Math.floor(seconds_ago / 60)

    if(minutes_ago == 0) { return "不到一分钟";}
    if(minutes_ago == 1) { return "一分钟";}
    if(minutes_ago < 45) { return minutes_ago + "分钟";}
    if(minutes_ago < 90) { return "大约一小时";}
        hours_ago  = Math.round(minutes_ago / 60);
    if(minutes_ago < 1440) { return hours_ago + "小时";}
    if(minutes_ago < 2880) { return "一天";}
        days_ago  = Math.round(minutes_ago / 1440);
    if(minutes_ago < 43200) { return days_ago + "天";}
    if(minutes_ago < 86400) { return "大约一月";}
        months_ago  = Math.round(minutes_ago / 43200);
    if(minutes_ago < 525960) { return months_ago + "月";}
    if(minutes_ago < 1051920) { return "大约一年";}
        years_ago  = Math.round(minutes_ago / 525960);
        return "超过" + years_ago + "年"
    }
}

var App = {
  
    // 显示进度条
    loading : function(show){
        var loadingPanel = jQuery("#loading");
        if(show == false){
            loadingPanel.hide();
        }
        else{      
            loadingPanel.show();
        }
    },

    alert : function(msg){
        html = '<div class="alert_message">';
        html += msg;
        html += '</div>';
        jQuery(".notice_message").remove();
        jQuery(".alert_message").remove();
        jQuery("#main .left_wrapper").prepend(html);
        return true;
    },

    notice : function(msg){
        html = '<div class="notice_message">';
        html += msg;
        html += '</div>';
        jQuery(".notice_message").remove();
        jQuery(".alert_message").remove();
        jQuery("#main .left_wrapper").prepend(html);
        return true;
    },

    /*
     * 检查 Ajax 返回结果的登陆状态，如果是未登陆，就转向登陆页面
     * 此处要配合 ApplicationController 里面的 require_user 使用
     */
    requireUser : function(result, type){
        type = type.toLowerCase();
        if(type == "json"){
            if(result.success == false){
                location.href = "/login_to_zhaopin?redirect_path=" + encodeURIComponent(window.location.pathname);
                return false;
            }
        }
        else{
            if(result == "_nologin_"){
                location.href = "/login_to_zhaopin?redirect_path=" + encodeURIComponent(window.location.pathname);
                return false;
            }
        }
        return true;
    },

    shortStr : function(str, len){
        var newStr="";
        var lst = /[\u0000-\u00ff]/;
        // 判断截取长度，遇到非汉字和全角符号计算两个字符
        for (var i=0, k=0; i<str.length; i++){
            newStr += str.charAt(i);
            if (lst.test(str.charAt(i))){k++;}
            else {k+=2;}
            if (k>=len){break;}
        }
        return newStr;
    },

    inPlaceEdit : function(el, editor_options, n){   //modify 2012-1-11 by lesanc n: number of words 
        var link = jQuery(el);
        var linkId = link.attr("id");
        var textId = link.attr("data-text-id");
        var remote_url = link.attr("data-url");
        var editType = link.attr("data-type");
        var editRich = link.attr("data-rich");
        var editWidth = link.attr("data-width");
        var editHeight = link.attr("data-height");
        var editPanel = null;

        textPanel = jQuery("#"+textId);
        link.parent().hide();

        sizeStyle = ""
        if(editWidth != undefined){
            sizeStyle += "width:"+editWidth+"px;"
        }
        if(editHeight != undefined){
            sizeStyle += "height:"+editHeight+"px;"
        }

        editHtml = '<input type="text" class="main_edit fc999" name="value" style="'+sizeStyle+'" />'; //added by pan
        if (linkId.indexOf('user__tagline') > -1){  //add 2011-9-30 by lesanc.li
            editHtml = '<input type="text" onchange="checklen(this,40)" maxlength="40" class="main_edit" id="user_tagline" name="value" style="margin-left:0px;'+sizeStyle+'" /><span id="user_tagline_tno" style="display:none;"></span>';
        }
        if(editType == "textarea"){
            editHtml = '<textarea name="value" style="'+sizeStyle+'"></textarea><div class="clearfix height0"></div>';
            if (linkId.indexOf('topic__summary') > -1){  //add 2011-9-30 by lesanc.li
                n = 2000;
            } else if (linkId.indexOf('ask__title') > -1){  //add 2012-2-24 by lesanc.li
                n = 50;
            } else if (linkId.indexOf('ask__body') > -1){  //add 2012-2-24 by lesanc.li
                n = 3000;
            } else if (linkId.indexOf('answer__body') > -1){  //add 2012-1-11 by lesanc.li
                n = 5000;
            }
        }
    
        var csrf_token = jQuery('meta[name=csrf-token]').attr('content'),
        csrf_param = jQuery('meta[name=csrf-param]').attr('content');

        editPanel = jQuery('<form action="'+remote_url+'" method="post" id="ipe_'+linkId+'" \
        data-text-id="'+textId+'" data-id="'+linkId+'" class="in_place_editing">\
                  <input type="hidden" name="id" value="'+linkId+'" /> \
                  <input type="hidden" name="'+csrf_param+'" value="'+csrf_token+'" /> \
                  '+ editHtml +' \
                  <div class="btnNormalSilver submit"> \
                  <span>保 存</span> \
                  </div> \
                  '+ "&nbsp;" +'<a href="#" class="cancel">取消</a>\
                </form>');
        link.parent().after(editPanel);

        if(editType == "textarea"){
            var _html = textPanel.html();
            if (editor_options["is_mobile_device"]) {
                _html = _html.replace(/<br>/ig, "\n").replace(/<\/p>/ig, "\n").replace(/<div>/ig, "\n").replace(/<[^>]+>/ig, "");
            }
            jQuery("textarea",editPanel).val(_html);
        } else {
            jQuery("input.main_edit",editPanel).val(textPanel.text());
        }
    
        if(editRich == "true"){
            jQuery("textarea",editPanel).qeditor(editor_options);
        } 
    
        // add 2012-1-11 by lesanc.li
        if (n && editType == "textarea"){
            if(editRich == "true"){
                App.inputLimit(jQuery(".qeditor_preview", editPanel), n, "text");
            } else {
                App.inputLimit(jQuery("textarea", editPanel), n);
            }
        }

        jQuery("a.cancel",editPanel).click(function(){
            linkId = jQuery(this).parent().attr("data-id");
            editPanel = jQuery("#ipe_"+linkId);
            editPanel.prev().show();
            editPanel.remove();
            return false;
        });

        jQuery("div.submit",editPanel).click(function(e){
            var elLen = 0, val = editPanel[0]["value"].value;
            if (editType == "textarea"){
                if(editRich == "true"){
                   var qeditor = jQuery(".qeditor_preview", editPanel);
                   val = qeditor.html();
                   elLen = real_length(jQuery.trim(qeditor.text()));
                } else {
                   elLen = real_length(jQuery.trim(val));
                }
                if (n && elLen > n){
                    e.preventDefault();
                    e.stopPropagation();
                    return false;
                } else if (elLen === 0){
                  val = "";
                  return false;
                }
            }
            App.loading();
            jQuery.ajax({
                url : remote_url,
                data : {id:editPanel[0]["id"].value, authenticity_token:editPanel[0]["authenticity_token"].value, value:jQuery.trim(val)}, //editPanel.serialize(),
                dataType : "text",
                type : "post",
                success : function(res){
                    if(res == "_nologin_"){
                        App.requireUser(res,"text");
                        return;
                    }
                    jQuery("#"+editPanel.attr("data-text-id")).html(res);
                    jQuery("a.cancel",editPanel).click();
                    App.loading(false);
                }
            });
            return false;
        });
    },

    hideNotice : function(id){
        jQuery("#sys_notice").fadeOut('fast');
    jQuery.cookie("hide_notice",id, { expires : 300 });
        return false;
    },

    /**
     * Get Rails CSRF key and value
     * result:
     * { key : "", value : "" }
     */
    getCSRF : function(){
        key = jQuery("meta[name=csrf-param]").attr("content");
        value = jQuery("meta[name=csrf-token]").attr("content");
    return { key : key, value : value };
    },

    /**
     * 文本框帮顶自动搜索用户功能
     * input  搜索框
     * callback 回调函数
     */
    completeUser : function(input,callback){
        input.autocomplete("/search/users", {
            mincChars: 1,
            delay: 50,
            width: 206,
            scroll : false,
            formatItem : function(data, i, total){
                return Asks.completeLineUser(data,false);
            }
        });
        input.result(function(e,data,formatted){
            if(data){
                user_id = data[1];
                name = data[0];
                callback(name, user_id);
            }
        });
    },

    //add 2011-11-8 by lesanc.li
    inputLimit: function(el, n, vtype, ttype){
        var editPanel = jQuery(el).parents("form");
        vtype = vtype || "val";
        ttype = ttype || "yes";
        var elLen = 0;
        var timeId = null;
        if(ttype=="yes"){
            var limitwords = jQuery(el).next('.limitwords');
            if(!limitwords.length) {
                limitwords = jQuery('<div class="limitwords"></div>');
                if (vtype==="text"){
                    jQuery(el).parents(".qeditor_border").after(limitwords);
                } else {
                    jQuery(el).after(limitwords);
                }
            }
            limitwords.hide();
            updateText();
        }
        jQuery(el).bind("blur", function(){clearInterval(timeId);
            // Added by P.S.V.R
            // 2011.2.14
            if('new_ask_title_gl'==jQuery(el).attr('id') && jQuery(el).val() && jQuery(el).val() != "问题标题"){
                jQuery.ajax({
                    type: 'POST',
                    url: '/ajax/seg',
                    dataType: 'json',
                    data: 'q='+jQuery(el).val(),
                    success: function(data) {
                        if (data){
                            for(var i=0;i<data.length;i++){
                                Asks.add_topic_to_new_ask_dialog(data[i]);
                            }
                        }
                    }          
                });
            }
        });
        jQuery(el).bind("focus", function(){
            if(ttype=="yes"){
                setTimeout(function(){limitwords.show();}, 0);
                timeId = setInterval(function(){    
                    updateText();
                }, 500);
            }
        });
        var _rh = jQuery(el).height();
        jQuery(el).bind("keypress", function(event){
            event = event || window.event;
            elLen = (vtype == "val")?real_length2(jQuery(el).val()):real_length2(jQuery(el).text());
            //elLen = (vtype == "val")?jQuery(el).val().length:jQuery(el).text().length;
            if (elLen >= 2*n && event.keyCode != 8){
                return false;
            } 
        });
        // add by lesanc.li 2012-3-28
        if (vtype === "val" && jQuery(el)[0].tagName.toLowerCase() === "textarea"){          
          jQuery(el).css({"overflow":"hidden"});
          jQuery(el).bind("keyup", function(event){
              event = event || window.event;
              if (event.keyCode === 8 || event.keyCode === 46){
                jQuery(el).css("height","auto");
                updateHeight(el);
              } else {
                updateHeight(el);
              }
          });
          jQuery(el).bind("input", function(){            
             updateHeight(el);
          });
        }

        jQuery(el).bind("paste", function(e){
           updateText();
           /* setTimeout(function(){
                if (vtype == "val"){
                    //jQuery(el).val(jQuery.trim(jQuery(el).val().replace(/\s+/g, " ")));
                } else {
                    //jQuery(el).html(jQuery.trim(jQuery(el).text().replace(/\s+/g, " ")));
                }
                setTimeout(function(){
                    updateText();
                }, 500);
            }, 500); */
        });
        
        editPanel[0].onsubmit = preventSubmit;
        jQuery("input[type='submit'],button[type='submit']", editPanel).click(preventSubmit);

        function updateHeight(ele, u){
          var sh = jQuery(ele)[0].scrollHeight + (u || 0);
          if (jQuery.browser.webkit){
            sh -= 12;
          }
          if (sh > _rh){
            jQuery(ele).css("height", sh + "px");
          } else {
			jQuery(ele).css("height", _rh + "px");
		  }
        }

        function preventSubmit(e){
            elLen = (vtype == "val")?real_length(jQuery(el).val()):real_length(jQuery(el).text());
            //elLen = (vtype == "val")?jQuery(el).val().length:jQuery(el).text().length;
            if (elLen > n){
                App.loading(false);
                e.preventDefault();
                e.stopPropagation();
                return false;
            }
        }

        function updateText(){
            elLen = (vtype == "val")?real_length(jQuery(el).val()):real_length(jQuery(el).text());
            //elLen = (vtype == "val")?jQuery(el).val().length:jQuery(el).text().length;
            if (elLen > n){
                limitwords.html('<span style="color:red">已经超过' + (elLen - n) + '个汉字</span>');
            } else {
                limitwords.html('您还可以输入' + (n - elLen) + '个汉字');
            }
        }
    },
    // 输入框默认提示 edit 2012-1-31 by lesanc.li
    placeHolder : function(el, tips, supportLowBrowser){
    if (supportLowBrowser === undefined){supportLowBrowser = true;}
        if (typeof document.createElement("input").placeholder != "undefined"){
            jQuery(el).attr("placeholder", tips);
        } else if(supportLowBrowser){
            jQuery(el).bind("focus", function(){
                if(jQuery(this).val() == tips){
                    jQuery(this).val("").css("color","#000000");
                }
            }).bind("blur", function(){
                if(jQuery.trim(jQuery(this).val()) == "" || jQuery(this).val() == tips){
                    jQuery(this).val(tips).css("color","#999999");
                }
            }).trigger("blur");
        }
    },
    // 刷新感兴趣的内容
    refresh_sugg : function(){
        App.loading();
        jQuery.get("/refresh_sugg", function(res){
            App.loading(false);
            if(res){
                jQuery("#refresh_sugg").replaceWith(res);
            }
        });
        return false;
    },

    testLogin : function(){
        if(!logined){
            Users.userLogin();
            jQuery("input[name='loginname']").trigger("focus");
            return false;
        }
        return true;
    },
  
    varsion : function(){
        return "1.0";
    }
}

function show_all_answer_body(log_id, answer_id) {
    jQuery('#aws_' + log_id + '_' + answer_id).addClass("force-hide");
    jQuery('#awb_' + log_id + '_' + answer_id).addClass("force-show");
    return false;
}

function mark_notifies_as_read(el, ids) {
    App.loading();
    jQuery.get("/mark_notifies_as_read?ids="+ids,function(){
        App.loading(false);
        jQuery(el).find(".close").hide();
        jQuery(el).parent().fadeOut();
    });
    jQuery(".userNotify").addClass("force-hide");
    return false;
}

function mark_all_notifies_as_read(el) {
    App.loading();
    jQuery.get("/mark_all_notifies_as_read",function(){
        App.loading(false);
        jQuery(el).find(".close").hide();
        jQuery(el).parent().fadeOut();
    });
    jQuery(".userNotify").addClass("force-hide");
    return false;
}

function expand_notification(el, type, id) {
    var items = jQuery("#N" + type + "_" + id + "_items");
	
    if (items.hasClass("force-show")) {
        items.removeClass("force-show");
    } else {
        items.addClass("force-show");
    }
    return false;
}

function real_length(str) {
    var elLen = str.length;
    var CJK = str.match(/[\u4E00-\u9FA5\uF900-\uFA2D]/g);
    if (CJK != null) elLen+=CJK.length;
    elLen=Math.ceil(elLen/2);
    return elLen;
}

function real_length2(str) {
    var elLen = str.length;
    var CJK = str.match(/[\u4E00-\u9FA5\uF900-\uFA2D]/g);
    if (CJK != null) elLen+=CJK.length;
    return elLen;
}

function checklen(obj,size){
    var tno = document.getElementById(obj.id+"_tno");
    var lenE = obj.value.length;
    var lenC = 0;
    var CJK = obj.value.match(/[\u4E00-\u9FA5\uF900-\uFA2D]/g);
    if (CJK != null) lenC+=CJK.length;
    tno.innerText = size-lenC-lenE;
    if (tno.innerText < 0) {
        var tmp = 0
        var cut = obj.value.substring(0,size);
        for (var i=0; i<cut.length; i++){
            tmp += /[\u4E00-\u9FA5\uF900-\uFA2D]/.test(cut.charAt(i)) ? 2 : 1;
            if (tmp > size) break;
        }
        obj.value = cut.substring(0, i);
    }
}