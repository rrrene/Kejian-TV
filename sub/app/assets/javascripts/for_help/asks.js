var Asks = {
    mute : function(el,id){
        App.loading();
        $.get("/asks/"+id+"/mute",{}, function(res){
            App.loading(false);
            if(!App.requireUser(res,"text")){
                return false;
            }
            // $(el).replaceWith('<span class="muted">不再显示</span>');
            $(el).parent().parent().fadeOut("fast");
        });
        return false;
    },

    unmute : function(el,id){
        App.loading();
        $.get("/asks/"+id+"/unmute",{}, function(res){
            App.loading(false);
            if(!App.requireUser(res,"text")){
                return false;
            }
            // $(el).replaceWith('<span class="muted">不再显示</span>');
            $(el).parent().parent().fadeOut("fast");
        });
        return false;
    },

    simple_follow : function(el,id){
        if(!logined){
          Users.userLogin();
          return false;
        }
        App.loading();
        $.get("/asks/"+id+"/follow",{}, function(res){
            App.loading(false);
            if(!App.requireUser(res,"text")){
                return false;
            }
            $(el).replaceWith('<a onclick="return Asks.simple_unfollow(this,\''+id+'\')" href="#">取消关注</a>'); //20111121 by lesanc.li
        // $(el).parent().parent().fadeOut("slow");
        });
        return false;
    },

    simple_unfollow : function(el,id){
        App.loading();
        $.get("/asks/"+id+"/unfollow",{}, function(res){
            App.loading(false);
            if(!App.requireUser(res,"text")){
                return false;
            }
            $(el).replaceWith('<a onclick="return Asks.simple_follow(this,\'' + id + '\')" href="#">关注</a>'); //modify 2011-9-29 by lesanc.li
        //		$(el).parent().parent().fadeOut("fast");
        });
        return false;
    },

    dropdown_menu : function(el){
        html = '<ul class="menu">';
        if(ask_redirected == true){
            html += '<li><a onclick="return Asks.redirect_ask_cancel(this);" href="#">取消重定向</a></li>';
        }
        else{
            html += '<li><a onclick="return Asks.redirect_ask(this);" href="#">问题重定向</a></li>';
        }
        html += '<li><a onclick="return Asks.report(this);" href="#">举报</a></li>';
        $(el).jDialog({
            title_visiable : false,
            width : 160,
            class_name : "dropdown_menu",
            top_offset : -2,
            content : html
        });
        $(el).attr("droped",1);
        return false;
    },

    redirect_ask : function(el){
        if(!logined){  //add 2011-10-14 by lesanc.li
            Users.userLogin();
            return false;
        }
        jDialog.close();
    $.facebox({ div : "#redirect_ask", overlay : false });
        $(".facebox_window.simple_form input.search").autocomplete("/search/asks",{
            minChars: 1,
            delay: 50,
            width: 456,
            scroll : false,
            addSearch: false
        });
        $(".facebox_window.simple_form input.search").result(function(e,data,formatted){
            if(data){
                $(".facebox_window.simple_form .r_id").val(data[1]);
                $(".facebox_window.simple_form .r_title").val(data[0]);
            }
        });
    },

    redirect_ask_save : function(el){
        App.loading();
        r_id = $(".facebox_window.simple_form .r_id").val();
        r_title = $(".facebox_window.simple_form input.r_title").val();
        if(r_id.length == ""){
            $(".facebox_window.simple_form input.search").focus();
        }
    $.get("/asks/"+ask_id+"/redirect",{ new_id : r_id }, function(res){
            App.loading(false);
            if(res == "1"){
                ask_redirected = true;
                Asks.redirected_tip(r_title,r_id, 'nr', ask_id );
                $.facebox.close();
            }
            else{
                alert("循环重定向，不允许这么关联。");
                return false;
            }
        });
        return false;
    },

    redirect_ask_cancel : function(el){
    $.get("/asks/"+ask_id+"/redirect",{ cancel : 1 });
        Asks.redirected_tip();
        ask_redirected = false;
        jDialog.close();
    },

    redirected_tip : function(title, id, type, rf_id){
        if(title == undefined){
            $("#redirected_tip").remove();
        }
        else{
            label_text = "问题已重定向到: "
            ask_link = "/asks/" + id + "?nr=1&rf=" + rf_id;
            if(type == "rf"){
                label_text = "重定向来自: ";
                ask_link = "/asks/" + id + "?nr=1";
            }
            html = '<div id="redirected_tip"><div class="container notice_message">';
            html += '<label>'+label_text+'</label><a href="'+ask_link+'">'+title+'</a>';
            html += '</div></div>';
            $("#main").before(html);
        }
    },

    /* 问题，话题，人搜索自动完成 */
    completeAll : function(el){
        input = $(el);
        input.autocomplete("/search/all",{
            mincChars: 1,
            delay: 50,
            x: -8,
            y: 10,
            width: 478,
            scroll : false,
            selectFirst : false,
            clickFire : true,
            hideOnNoResult : false,
            noResultHTML : "未找到与“{kw}”相关的内容，请提问或尝试其他关键词",  // modify 2011-10-19 by lesanc.li
            formatItem : function(data, i, total){
                klass = data[data.length - 1];
                switch(klass){
                    case "Ask":
                        return Asks.completeLineAsk(data, true);
                        break;
                    case "Topic":
                        return Asks.completeLineTopic(data, true);
                        break;
                    case "User":
                        return Asks.completeLineUser(data, true);
                        break;
                    case "Total":
                        return Asks.completeLineTotal(data, true);
                        break;
                    default:
                        return "";
                        break;
                }
            }
        }).result(function(e, data, formatted){
            url = "/";
            klass = data[data.length - 1];
            switch(klass){
                case "Ask":
                    url = "/asks/" + data[1];
                    break;
                case "Topic":
                    url = "/topics/" + data[0];
                    break;
                case "User":
                    url = "/users/" + data[6];
                    break;
                case "Total":
                    url = "/traverse/index?q=" + (encodeURIComponent?encodeURIComponent(data[0]):escape(data[0]));
                    break;
            }
            location.href = url;
            return false;
        }).keydown(Asks.keydownToSearch);
    },

    completeTopic : function(el){
        $(el).autocomplete("/search/topics",{
            minChars: 1,
            delay: 50,
            width: 200,
            scroll : false,
            defaultHTML : (el.attr("id")=="searchTopic")?"":"输入文本开始搜索",
            addSearch : (el.attr("id")=="searchTopic")?false:true,
            formatItem : function(data, i, total){
                return Asks.completeLineTopic(data,false);
            }
        });
    },

    completeTopicForAsk : function(el){
        $(el).autocomplete("/search/topics",{
            minChars: 1,
            delay: 50,
            width: 200,
            scroll : false,
            defaultHTML : (el.attr("id")=="searchTopic")?"":"输入文本开始搜索",
            addSearch : (el.attr("id")=="searchTopic")?false:true,
            formatItem : function(data, i, total){
                return Asks.completeLineTopic(data,false);
            }
        }).result(function(e,data,formatted){
            if(data){
                Asks.add_topic_to_new_ask_dialog(data[0]);
            }
        });
    },

    toggleShareAsk : function(el,type){ //modify 2011-11-8 by lesanc.li
        $(el).parents("#share_ask_box").find(".inner .invite").show();
        return false;
    },

    /* 邀请人回答问题 */
    completeInviteToAnswer : function(){
        input = $("#ask_to_answer");
        App.placeHolder(input, "可通过人名、话题、职务等搜索");
        input.autocomplete("/search/users", {
            mincChars: 1,
            x: -5,
            y: 2,
            delay: 50,
            width: 206,
            scroll : false,
            defaultHTML : "输入文本开始搜索",
            noResultHTML : "未找到与“{kw}”相关的人",  // add 2012-07-04 by lesanc.li
            addSearch : false,
            formatItem : function(data, i, total){
                return Asks.completeLineUser(data,false,40);
            }
        });
        input.result(function(e,data,formatted){
            if(data){
                user_id = data[1];
                name = data[0];
                Asks.inviteToAnswer(data[1]);
            }
        });
    },

    /* 取消邀请 */
    cancelInviteToAnswer : function(el, id){
        /*var countp = $(el).parent().find(".count");
    var count = parseInt(countp.text());
    if(count > 1){
      count -= 1
      countp.text(count);
    }
    else{
      $(el).parent().fadeOut().remove();
    }*/
    $.get("/asks/"+ask_id+"/invite_to_answer",{ i_id : id, drop : 1 });
        return false;
    },
  
    inviteToAnswer : function(user_id, is_drop){
        App.loading();
    $.get("/asks/"+ask_id+"/invite_to_answer.js",{ user_id : user_id, drop : is_drop }, function(data){
            /\(\'#shared_span_count\'\).html\(\' \((\d+)\)\' \)/.exec(data);    //add 2011-11-4 by lesanc.li
            if (RegExp["$1"] > 0){
                $("#ask_invited_users").parent().prev("dt").show();
            } else {
                $("#ask_invited_users").parent().prev("dt").hide();
            }
        });
    },

    completeLineTopic : function(data,allow_link){
        var html = "";
        var cover = data[3];
        var count1 = data[1];
        var count2 = data[2];
        if(cover.length > 0){
            html += '<img class="imgHead" width="38" height="38" src="'+ cover +'" alt="'+data[0]+'" title="'+data[0]+'" />';
        }
        if(allow_link == true){
            html += '<a href="/topics/'+data[0]+'">'+ data[0] +'</a>';
        }
        else{
            html += data[0];
        }
        html += ' <span class="fc999">话题</span>';
        html += '<br>';
        html += count1+'个关注者·'+count2+'个问题';
        return html;
    },


    completeLineAsk : function(data, allow_link){
        var html = "";
        var count = data[2];
        if(allow_link == false){
            html += data[0];
        } else {
            html += '<a href="/asks/'+data[1]+'">'+data[0].replace("/","")+'</a>';
        }
        html += '('+count+'个答案)';
        return html;
    },

    completeLineUser : function(data,allow_link,limit){
        var html = "", len, tempStr;
        var avatar = data[3];
        var username = data[0];
        var tagline = data[2];
        var count1 = data[4];
        var count2 = data[5];
        if(/^\/upload/.test(avatar) == false){
            avatar = "" + avatar;
        }
        if (limit && !isNaN(limit)){
            len = username.replace(/[^\u0000-\u00ff]/gi, "aa").length;        
            if (len > limit){
                username = App.shortStr(username, limit - 3) + "...";
                tagline = "";
            } else if (len < limit && tagline.replace(/[^\u0000-\u00ff]/gi, "aa").length > limit - len -1){
                tagline = App.shortStr(tagline, limit - len - 3) + "...";
            } else if (len === limit){      
                tagline = "";
            }
        }
        html += '<img class="imgHead" width="38" height="38" src="'+ avatar +'" alt="'+data[0]+'" title="'+data[0]+'" />';
        if(allow_link == true){
            html += '<a href="/users/'+data[7]+'">'+username+'</a>';
        }else{
            html += username;
        }     
        html += ' <span class="fc999">'+tagline+'</span>';
        html += '<br>';
        html += count1+'个关注者·答过'+count2+'个问题';
        return html;
    },

    completeLineTotal : function(data,allow_link, el){
        var href = "";
        if(allow_link == true){
            href = '/traverse/index?q='+(encodeURIComponent?encodeURIComponent(data[0]):escape(data[0]));
            return '所有搜索结果：<a href="'+href+'"><mark>'+data[0]+'</mark>';
        }else{
            return '所有搜索结果：<mark>'+data[0]+'</mark>';
        }
    },

    keydownToSearch : function(e){
        var a;
        if (e.keyCode === 13){
            a = $(".ac_results a[href^='/traverse/index']");
            if (a.length){
                window.location = a[0].href;
                return false;
            }
        }        
    },

    beforeSubmitComment : function(el){
        App.loading();
    },

    thankAnswer : function(el,id){
        if(!logined){  //add 2011-10-14 by lesanc.li
            Users.userLogin();
            return false;
        }
        klasses = $(el).attr("class");
        if(klasses.indexOf("thanked") > 0){
            return false;
        }
        $(el).addClass("thanked");
        $(el).text("已感谢");
    $(el).click(function(){ return false });
        $.get("/answers/"+id+"/thank");
        return false;
    },

    spamAsk : function(el, id){
        if(!logined){  //add 2011-10-14 by lesanc.li
            Users.userLogin();
            return false;
        }
        if(!confirm("多人评价为烂问题后，此问题将会被屏蔽，而且无法撤销！\n你确定要这么评价吗？")){
            return false;
        }

        App.loading();
        $(el).replaceWith("烂问题");
        $.get("/asks/"+id+"/spam",function(count){
            if(!App.requireUser(count,"text")){
                return false;
            }
            $("#spams_count").text(count);
            App.loading(false);
        });
        return false;
    },

    beforeAnswer : function(el){
        $("button.submit",el).attr("disabled","disabled");
        App.loading();
    },

    spamAnswer : function(el, id){
        if(!logined){  //add 2011-10-14 by lesanc.li
            Users.userLogin();
            return false;
        }
        App.loading();
        $(el).replaceWith("已提交");
        $.get("/answers/"+id+"/spam",function(count){
            if(!App.requireUser(count,"text")){
                return false;
            }
            App.loading(false);
        });
        return false;
    },

    toggleEditTopics : function(isShow){
        var topics = $("div.topics");
        var t1 = topics.find(".topicNav").eq(0);
        var t2 = topics.find(".topicNav.modify");
        var a = topics.find(".addTopic");
        if(isShow){
            t2.show();
            a.show();
            t1.hide();
            App.placeHolder(a.find("input"),"输入话题");
        }
        else{
            t1.show();
            t2.hide();
            a.hide();  
        }
    },

    beforeAddTopic : function(el){
        App.loading();
    },
    // modify 2012-2-6 by lesanc.li
    addTopic : function(name){
        App.loading(false);
        if((name.trim && name.trim() == "") || typeof name == "undefined" || name == ""){
            return false;
        }
        var m = $(".topics .topicNav li.modify:last");
        m.prev("li.modify").remove();
        m.before("<li><a href='/topics/"+name+"' title='"+name+"'>"+name+"</a></li>");
        $(".topics .topicNav.modify").append("<li>"+name+"<a class=\"close\" href='javascript:void(0);' title='"+name+"'></a></li>");
    },
    // modify 2012-2-6 by lesanc.li
    removeTopic : function(el, name){
        App.loading();
    $.get("/asks/"+ask_id+"/update_topic", { name : name }, function(res){
            $(el).parent().remove();
            $(".topics .topicNav li").each(function(){
	      if($(this).text() == name){$(this).remove();} 
            });
            App.loading(false);
        });
        return false;
    },

    follow : function(el){
        if(!logined){  //add 2011-11-8 by lesanc.li
            Users.userLogin();
            return false;
        }
        App.loading();
        $(el).attr("onclick", "return false;");
        $.get("/asks/"+ask_id+"/follow",{}, function(res){
            App.loading(false);
            $(el).replaceWith('<a class="bBtn bBtnUnFocus" onclick="return Asks.unfollow(this);"></a>');
        });
        return false;
    },

    unfollow : function(el){
        if(!logined){
            Users.userLogin();
            return false;
        }
        App.loading();
        $(el).attr("onclick", "return false;");
        $.get("/asks/"+ask_id+"/unfollow",{}, function(res){
            App.loading(false);
            $(el).replaceWith('<a class="bBtn bBtnFocus" onclick="return Asks.follow(this);"></a>');
        });
        return false;
    },

    toggleComments : function(type, id){
        if(!logined){
            Users.userLogin();
            return false;
        }
        if (type === "ask"){
          var el = $("#"+type+"_"+id);
        } else {
          var el = $("#"+type+"_"+id+" .replys");
        }
        var comments = $(".comments",el);
        if (comments.length > 0){
            comments.toggle();
        } else {
            App.loading();
            $.ajax({url:"/comments",data:{ type : type, id : id }, success:function(html){
                    el.append(html);
                    App.loading(false);
            }, dataType:"text"});
        }
        return false;
    },

    commentSubmit : function(el){
        if(!logined){
            Users.userLogin();
            return false;
        }   
        if ($("textarea", $("#"+el)).val()){
            App.loading();
            $("#"+el).trigger("submit");
        }
        return false;
    },

    answerSubmit : function(){
        if(!App.testLogin()){
            return false;
        }
        var el = $("#new_answer_form");
        if ($("textarea", $(el)).val()){
            App.loading();
            $(el).trigger("submit");
        }
        return false;
    },

    tohimSubmit : function(){
        if(!App.testLogin()){
            return false;
        }
        if(real_length($("#new_ask_title_ta").val())>50){
            return false;
        }
        var el = $("#tohim");
        if ($("textarea", $(el)).val()){
            App.loading();
            $(el).trigger("submit");
        }
        return false;
    },
  
    vote : function(id, type){
        if(!App.testLogin()){
            return false;
        }
        var answer = $("#answer_"+id);
        var vtype = "down";
        if(type == 1) {
            vtype = "up";
            $(".vote.voteUp",answer).addClass("voteUpe").css("background-position", "-384px 0");
            $(".vote.voteDown",answer).removeClass("voteDowne").css("background-position", "-288px -24px;");
        } else {
            $(".vote.voteUp",answer).removeClass("voteUpe").css("background-position", "-288px 0");
            $(".vote.voteDown",answer).addClass("voteDowne").css("background-position", "-384px -24px;");
        }
        App.loading();
        $.get("/answers/"+id+"/vote",{ inc : type, t : +new Date() },function(res){
            if(!App.requireUser(res,"text")){
                return false;
            }
            res_a = res.split("|");
            Asks.vote_callback(id, vtype, res_a[0], res_a[1],res_a[2]);
            App.loading(false);
        });
        return false;
    },

    vote_callback : function(id, vtype, new_up_count, new_down_count,new_who){
        var answer = $("#answer_"+id);
        var answer_header = $(".replys header",answer);
        var num = $(".votes_num",answer);
        var votes = $(".voters",answer_header);
        answer.attr("data-uc", new_up_count);
        answer.attr("data-dc", new_down_count);

        // Change value for visable label
        if(votes.length > 0){
            if(new_up_count <= 0){
                // remove up vote count label if up_votes_count is zero
                $(".num",answer_header).remove();
            }else{
                votes.replaceWith(new_who);
            }
        } else {
            if(vtype == "up"){
                answer_header.append("<span class=\"num\">投票者:"+new_who+"</span>");
            }
        }
        num.text(new_up_count);

        var answers = $(".reply");
        var position_changed = false;

        for(var i =0;i<answers.length;i++){
            a = answers[i];
            // Skip current voted Answer self
            if($(a).attr("id") == answer.attr("id")){
                continue;
            }
            // Get next Answer uc and dc
            u_count = parseInt($(a).attr("data-uc"));
            d_count = parseInt($(a).attr("data-dc"));

            // Change the Ask position
            if(vtype == "up"){
                if(new_up_count > u_count){
                    //$(a).before(answer);
                    position_changed = true;
                    break;
                }
            }
            else{
                // down vote
                if(new_up_count <= u_count && new_down_count < d_count){
                    //$(a).after(answer);
                    position_changed = true;
                    break;
                }
            }
        }
        answer.fadeOut(100).fadeIn(200);
    },

    report : function(){
        if(!logined){
            Users.userLogin();
            return false;
        }
    $.facebox({ div : "#report_page", overlay : false });
        $("#report_submit", $("#facebox")).click(function(){
            $("#report_page_form", $("#facebox")).submit();
        });
        jDialog.close();
        return false;
    },

    showSuggestTopics : function(topics){
        html = '<div id="ask_suggest_topics" class="ask"><div class="container"><label>根据您的问题，我们推荐这些话题(点击添加):</label>';
        for(var i=0;i<topics.length;i++) {
            html += '<a href="#" class="topic nofloat" onclick="return Asks.addSuggestTopic(this,\''+topics[i]+'\');">'+topics[i]+'</a>';
        }
        html += '<a class="silver_button silver_button_small" href="#" onclick="return Asks.closeSuggestTopics();">完成</a>'; //modify 2011-9-29 by lesanc.li
        html += "</div></div>";
        html='';// ticket 509
        $("#main").before(html);
    },

    addSuggestTopic : function(el,name){
        App.loading();
        $.ajax({
            //url : "/asks/"+ask_id+"/update_topic.js?"+ csrf.key + "=" + csrf.value,
            url : "/asks/"+ask_id+"/update_topic.js",  //add 2011-9-26 by lesanc.li
            data : {
                name : name,
                add : 1
            },
            dataType : "text",
            type : "post",
            success : function(res){
                App.loading(false);
                Asks.addTopic(name); 
                $(el).remove();
                if($("#ask_suggest_topics a.topic").length == 0){
                    $("#ask_suggest_topics").remove();
                }
            }
        });
        return false;
    },
  
    closeSuggestTopics : function(){
    $("#ask_suggest_topics").fadeOut("fast",function(){ $(this).remove(); });
        return false;
    },

    shortDetail : function(){
        $(".ask[class='ask']>.md_body").each(function(){
            var mdHtml = $(this).html();
            var mdText = $.trim($(this).text());
            if(mdText.length > 270){
                var mdSpan = $(document.createElement("span"));
                $(this).html(mdSpan.html(mdText.substring(0,270)+"。。。 "));
                var mdLink = $(document.createElement("a"));
        mdLink.text("展开").attr("href","#").css({"background":"","padding":"0"}).appendTo($(this));
                mdLink.toggle(function(){
                    mdSpan.html(mdHtml);
                    mdLink.text("收起");
                },function(){
                    mdSpan.html(mdText.substring(0,270)+"。。。 ");
                    mdLink.text("展开")
                });
            }
        });
    },
    // Modified by P.S.V.R
    // 2011.2.14
    add_topic_to_new_ask_dialog: function(topic){
        var topics = $("#inner_new_ask input[name=\"topics\"]", $("#facebox"));
        var exist = false;
        var topicList = $("#facebox .topicNav.modify");
        $("li", topicList).each(function(){
            if ($.trim($(this).text()) == topic){
                exist = true;
                return false;
            }
        });
        if (!exist){
            topicList.append('<li>'+topic+'<a class="close_topic" href="javascript:void(0);" title="删除本话题标签"></a></li>');
            topics.val(topics.val()==""?topic:(topics.val()+","+topic));
            return true;
        }else{
            return false;
        }
    },
    /* 添加问题 */
    addAsk: function(){
        if(!logined){
            Users.userLogin();
            return false;
        }
        //var txtTitle = $("#hidden_new_ask textarea:nth-of-type(1)");
        var txtTitle = $("#hidden_new_ask textarea").eq(0);
        ask_search_text = $("#searchInput").val() != "搜索求职、职场疑问" ? $("#searchInput").val() : "";
        txtTitle.text(ask_search_text);
        txtTitle.focus();
    $.facebox({ div : "#hidden_new_ask", overlay : false });  
        var facebox = $("#facebox");
        var title = $("#inner_new_ask textarea[name=\"ask\[title\]\"]", facebox);
        var body = $("#inner_new_ask textarea[name=\"ask\[body\]\"]", facebox);
        var topic = $("#inner_new_ask input[name=\"topic\"]", facebox);
        var topics = $("#inner_new_ask input[name=\"topics\"]", facebox);
        App.placeHolder(title, "问题标题");
        App.placeHolder(body, "问题描述（可选）");
        App.placeHolder(topic, "输入话题");
        App.inputLimit(title, 50);
        App.inputLimit(body, 3000);
        App.inputLimit(topic, 10,"val","no");
        topic.attr("maxlength","20");
        Asks.completeTopicForAsk(topic);
        title.blur(function(){
            if ($.trim($(this).val()) !== "" && $.trim($(this).val()) !== "问题标题"){
                $("#theAddTopic", facebox).show();
            }
        });

        //add topic
        // Modified by P.S.V.R
        // 2011.2.14
        var modify_btn = $("a.edit_topic", facebox);
        $(".add_topic", facebox).unbind("click").click(function(){
            if (!$.trim(topic.val()) || real_length(topic.val())>10){
                return false;
            }
            var t = $.trim(topic.val());
            if(t && t!=="输入话题" && Asks.add_topic_to_new_ask_dialog(t)){
                topic.val('');
            }
            return false;
        });
        //remove topic
        $(".topicNav.modify li a.close_topic", facebox).live("click", function(){
            var topicv = $.trim($(this).parent().text());
            if(topics.val().indexOf(topicv+',') == 0){
                topics.val(topics.val().replace(topicv+',', ''));
            } else if(topics.val().indexOf(','+topicv)>-1){
                topics.val(topics.val().replace(','+topicv, ''));
            } else if(topics.val() == topicv){
                topics.val('');
            }
            $(this).parent().remove();
        });
        // submit
        $(".submit", facebox).unbind("click").click(function(){
            if(title.val() === "" || title.val() === "问题标题"){
				setTimeout(function(){title.css({"border-color":"#f8d97c","background":"#ffffe1"});}, 0);
				setTimeout(function(){title.css({"border-color":"#d9edce","background":"#ffffff"});}, 200);
				setTimeout(function(){title.css({"border-color":"#f8d97c","background":"#ffffe1"});}, 400);
				setTimeout(function(){title.css({"border-color":"#d9edce","background":"#ffffff"});}, 600);
				setTimeout(function(){title.css({"border-color":"#f8d97c","background":"#ffffe1"});}, 800);
				setTimeout(function(){title.css({"border-color":"#d9edce","background":"#ffffff"});}, 1000);
                return false;
            }
			if (body.val() === "问题描述（可选）"){
				body.val('');
			}
            if (real_length(title.val())>50 || real_length(body.val())>3000){
                // if (title.val().length>100 || body.val().length>6000){
                return false;
            }
            $("form", facebox)[0].submit();
        });
        return false;
    },

    version : function(){
    }
}

function CallbackPosition(data, page){
    var chkes = document.getElementById('chkEmailScript');
    if (chkes){
        document.getElementsByTagName('head')[0].removeChild(chkes);
    }
    var chks = document.createElement('script');
    chks.id = 'chkEmailScript';
    chks.type = 'text/javascript';
    var head = document.getElementsByTagName('head')[0];
    if (head.getElementsByTagName('script').length>0){
        head.insertBefore(chks, head.getElementsByTagName('script')[0]);
    } else {
        head.appendChild(chks);
    }
    chks.onload = chks.onreadystatechange = function(){
        if (typeof cefmarkhome != 'undefined'){
            if (cefmarkhome == 1){
                writeFileErrMsg('该邮箱已被注册，请<a onclick="Users.userLogin()" href="#">直接登录</a>');
            } else if (cefmarkhome == 9){
                writeFileErrMsg("");
            } else if (cefmarkhome == 0){
                writeFileErrMsg("");
            }
        }
    }
    chks.src = page + '&' + data;
}

function judgeEmail(sValue) {
    if (sValue == "") {
        writeFileErrMsg("请输入您的电子邮件地址");
        return false;
    }
    var CheckEmail = isemail_b(sValue);
    if (CheckEmail.length > 0) {
        writeFileErrMsg(CheckEmail);
        return false;
    }
    writeFileErrMsg("");
    return true;
}

//检查Email是否存在
function checkEmail(strEmail) {
    var d = new Date();
    var url = "http://my.zhaopin.com/myzhaopin/CEF_markhome.asp?timestamp=" + d.getTime();
    var query = "opt=1&email=" + strEmail;
    CallbackPosition(query, url)
}
function writeFileErrMsg(strMessage){
    $("#facebox .user_email_err").html(" "+strMessage).css("color", "red");
}

function isemail_b(s) {
    // Writen by david, we can delete the before code
    if (s.length > 100) {
        //window.alert("email地址长度不能超过100位!");
        return "email地址长度不能超过100位!";
    }
    s = s.toLowerCase();
    var strSuffix = "cc|com|edu|gov|int|net|org|biz|info|pro|name|coop|al|dz|af|ar|ae|aw|om|az|eg|et|ie|ee|ad|ao|ai|ag|at|au|mo|bb|pg|bs|pk|py|ps|bh|pa|br|by|bm|bg|mp|bj|be|is|pr|ba|pl|bo|bz|bw|bt|bf|bi|bv|kp|gq|dk|de|tl|tp|tg|dm|do|ru|ec|er|fr|fo|pf|gf|tf|va|ph|fj|fi|cv|fk|gm|cg|cd|co|cr|gg|gd|gl|ge|cu|gp|gu|gy|kz|ht|kr|nl|an|hm|hn|ki|dj|kg|gn|gw|ca|gh|ga|kh|cz|zw|cm|qa|ky|km|ci|kw|cc|hr|ke|ck|lv|ls|la|lb|lt|lr|ly|li|re|lu|rw|ro|mg|im|mv|mt|mw|my|ml|mk|mh|mq|yt|mu|mr|us|um|as|vi|mn|ms|bd|pe|fm|mm|md|ma|mc|mz|mx|nr|np|ni|ne|ng|nu|no|nf|na|za|aq|gs|eu|pw|pn|pt|jp|se|ch|sv|ws|yu|sl|sn|cy|sc|sa|cx|st|sh|kn|lc|sm|pm|vc|lk|sk|si|sj|sz|sd|sr|sb|so|tj|tw|th|tz|to|tc|tt|tn|tv|tr|tm|tk|wf|vu|gt|ve|bn|ug|ua|uy|uz|es|eh|gr|hk|sg|nc|nz|hu|sy|jm|am|ac|ye|iq|ir|il|it|in|id|uk|vg|io|jo|vn|zm|je|td|gi|cl|cf|cn"
    var regu = "^[a-z0-9][_a-z0-9\-]*([\.][_a-z0-9\-]+)*@([a-z0-9\-\_]+[\.])+(" + strSuffix + ")$";
    var re = new RegExp(regu);
    if (s.search(re) != -1) {
        return "";
    } else {
        return "请输入有效的E-mail地址 ！";
    }
}

function trim(str) {
    regExp1 = /^ */;
    regExp2 = / *$/;
    return str.replace(regExp1, '').replace(regExp2, '');
}

// 搜索页 更多显示 add 2011-10-17 by lesanc.li
function loadResults(el, q, curpage){
    App.loading();
    $.get("/traverse/asks_from?q="+((encodeURIComponent)?encodeURIComponent(q):q)+"&current_key="+curpage,function(data){
        $(el).parent().before(data).remove();
        App.loading(false);
    });
    return false;
}

//图片大小检测 add 2011-11-1 by lesanc.li
function checkUploadImg(fileObj){
    var hint = fileObj.next("p.hint");
    if (!hint.length) hint = fileObj.parent().next("p.hint");
    hint.html("支持jpg, gif, png 格式的图片，不要超过2MB。建议图片尺寸大于100 X 100。");
    $("button[type='submit']").unbind("click");
    if (fileObj.val() == ""){
        return false;
    } else if(!(/(?:.jpeg|.png|.gif|.jpg)$/.test(fileObj.val()))){
        hint.html(hint.html().replace("支持jpg, gif, png 格式的图片","<span style=\"color:red\">支持jpg, gif, png 格式的图片</span>"));
    $("button[type='submit']").click(function(){return false;});
    } else if(fileObj.val().indexOf(":")>-1){
        var uploadImg = $("#uploadImg");
        if(!uploadImg.attr("src")){
            uploadImg = document.createElement("img");
            uploadImg = $(uploadImg);
      uploadImg.css({"position":"absolute", "visibility":"hidden"}).bind("readystatechange", function(){
                if(uploadImg[0].readyState!= "complete") return false;
                imgSize = uploadImg[0].fileSize;
                if (imgSize > 2048000){
                    hint.html(hint.html().replace("不要超过2MB","<span style=\"color:red\">不要超过2MB</span>"));
          $("button[type='submit']").click(function(){return false;});
                }
            }).appendTo($("body"));
        }
        uploadImg.attr("src", fileObj.val());
    } else {
        var imgSize = (fileObj[0].files)?fileObj[0].files.item(0).fileSize:0;
        if (imgSize > 2048000){
            hint.html(hint.html().replace("不要超过2MB","<span style=\"color:red\">不要超过2MB</span>"));
      $("button[type='submit']").click(function(){return false;});
        }
    }
}