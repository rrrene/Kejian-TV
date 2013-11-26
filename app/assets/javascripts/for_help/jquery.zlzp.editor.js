/*
 * 功能：生成富文本编辑器
 * 依赖：jquery-1.6.4.min.js
 * 示例：
 * $("#content").editor(opts);
 * 参数：
 * opts：参数，false/object：
 * 1、false：注销富文本编辑功能。
 * 2、object属性：
 * 		is_mobile_device： 是否是移动设备，默认为false。如果为true，其他设置无效
 * 		width：宽度  默认为自适应
 * 		height：默认为50px，并且自适应输入内容；如果指定高度，超出时出现滚动条
 * 
 */
;
var imgPath = "/assets/for_help/zlzp/";
QEDITOR_TOOLBAR_HTML = '\<div class="qeditor_toolbar"> \
	  <a href="#" onclick="return QEditor.action(this,\'bold\');" title="加粗"><b>B</b></a> \
	  <a href="#" onclick="return QEditor.action(this,\'italic\');" title="倾斜"><i>I</i></a> \
	  <a href="#" onclick="return QEditor.action(this,\'underline\');" title="下划线"><u>U</u></a> \
	  <a href="#" onclick="return QEditor.action(this,\'strikethrough\');" title="删除线" alt="删除线"><strike>S</strike></a> \
	  <a href="#" onclick="return QEditor.action(this,\'insertorderedlist\');"><img src="'
		+ imgPath
		+ 'ol.gif" title="有序列表" alt="有序列表" /></a> \
	  <a href="#" onclick="return QEditor.action(this,\'insertunorderedlist\');"><img src="'
		+ imgPath
		+ 'ul.gif" title="无序列表" alt="无序列表" /></a> \
</div>';

var QEditor = {
	action : function(e, a, p) {
		qeditor_preview = $(".qeditor_preview", $(e).parent().parent());
		if (qeditor_preview.html().indexOf("<")==-1){
			qeditor_preview.append('<br _moz_dirty="" type="_moz">');
		}
		qeditor_preview.focus();

		if (p == null) {
			p = false;
		}
		
		if (a == "insertcode") {
			alert("TODO: inser [code][/code]");
		} else {
			document.execCommand(a, false, p);
		}
		if (qeditor_preview != undefined) {
			//qeditor_preview.change();
		}

		return false;
	},

	renderToolbar : function(el) {
		el.parent().prepend(QEDITOR_TOOLBAR_HTML);
	},

	version : function() {
		return "0.1";
	}
};

(function($) {
	$.fn.qeditor = function(options) {
		if (options == false) {
			return this.each(function() {
				var obj = $(this);
				obj.parent().find('.qeditor_toolbar').detach();
				obj.parent().find('.qeditor_preview').detach();
				obj.unwrap();
			});
		} else {
      options = options || {};
			return this
					.each(function() {
						var obj = $(this);
						obj.addClass("qeditor");
						if (options && options["is_mobile_device"]) {
							var hidden_flag = $('<input type="hidden" name="did_editor_content_formatted" value="no">');
							obj.after(hidden_flag);
						} else {
							var preview_editor = $('<div class="qeditor_preview" contentEditable="true"></div>');
							preview_editor.html(obj.val());
							obj.after(preview_editor);
							preview_editor.change(function() {
								pobj = $(this);
								t = pobj.parent().find('.qeditor');
								t.val(pobj.html());
							});
							preview_editor.keyup(function() {
								$(this).change();
							});
							obj.hide();
							var qeditor_border = $('<div class="qeditor_border"></div>');
							qeditor_border.css({
								"width" : (options["width"] && typeof options["width"] == "number")?(options["width"] + "px"):"100%",
								"height" : (options["height"] && typeof options["height"] == "number")?(options["height"]>93?(options["height"] + "px"):"93px"):"100%"
							});
							if (options["height"]){
                preview_editor.css({
                  "height" : qeditor_border.height() - 43 + "px",
                  "overflow": "auto"
                });
							} else {
                preview_editor.css({  
                  "height" : "auto",
                  "overflow": "visible"
                });
                if ($.browser.msie && $.browser.version <= 6.0){
                  preview_editor.css({  
                    "height" : "50px"
                  });
                }
              } 
							obj.wrap(qeditor_border);
							obj.after(preview_editor);
							QEditor.renderToolbar(preview_editor);
              if (options["limit"]){
                App.inputLimit(preview_editor, options["limit"], "text");
              }
						}
					});
		}
	};
})(jQuery);
