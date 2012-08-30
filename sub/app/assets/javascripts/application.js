// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_noconflict
//= require jquery_ujs
//= require ./psvr_kina
//= require_self



jQuery(function(){
  window.psvr_bgImg = new Image();
  window.psvr_bgImg.onload = function() {
    jQuery.extend(window.psvr_kina, {
        psvr_height: window.psvr_bgImg.height,
        psvr_width: window.psvr_bgImg.width
    });
    jQuery(window.psvr_bgImg).addClass('psvr_bgimg');
    jQuery(window.psvr_bgImg).attr('id','ktv_bg');
    jQuery(window.psvr_bgImg).attr('alt',<%=raw $cnu_fotos[@bg_index].to_json %>);
    jQuery('#ktv_bg_container').prepend(window.psvr_bgImg);
    jQuery.extend(window.psvr_kina, {
        bg: jQuery('#ktv_bg')[0],
        timer: setInterval(window.psvr_kina.fix, 200)
    });
  };
  window.psvr_bgImg.src = <%= raw asset_path("cnu_foto/#{@bg_index}.jpg").to_json %>;
  //jQuery('body').css('padding-bottom',jQuery(window).height()/2);
});
