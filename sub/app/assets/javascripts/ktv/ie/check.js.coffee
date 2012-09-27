App.strlen = (str)->
  len=0
  i=0
  while i<str.length
    if str.charCodeAt(i)>255
      len+=2
    else
      len++
    i++
  return len

App.chinese = (str)->
  _80=0
  i=0
  while i<str.length
    if str.charCodeAt(i)>255
      _80++
    i++
  return _80

App.showRegError = (fieldname,content) ->
  $('#regerror_'+fieldname).html(content)

App.checkUsernameAjax = (val)->
  $.ajax(
    url: '/ajax/checkUsername'
    data:
      q:val
    success: (data, textStatus, jqXHR) ->
      unless data.okay
        App.showRegError("name","请输入真实中文姓名<br><span style=\"font-size:12px\">(若不愿透露姓名，请输入一个下划线开头的名字以跳过此检查)</span>")
  )
App.checkEmailAjax = (val)->
  $.ajax(
    url: '/ajax/checkEmailAjax'
    data:
      q:val
    success: (data, textStatus, jqXHR) ->
      unless data.okay
        App.showRegError("email","E-mail已经被使用")
  )
App.checkUsername= (el) ->
  App.showRegError("name",'')
  _b7=$(el).val();
  if(_b7=="")
    return false;
  if(App.strlen(_b7)>12)
    App.showRegError("name","不能多于6个汉字或者12个字符");
    return false;
  if(_b7[0] != '_')
    if(App.chinese(_b7)<2)
      App.showRegError("name","请输入真实中文姓名<br><span style=\"font-size:12px\">(若不愿透露姓名，请输入一个下划线开头的名字以跳过此测试)</span>");
      return false;
    App.checkUsernameAjax(_b7);
  return true;
  
App.checkEmail= (el) ->
  App.showRegError("email",'')
  _b7=$(el).val();
  email_regexp = /^[^@]+@([^@\.]+\.)+[^@\.]+$/
  if(_b7=="")
    return false;
  unless email_regexp.test(_b7)
    App.showRegError("email","E-mail不是有效的");
    return false;
  App.checkEmailAjax(_b7);
  return true;

App.checkPassword= (el) ->
  App.showRegError("password",'')
  _b7=$(el).val();
  if(_b7=="")
    return false;
  unless _b7.length>=6
    App.showRegError("password","密码过短（最短为 6 个字符）")
    return false
  unless _b7.length<=128
    App.showRegError("password","密码过长（最长为128个字符）")
    return false
  return true
  
App.checkPasswordConfirmation= (el) ->
  App.showRegError("password_confirmation",'')
  _b7=$('#user_password').val();
  _b8=$('#user_password_confirmation').val();
  if(_b7=="")
    return false;
  unless _b7 == _b8
    App.showRegError("password_confirmation","密码与确认值不匹配")
    return false
  return true
