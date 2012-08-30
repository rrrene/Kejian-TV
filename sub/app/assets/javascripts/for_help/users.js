var Users = {
  follow : function(el, id, small){
    if(!logined){
      Users.userLogin();
      return false;
    }
    App.loading();
    $.get("/users/"+id+"/follow",{}, function(res){
        $(el).replaceWith('<a onclick="return Users.unfollow(this, \''+ id +'\',\''+small+'\');" class="'+(small == 'small'?'nBtn nBtnUnFocus':'bBtn bBtnUnFocus')+'"></a>');
        App.loading(false);
    });
    return false;
  },
  unfollow : function(el, id, small){
    if(!logined){
      Users.userLogin();
      return false;
    }
    App.loading();
    $.get("/users/"+id+"/unfollow",{}, function(res){
        $(el).replaceWith('<a onclick="return Users.follow(this, \''+ id +'\',\''+small+'\');" class="'+(small == 'small'?'nBtn nBtnFocus':'bBtn bBtnFocus')+'"></a>');
        App.loading(false);
    });
    return false;
  },

  simple_follow : function(el,id){
    App.loading();
    $.get("/users/"+id+"/follow",{}, function(res){
        App.loading(false);
        if(!App.requireUser(res,"text")){
          return false;
        }
        $(el).replaceWith('<a onclick="return Users.simple_unfollow(this,\''+id+'\')" href="#">取消关注</a>'); 
    });
    return false;
  },

	simple_unfollow : function(el,id){
    App.loading();
    $.get("/users/"+id+"/unfollow",{}, function(res){
        App.loading(false);
        if(!App.requireUser(res,"text")){
          return false;
        }
		 $(el).replaceWith('<a onclick="return Users.simple_follow(this,\'' + id + '\')" href="#">关注</a>'); 
    });
    return false;
  },

  /* 不感兴趣推荐的用户或话题 */
  mute_suggest_item : function(el, type, id){
    $(el).parent().parent().fadeOut("fast");
    $.get("/mute_suggest_item", { type : type, id : id },function(res){
        App.requireUser(res);
    });
    return false;
  },

  varsion : function(){},
  
  // 隐藏或展开个人经历 add 2011-9-23 by lesanc.li
  toggleBio : function(){
	var bio = $('.user_profile .detail .bio');
	if (bio.height() > 120){
		bio.find('#user_bio').css({'height':'100px', 'width':'500px', 'display':'block', 'overflow':'hidden', 'word-break':'break-all'});
		bio.find('#user_bio').after('<div><a href="#" id="bioMore">展开</a></div>');
		$('#bioMore').css({'text-decoration':'underline', 'font-size':'12px', 'color':'#999999'});
	}
  },
  
  bioToggleMore : function(el){
	$(el).toggle(function(){
	  $('.user_profile .detail .bio #user_bio').css({'height':''});
	  $('#bioMore').html('收起');
	}, function(){
	  $('.user_profile .detail .bio #user_bio').css({'height':'100px'});
	  $('#bioMore').html('展开');
    });
  },

  // modify 2012-2-6 by lesanc.li
  userLogin: function(){
    var lhtml = [];
    lhtml.push('<header>欢迎使用智联招聘账号登录问道 <a class="close" href="javascript:void(0);"></a></header>');
    lhtml.push('<section class="form clearfix">');
    lhtml.push('<form name="frmLogin" id="frmLogin" method="post" action="http://my.zhaopin.com/loginmgr/loginproc.asp">');
    lhtml.push('<dl>');
    lhtml.push('<dt>账&nbsp;&nbsp;号:</dt>');
    lhtml.push('<dd><input type="text" class="fl input-x-validate" name="loginname" maxlength="100" value="" />');
    lhtml.push('<div class="validImg fl"></div><div class="validTip fl" id="tip_loginname"></div></dd>');
    lhtml.push('<dt>密&nbsp;&nbsp;码:</dt>');
    lhtml.push('<dd><input type="password" class="fl input-x-validate" name="password" maxlength="25" value="" />');
    lhtml.push('<div class="validImg fl"></div><div class="validTip fl" id="tip_password"></div></dd>');
    lhtml.push('<dt></dt>');
    lhtml.push('<dd  style="height:18px;"><span style="float:right;"><a href="http://my.zhaopin.com/loginmgr/forgetpassword.asp" target="_blank">忘记密码？</a></span>');
    lhtml.push('<input style="width:18px;" type="checkbox" class="noBorder" name="isautologin" value="1" />记住登录状态</dd>');
    lhtml.push('<input type="hidden" name="Validate" id="Validate" value="campusspecial2011unify" />');
    lhtml.push('<input type="hidden" name="errbkurl" id="errbkurl" value="'+location.href+((location.href.indexOf('error=1')>-1)?'':'?error=1')+'" />');
    lhtml.push('<input type="hidden" name="bkurl" id="bkurl" value="'+location.href.replace('?error=1', '')+'" />');
    lhtml.push('</dl></form></section>');
    lhtml.push('<footer>');
    lhtml.push('<div class="btnNormalGreen bold mt20 login"><span>&nbsp;登 录&nbsp;</span></div>');
    lhtml.push('<div class="goLog mt20">没有智联招聘账号？<a href="#" onclick="Users.userReg()">立即注册</a></div>');
    lhtml.push('</footer>');
    $.facebox({ html : lhtml.join(""), overlay : false });
    var form = document.forms["frmLogin"];
    var loginname = $("#facebox input[name='loginname']");
    var password = $("#facebox input[name='password']");
    var login = $("#facebox .login");
    App.placeHolder(loginname, "邮箱/用户名");
    //App.placeHolder(password, "密码", false);
    // submit
//    loginname.validate({
//      rules: [{
//        text: '请输入有效的E-mail地址',
//        rule: "email"
//      }],
//      tipTag: $("#tip_loginname")
//    });
//    password.validate({
//      rules : [{
//          text : '密码是6-25位的字母数字和下划线',
//          rule : function(a,b){
//            return /^[a-zA-Z0-9_]{6,25}$/.test(b);
//          }
//        }],
//      tipTag : $("#tip_password")
//    });
    login.unbind("click").click(function(){
      checkLogin();
    });
    password.keydown(function(e){
      if (e.keyCode == 13){
        checkLogin();
      }
    });
    function checkLogin(){
//      formFlag = {};
//      loginname.validate();
//      password.validate();
//      for (var flag in formFlag){
//        if (!formFlag[flag]) return false;
//      }
      form.submit();
    }
    return false;
  },
  // add 2012-2-5 by lesanc.li
  userLogout: function(){
    var url = location.href;
    if (/(^http:\/\/[^\/]+\/)/i.test(url)){
      location.href='http://my.zhaopin.com/loginmgr/logout.asp?strBkUrl='+RegExp['$1'];
    }
    return false;
  },
  // modify 2012-2-6 by lesanc.li
  userReg: function(){
    var url = location.href;
    if (/(^http:\/\/[^\/]+\/)/i.test(url)){
      url=RegExp['$1'];
    }
    var lhtml = [];
    lhtml.push('<header>注册智联招聘账号 <a class="close" href="javascript:void(0);"></a></header>');     
    lhtml.push('<section class="form clearfix">');
    lhtml.push('<form name="regform" id="regform" method="post" action="http://my.zhaopin.com/loginmgr/registerProc.asp">');
    lhtml.push('<dl>');
    lhtml.push('<dt>常用邮箱:</dt>');
    lhtml.push('<dd><input type="hidden" name="redirect_url" value="'+url+'" />');
    lhtml.push('<input type="text" size="32" name="email" id="email" class="user_email fl input-x-validate" value="" maxlength="100" />');
    lhtml.push('<div class="validImg fl"></div><div class="validTip fl" id="tip_email"></div></dd>');
    lhtml.push('<dt>登录密码:</dt>');
    lhtml.push('<dd><input type="password" class="fl input-x-validate" name="password1" id="password1" value="" size="32" />');
    lhtml.push('<div class="validImg fl"></div><div class="validTip fl" id="tip_password1"></div></dd>');
    lhtml.push('<dt>确认密码:</dt>');
    lhtml.push('<dd><input type="password" class="fl input-x-validate" name="password2" id="password2" value="" size="32" />');
    lhtml.push('<div class="validImg fl"></div><div class="validTip fl" id="tip_password2"></div></dd>');
    lhtml.push('<dt></dt>');
    lhtml.push('<dd class="clear"><div class="details"><input type="checkbox" class="noBorder accept" name="accept" checked="checked" style="width:20px;" />我接受 <a target="_blank" href="/agreement">问道用户协议</a> 和 <a target="_blank" href="http://jobseeker.zhaopin.com/zhaopin/aboutus/secrecy.html">智联隐私协议</a></div></dd>');
    lhtml.push('</dl>');
    lhtml.push('</form></section>');
    lhtml.push('<footer>');
    lhtml.push('<div class="btnNormalGreen bold mt20 reg"><span>&nbsp;注 册&nbsp;</span></div>');
    lhtml.push('<div class="goLog mt20">已有智联招聘账号？<a href="#" onclick="Users.userLogin()">直接登录</a></div>');
    lhtml.push('</footer>');
    $.facebox({ html : lhtml.join(""), overlay : false });
    var form = document.forms["regform"];
    var email = $("#facebox input[name='email']");
    var password1 = $("#facebox input[name='password1']");
    var password2 = $("#facebox input[name='password2']");
    var accept = $("#facebox input[name='accept']");
    var reg = $("#facebox .reg");
    var form = $("#facebox form");
    var email = $("#facebox input[name='email']");
    var password1 = $("#facebox input[name='password1']");
    var password2 = $("#facebox input[name='password2']");
    var accept = $("#facebox input[name='accept']");
    var reg = $("#facebox .reg");
    // email validate
    email.validate({
      rules: [{
        text: '请输入有效的E-mail地址',
        rule: "email"
      },{
        type: "ajax",
        rule: function(){
          $.getScript("http://my.zhaopin.com/myzhaopin/CEF_markhome.asp?opt=1&email=" + email.val(), function(){
            if (typeof cefmarkhome != 'undefined'){
              if (cefmarkhome == 1){
                email.parent().attr("class", "input-x-validate-error");
                $("#tip_email").html('该邮箱已注册智联账号，可<a onclick="Users.userLogin()" href="#">直接登录</a>');
                formFlag["email"] = false;
              } else if (cefmarkhome == 0){
                email.parent().attr("class","input-x-validate-valid");
                formFlag["email"] = true;
                for (var flag in formFlag){
                  if (!formFlag[flag]){
                    return false;
                  }
                }
                form.submit();
              }
            }
          });
        }
      }],
      tipTag: $("#tip_email")
    });
    password1.validate({
      rules : [{
          text : '密码只能是6-25位的字母数字和下划线',
          rule : function(a,b){
            return /^[a-zA-Z0-9_]{6,25}$/.test(b);
          }
        }],
      defaultText : "密码是6-25位的字母数字和下划线", 
      tipTag : $("#tip_password1")
    });
    password2.validate({
      rules : [{
          text : '密码只能是6-25位的字母数字和下划线',
          rule : function(a,b){
           return /^[a-zA-Z0-9_]{6,25}$/.test(b);
          }
        },{
          text : '两次输入密码不相同',
          rule : function(a,b){
           return password1.val() == password2.val();
          }
        }],
      defaultText : "密码是6-25位的字母数字和下划线", 
      tipTag : $("#tip_password2")
    });
    reg.unbind("click").click(function(){
      checkregform();
    });
    password2.keydown(function(e){
      if (e.keyCode == 13){
        checkregform();
      }
    });
    function checkregform(){
      formFlag = {};
      formFlag["submit"] = true;
      email.validate();
      password1.validate();
      password2.validate();
      if(!accept[0].checked){
        formFlag["accept"] = false;
        return false;
      } else {
        formFlag["accept"] = true;
      }
      for (var flag in formFlag){
        if (!formFlag[flag]){
          return false;
        }
      }
      form.submit();
    }
    return false;
  }
}

$(document).ready(function(){
  Users.toggleBio();
	Users.bioToggleMore($('#bioMore'));
});