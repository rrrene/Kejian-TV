$(document).ready(function(){
  // 登录
  $("form[name='loginform']").submit(function(e){
    var loginform = $(this)[0];
    if ($.trim(loginform.loginname.value) == ""){
      showTip("账号不能为空！");
      loginform.loginname.focus();
      return false;
    }
    if ($.trim(loginform.password.value).length < 6){
      showTip("密码不能少于6位！");
      loginform.password.focus();
      return false;
    }
    loginform.method = "post";
    loginform.action = "http://my.kejian.tv//loginmgr/loginproc.asp";
    loginform.bkurl.value = "http://"+location.host+"/?force_mobile=1";
    loginform.errbkurl.value = "http://"+location.host+"//mobile/login?error=1";
    return true;
  });

  // 注册
  $("form[name='regform']").submit(function(e){
    var regform = $(this)[0];
    if ($.trim(regform.email.value) == ""){
      showTip("常用邮箱不能为空！");
      regform.email.focus();
      return false;
    }
    if ($.trim(regform.password1.value).length < 6){
      showTip("登录密码不能少于6位！");
      regform.password1.focus();
      return false;
    }
    if ($.trim(regform.password2.value).length < 6){
      showTip("确认密码不能少于6位！");
      regform.password2.focus();
      return false;
    }
    if (regform.password2.value != regform.password1.value){
      showTip("两次输入的密码不一致！");
      regform.password2.focus();
      return false;
    }
    regform.method = "post";
    regform.action = "http://my.kejian.tv/loginmgr/registerProc.asp";
    regform.redirect_url.value = "http://"+location.host+"/";
    $.mobile.showPageLoadingMsg();
    $.getScript("http://my.kejian.tv/myzhaopin/CEF_markhome.asp?timestamp=" + new Date().getTime()+"&opt=1&email=" + regform.email.value, function(){
      $.mobile.hidePageLoadingMsg();
      if (typeof cefmarkhome != 'undefined' && cefmarkhome != 1){
          regform.submit();
      } else {
          showTip("邮箱已存在！");
      }
    });
    return false;
  });

  function showTip(msg){
    $("<div class='ui-loader ui-overlay-shadow ui-body-e ui-corner-all'><h1>"+msg+"</h1></div>").css({ "display": "block", "opacity": 0.96, "top":
$(window).scrollTop() + 100 })
    .appendTo( $.mobile.pageContainer )
    .delay( 1500 )
    .fadeOut( 400, function(){
      $(this).remove();
    });
  }
});