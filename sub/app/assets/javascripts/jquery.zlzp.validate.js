/*
 * 功能：实现表单输入的合法验证
 * 依赖：jquery-1.6.4.min.js
 * 示例：
 * $("#username").validate({
 *     rules: [{
 *     	 text:"用户名不能为空",
 *       rule:"empty"
 *     }, {
 *     	 text:"用户名必须为6-20个字符",
 *       rule:"length",
 *       min:6,
 *       max:20
 *     }
 *     ], 
 *     defaultText:"请输入用户名", 
 *     validText:"输入正确"
 * });
 * 参数：
 * rules：检验规则，取值可以是以下若干值的组成的数组：
 * 1、number：全数字检验。
 * 2、string：全字符检验（除数字以为的所有字符）。
 * 3、normal：常规字符检验（a-zA-Z0-9_）
 * 4、email：电子邮件检验。
 * 5、length{6,25}: 长度检验。
 * 6、checked：表单选择状态检验。
 * defaultText: 提示文本。
 * validText: 输入正确文本。
 */
;
var formFlag = {};
(function($) {
  // 样式配置
  var sClass = [ "input-x-validate-default", "input-x-validate-error",
					"input-x-validate-valid" ];
	var tipClass = [ "tip-x-validate-default", "tip-x-validate-error",
					"tip-x-validate-valid" ];
	// 规则定义
	var basicRules = {
		empty : function(str) {
			if ($.trim(str) != "") {
				return true;
			} else {
				return false;
			}
		},
		number : function(str) {
			if (/^\d*$/.test(str)) {
				return true;
			} else {
				return false;
			}
		},
		string : function(str) {
			if (/^\D*$/.test(str)) {
				return true;
			} else {
				return false;
			}
		},
		normal : function(str) {
			if (/^[a-zA-Z0-9_]*$/.test(str)) {
				return true;
			} else {
				return false;
			}
		},
		email : function(str) {
			if (/^[a-z0-9][_a-z0-9\-]*([\.][_a-z0-9\-]+)*@([a-z0-9\-_]+[\.])+(?:cc|com|edu|gov|int|net|org|biz|info|pro|name|coop|al|dz|af|ar|ae|aw|om|az|eg|et|ie|ee|ad|ao|ai|ag|at|au|mo|bb|pg|bs|pk|py|ps|bh|pa|br|by|bm|bg|mp|bj|be|is|pr|ba|pl|bo|bz|bw|bt|bf|bi|bv|kp|gq|dk|de|tl|tp|tg|dm|do|ru|ec|er|fr|fo|pf|gf|tf|va|ph|fj|fi|cv|fk|gm|cg|cd|co|cr|gg|gd|gl|ge|cu|gp|gu|gy|kz|ht|kr|nl|an|hm|hn|ki|dj|kg|gn|gw|ca|gh|ga|kh|cz|zw|cm|qa|ky|km|ci|kw|cc|hr|ke|ck|lv|ls|la|lb|lt|lr|ly|li|re|lu|rw|ro|mg|im|mv|mt|mw|my|ml|mk|mh|mq|yt|mu|mr|us|um|as|vi|mn|ms|bd|pe|fm|mm|md|ma|mc|mz|mx|nr|np|ni|ne|ng|nu|no|nf|na|za|aq|gs|eu|pw|pn|pt|jp|se|ch|sv|ws|yu|sl|sn|cy|sc|sa|cx|st|sh|kn|lc|sm|pm|vc|lk|sk|si|sj|sz|sd|sr|sb|so|tj|tw|th|tz|to|tc|tt|tn|tv|tr|tm|tk|wf|vu|gt|ve|bn|ug|ua|uy|uz|es|eh|gr|hk|sg|nc|nz|hu|sy|jm|am|ac|ye|iq|ir|il|it|in|id|uk|vg|io|jo|vn|zm|je|td|gi|cl|cf|cn)$/
					.test(str)) {
				return true;
			} else {
				return false;
			}
		},
		length : function(str, start, end) {
			start = start || 0;
			end = end || 1024;
			if (str.length >= start && str.length <= end) {
				return true;
			} else {
				return false;
			}
		},
		checked : function(jqObj) {
			if (jqObj[0].checked) {
				return true;
			} else {
				return false;
			}
		}
	};
  
	// 表单验证
	$.fn.validate = function(opts) {
    //var flag = true;
		return this.each(function(i) {
      var s = $(this);
      if (opts == undefined){
        s.trigger("blur");
      } else {
        opts.defaultText = opts.defaultText || (opts.tipTag && opts.tipTag.text()) || "";
        opts.validText = opts.validText || (opts.tipTag && opts.tipTag.text()) || "";
        if (typeof window["validate-no"] == "undefined") {
          window["validate-no"] = 1000;
        }
        s.no = window["validate-no"]++;
        var tipTag = opts.tipTag;
        if (!tipTag){
          tipTag = $("#tip-x-validate" + s.no);
          if (tipTag.length == 0) {
            tipTag = $("<span id=\"tip-x-validate" + s.no + "\"></span>");
          }
          s.after(tipTag);
        }
        if (opts.rules && opts.rules.length > 0) {
          s.bind("focus", function() {
            formFlag["submit"] = false;
            updateStatus(s, opts.defaultText, 0);
          });
          s.bind("blur", function() {
            if(check(opts.rules, s)){
              updateStatus(s, opts.validText, 2);
            } else {
              formFlag[s.attr("id")] = false;
              //flag =  false;
            }
          });         
//          if (opts.formObj){
//            opts.formObj.bind("submit", function(){
//              return check(opts.rules, s);
//            });
//          }
        }
        // 规则检验
        function check(r, s, index) {
          for ( var i = 0; i < r.length; i++) {
            if (r[i].target != undefined && index && r[i].target.indexOf(index+"@") == -1){
              continue;
            }
            if (r[i].type == "ajax"){
              var ra = r[i];
              continue;
            }
            if (r[i].min || r[i].max) {
              if (!basicRules["length"](s.val(), r[i].min, r[i].max)) {
                updateStatus(s, opts.rules[i].text, 1);
                return false;
              }
            }
            if (r[i].rule == "checked") {
              if (!basicRules["checked"](s)) {
                updateStatus(s, opts.rules[i].text, 1);
                return false;
              }
            } else if (basicRules[r[i].rule] instanceof Function){
              if (!basicRules[r[i].rule](s.val())) {
                updateStatus(s, opts.rules[i].text, 1);
                return false;
              }
            } else if (r[i].rule instanceof Function){
              if (!r[i].rule(s, s.val())) {
                updateStatus(s, opts.rules[i].text, 1);
                return false;
              } 
            }
          }
          if (typeof ra == "object"){
            ra.rule();
            return false;
          }
          return true;
        }
        // 状态更新
        function updateStatus(s, str, status) {
          for ( var i = 0; i < 3; i++) {
            s.parent().removeClass(sClass[i]);
            tipTag.removeClass(tipClass[i]);
          }
          s.parent().addClass(sClass[status]);
          tipTag.addClass(tipClass[status]);
          if(str!== undefined)tipTag.html(str);
        }
      }
		});
	};
})(jQuery);