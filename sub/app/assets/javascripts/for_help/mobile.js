/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


// 触发mobileinit事件
$(document).bind("mobileinit", function(){
    //alert('mobileinit');
    
    
});
$(document).ready(function(){
    
    
    // 点击“我要回答”按钮，定位到屏幕最底，同时输入框获得焦点。
    $('#btnGoToAnswer').click(function(){
        $.mobile.silentScroll($(document).height());
        $('#inputAnswerTextarea').focus();
    });
    // 点击textarea，清空里面的placeholder文本
    $('#inputAnswerTextarea').focus(function(){
        $(this).html('');
    })
    // 点击提交按钮提交本页第一个表单（单页也总会只有一个表单）
    $('#btnSubmitForm').click(function(){
        $('form').submit();
    })
    // 搜索页面，搜索按钮动作
    $('#btnGoToSearch').click(function(){
        $('form').submit();
    })
});

    /*
$('#acura').click(function(){
    // 页面跳转方法
    $.mobile.changePage("test.html", "slideup");

    // 向result.php页面提交ID为Search的表单post数据，直接本页跳转
    $.mobile.changePage( "searchresults.php", {
            type: "post", 
            data: $("form#search").serialize()
    });

    // AJAXload页面内容插到当前页PAGE中
    $.mobile.loadPage( "test.html" );	

    // 显示LOADING框		
    $.mobile.showPageLoadingMsg('asdfasdf');

    // 显示header和footer浮动容器
    $.mobile.fixedToolbars.show();
});
     */
    