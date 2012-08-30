/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


// 触发mobileinit事件
jQuery(document).bind("mobileinit", function(){
    //alert('mobileinit');
    
    
});
jQuery(document).ready(function(){
    
    
    // 点击“我要回答”按钮，定位到屏幕最底，同时输入框获得焦点。
    jQuery('#btnGoToAnswer').click(function(){
        jQuery.mobile.silentScroll(jQuery(document).height());
        jQuery('#inputAnswerTextarea').focus();
    });
    // 点击textarea，清空里面的placeholder文本
    jQuery('#inputAnswerTextarea').focus(function(){
        jQuery(this).html('');
    })
    // 点击提交按钮提交本页第一个表单（单页也总会只有一个表单）
    jQuery('#btnSubmitForm').click(function(){
        jQuery('form').submit();
    })
    // 搜索页面，搜索按钮动作
    jQuery('#btnGoToSearch').click(function(){
        jQuery('form').submit();
    })
});

    /*
jQuery('#acura').click(function(){
    // 页面跳转方法
    jQuery.mobile.changePage("test.html", "slideup");

    // 向result.php页面提交ID为Search的表单post数据，直接本页跳转
    jQuery.mobile.changePage( "searchresults.php", {
            type: "post", 
            data: jQuery("form#search").serialize()
    });

    // AJAXload页面内容插到当前页PAGE中
    jQuery.mobile.loadPage( "test.html" );	

    // 显示LOADING框		
    jQuery.mobile.showPageLoadingMsg('asdfasdf');

    // 显示header和footer浮动容器
    jQuery.mobile.fixedToolbars.show();
});
     */
    