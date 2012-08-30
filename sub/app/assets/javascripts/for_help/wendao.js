$(document).ready(function(){

    // 个人设置弹层，离开隐藏
    $('.userInfoName').mouseover(function(){
        $('#userInfoPop').show();
    })
    $('#userInfoPop').mouseleave(function(){
        $('#userInfoPop').hide();
    });
	
    $('.userPageHeader img.imgHead').mouseenter(function(){
        $(this).next().show();
    });
	
    // 上传头像表单模拟
    $("#file_uploader").live("change", function(){
        $("#file_uploader_text", $(this).prev()).val(this.value);
    });
	
	
    /*
	var windowHeight = $(window).height(), // 屏幕高度
		bodyHeight = $(document).height();   // 整页高度
	$(document).scroll(function(){
		var scrollTop = $(this).scrollTop(); // 当前滚动条高度 scrollTop
		console.log(windowHeight);
		console.log(bodyHeight);
		if ((scrollTop + windowHeight) === bodyHeight) {
			console.log('到了');
		}
	});
	*/

    // 初始化富文本编辑器
    $("textarea.richeditor").each(function(){
        var limit = 0;
        if ($(this).attr("id") === "edit_user_bio"){
            limit = 2000;
        } else if ($(this).attr("id") === "ask_body"){
            limit = 6000;
        }
        $(this).qeditor({
            width: $(this).width(),
            limit: limit
        }).hide();
    
    });

    //searchInput输入框提示
    App.placeHolder($("#searchInput"), "搜索求职、职场疑问");
    //个人页 对某人提问相关提示
    var txtATU = $("#new_ask_title_ta");
    var txtABT = $("#new_ask_body_ta");
    if (txtATU.length && txtABT.length){
        var strATU = "对"+$.trim($("#user_name").text())+"提问，请输入问题标题：";
        txtATU.focus(function(){
            if(!App.testLogin()){
                return false;
            }
            $(this).nextAll().css("display", "block");
        }).blur(function(){
            if($.trim(txtATU.val()) == "" || txtATU.val() == strATU){
                $(this).nextAll().css("display", "none");
            }
        });
        txtABT.focus(function(){
            if(!App.testLogin()){
                return false;
            }
            if($.trim(txtATU.val()) == "" || txtATU.val() == strATU){
                setTimeout(function(){
                    txtATU.nextAll().css("display", "none");
                }, 0);
            }
        }).blur(function(){
            if($.trim($(this).val()) == "" || $(this).val() == "问题描述（可选）"){
            }
    });;
        App.placeHolder(txtATU, strATU);
        App.placeHolder(txtABT, "问题描述（可选）");
        App.inputLimit(txtATU, 50);
        App.inputLimit(txtABT, 3000);
        $("#new_ask_submit_ta").bind("click", function(){
            if(!App.testLogin()){
                return false;
            }
            if($.trim(txtATU.val()) == "" || real_length(txtATU.val())>50 || txtATU.val() == strATU){
                return false;
            }
            return true;
        });
    }
    // asks/new 用户提问前检测登录状态
    $("#new_ask").submit(App.testLogin);
    // 用户回答问题字数限制
    var new_answer = $("#new_answer_form .qeditor_preview");
    if (new_answer.length>0){
        new_answer.click(App.testLogin);
        App.inputLimit(new_answer, 5000, "text");
    }
    //登录验证相关处理
    var search = location.search;
    if (!logined){
        // 如果是错误返回   
        if (search.indexOf('error=1') > -1 || search.indexOf('from=') > -1){
            Users.userLogin();
        }
        if (search.indexOf('error=1') > -1){
            search = search.replace("?error=1", "");
            $("#tip_password", $("#facebox")).html("用户名或密码错误").css("color", "red").show();
            $("input[name='password']", $("#facebox")).click(function(){
                $("#tip_password", $("#facebox")).hide();
            });
        }
        // 如果有来路
        if (/from=([^&]+)?/.test(search)){ 
            var bkurl = RegExp["$1"];
            bkurl = (decodeURIComponent)?decodeURIComponent(bkurl):unencode(bkurl);
            $("input[name='bkurl']").val(bkurl);
        } 
    } else {

    }

// 登录和注册、退出按钮的点击事件
$("#login_link").click(Users.userLogin);
    $("#reg_link").click(Users.userReg);
    $("#logout_link").click(Users.userLogout);
    // 问道广场 欢迎页热门话题关注 2012-2-5 by lesanc.li
    var hotTopicTable = $(".newbie .hotTopicTable");
    if (hotTopicTable.length > 0){
        // topics hover event
        (function(){
            var t = window.wendao_topics;
            var p = $("#popTopic");
            var timer = null;
            hotTopicTable.find("li").each(function(i){
                var s = $(this);
                s.mouseenter(function(){
                    clearTimeout(timer);
                    timer = setTimeout(function(){
                        p.find("img.imgHead").attr({
                            "title": t[i][0],
                            "alt": t[i][0],
                            "src": t[i][1]
                        });
                        p.find("a.bold").attr("title", t[i][0]).html(t[i][0]);
                        p.find("div.details").html(t[i][2]);
                        p.find("footer span").html(t[i][3]);
                        p.css({
                            "position": "absolute",
                            "left": s.offset().left,
                            "top": s.offset().top - p.height() - 2
                        }).show();
                        // topics click event
                        var btn = p.find("a.nBtn");
                        if (s.hasClass("selected")){
                            btn.removeClass("nBtnFocus").addClass("nBtnUnFocus");               
                        } else {
                            btn.removeClass("nBtnUnFocus").addClass("nBtnFocus");
                        }
                        btn.unbind("click").click(function(){
                            if(!logined){
                                Users.userLogin();
                                return false;
                            }
                            if (btn.hasClass("nBtnFocus")){
                                Topics.hotFollow(s, t[i][0], btn);     
                            } else {
                                Topics.hotUnfollow(s, t[i][0], btn);
                            }
                        });
                    }, 200);
                }).mouseleave(function(e){
                    clearTimeout(timer);
                    timer = setTimeout(function(){
                        p.hide();
                    }, 20);
                });
            });
            p.mouseenter(function(){
                clearTimeout(timer);
            }).mouseleave(function(){
                p.hide();
            });
        })();
        // topicAll click event
        hotTopicTable.find(".nBtnFocusAll").bind("click",function(){
            if(!logined){
                Users.userLogin();
                return false;
            }
            if ($(this).hasClass("followed")){
                $(this).removeClass("followed");
                Topics.unfollowAll(hotTopicTable);
            } else {
                $(this).addClass("followed");
                Topics.followAll(hotTopicTable);
            }
        });
    }
    // 个人页 鼠标经过个人图像事件
    var userImgEdit = $("figure.avatar .edit");
    $("figure.avatar img").mouseenter(function(){
        userImgEdit.show();
    }).mouseleave(function(e){
        if (e.relatedTarget != userImgEdit[0] && e.relatedTarget != userImgEdit.find("a")[0])
            userImgEdit.hide();
    });
    userImgEdit.mouseleave(function(){
        userImgEdit.hide();
    });
    // 个人页 修改图片
    $(".changeUserHead").click(function(){
    $.facebox({div:'#edit_topic_cover'});
        $("#upload_submit", $("#facebox")).unbind("click").click(function(){
            $("#facebox .simple_form")[0].submit();
        });
    });
    //  图片上传检测
    $("#facebox #user_avatar").live("change", function(){
        checkUploadImg($("#facebox #user_avatar"));
    });
    $("#user_avatar").bind("change", function(){
        checkUploadImg($(this));
    });
    //个人设置页 个人一句话描述输入框提示 2011-11-2 by lesanc.li
    if ($("#user_editing_tagline").length){
        App.placeHolder($("#user_editing_tagline"), "如：工作经历、擅长领域");
        $("#form_1").bind("submit", function(){
            if($("#user_editing_tagline").val() == "如：工作经历、擅长领域"){
                $("#user_editing_tagline").val("");
            }
        });
    }
    // 个人设置页 个性域名输入限制
    if ($("#user_slug").length){
        $("#user_slug").val($("#user_slug").val().replace(/[\. ]/g,"_"));
        $("#user_slug").bind("keydown", function(e){
            e = e || window.event;
            if (e.keyCode == 190 || e.keyCode == 110 || e.keyCode == 32){
                return false;
            }
        }).bind("blur", function(){
            if (/[^a-zA-Z0-9-_]+/.test($(this).val())){
                if ($("#user_slug_err").attr("id")){
                    $("#user_slug_err").html("输入的格式不正确！");
                    $("#user_slug_err").show();
                } else {
                    $(this).after("&nbsp;&nbsp;<span id=\"user_slug_err\" style=\"color:red\">输入的格式不正确！</span>");
                }
            }else if($(this).val().length<4){
                if ($("#user_slug_err").attr("id")){
                    $("#user_slug_err").html("字数过短！");
                    $("#user_slug_err").show();
                } else {
                    $(this).after("&nbsp;&nbsp;<span id=\"user_slug_err\" style=\"color:red\">字数过短！</span>");
                }
            }
            else {
                $("#user_slug_err").hide();
                $("#user_slug_err").html("");
            }
        });
    }
    // 个人设置页 昵称输入限制
    if ($("#user_name").length){
        $("#user_name").val($("#user_name").val().replace(/[\. ]/g,"_"));
        $("#user_name").bind("keydown", function(e){
            e = e || window.event;
            if (e.keyCode == 190 || e.keyCode == 110 || e.keyCode == 32){
                return false;
            }
        }).bind("blur", function(){
            if(real_length($(this).val()+"a")<3){
                if ($("#user_name_err").attr("id")){
                    $("#user_name_err").html("字数过短！");
                    $("#user_name_err").show();
                } else {
                    $(this).after("&nbsp;&nbsp;<span id=\"user_name_err\" style=\"color:red\">字数过短！</span>");
                }
            }
            else {
                $("#user_name_err").hide();
                $("#user_name_err").html("");
            }
        });
    }
    // 所有问题、个人页问题补充描述截断
    Asks.shortDetail();
    // 问题页代码迁移至此 2011-10-14 by lesanc.li
    Asks.completeInviteToAnswer(); 

    // 分享 Email和转发地址
    $(".shareEmail").facebox();
    $(".shareFw").facebox();
    // 问题页 问题添加话题操作
    $("div.topics li.modify").click(function(){
        Asks.toggleEditTopics(true);
    });
    $("div.topics a.complete_topics").click(function(){
        Asks.toggleEditTopics(false);
    });
    $("div.topics ul.modify a.close").live("click", function(){
        Asks.removeTopic($(this), $(this).parent().text());
    });
    // 过滤右侧栏第一个section的外边距
    $('#sidebar section').eq(0).addClass('mt20');
    // 右侧导航
    $('#mainNav li, #userInfoPop li:gt(0)').click(function(){
        window.location.href = $(this).find("a").attr("href");
    }); 
});
