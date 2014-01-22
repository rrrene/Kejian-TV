// 触发mobileinit事件
$(document).bind("mobileinit", function(){
});
$(document).ready(function(){
    // 点击“我要解答”按钮，定位到屏幕最底，同时输入框获得焦点。
    $('#btnGoToAnswer').click(function(){
        $.mobile.silentScroll($(document).height());
        $('#inputAnswerTextarea').focus();
    });
    // 点击textarea，清空里面的placeholder文本
    $('#inputAnswerTextarea').focus(function(){
        $(this).html('');
    });
    // 点击提交按钮提交本页第一个表单（单页也总会只有一个表单）
    $('#btnSubmitForm').click(function(){
        $('form').submit();
    });
    // 搜索页面，搜索按钮动作
    $('#btnGoToSearch').click(function(){
        $('form').submit();
    });
});