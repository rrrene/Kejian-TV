jQuery(function(){
  window.psvr_ie_already_ready=true;
});

jQuery.fn.editable = function () {
    this.each(function () {
        jQuery(this).click(function () {
            var b = jQuery(this),
                c = b.parent().find("form"),
                d = c.find("input[type=text]:first");
            b.hide(), c.show(), d.focus(), d.blur(function () {
                c.hide(), b.show()
            })
        })
    })
};


jQuery.fn.disableSelection = function () {
    return this.each(function () {
        jQuery(this).attr("unselectable", "on").css({
            "-moz-user-select": "none",
            "-webkit-user-select": "none",
            "user-select": "none"
        }).each(function () {
            this.onselectstart = function () {
                return !1
            }
        })
    })
};
