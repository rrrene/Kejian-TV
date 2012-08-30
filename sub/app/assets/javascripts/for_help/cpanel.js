// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/for_help/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require ./jquery-ui-1.8.16.custom.min.js
//= require ./jquery.timepickr.js
function submit_page(){
    if(event.keyCode ==13){
        if(jQuery('#render_page_input').val()==''){
            alert('请输入需要跳转的页码!');
        }else{
            var bl=!isNaN(Number(jQuery('#render_page_input').val())) && (jQuery('#render_page_input').val() > 0);
            var p=bl ? Number(jQuery('#render_page_input').val()) : 1;
            var h=document.location.href;
            var url =h.indexOf('?')>0 ? (h.indexOf('page=')>0? h.replace(/page=.*&|page=.*/,'page='+p+'&') :h+'&page='+p ) : (h+'?&page='+p);
            window.location.href=url;
        }
    }
}
function real_length2(str) {
    var elLen = str.length;
    var CJK = str.match(/[\u4E00-\u9FA5\uF900-\uFA2D]/g);
    if (CJK != null) elLen+=CJK.length;
    return elLen;
}


