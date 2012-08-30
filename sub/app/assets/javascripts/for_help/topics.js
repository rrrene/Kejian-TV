var Topics = {
  editCover : function(el){
    $(el).hover(function(){
      $(".edit",$(this)).show();
    }, function(){
      $(".edit",$(this)).hide();
    });
    $(".edit a",$(el)).click(function(el){
        $.facebox({ div : "#edit_topic_cover" });
        return false;
    });
  },

  follow : function(el, id, small){
    if(!logined){
      Users.userLogin();
      return false;
    }
    App.loading();
    var uid=(encodeURIComponent)?encodeURIComponent(id):id; 
    $.get("/topics/"+uid+"/follow",{}, function(res){
        $(el).replaceWith('<a onclick="return Topics.unfollow(this, \''+ id +'\',\''+ small +'\');" class="'+(small == 'small'?'nBtn nBtnUnFocus':'bBtn bBtnUnFocus')+'" href="javasrcipt:void(0);"></a>');
        App.loading(false);
    });
    return false;
  },
		
  unfollow : function(el, id, small){
    if(!logined){
      Users.userLogin();
      return false;
    }
    App.loading();
    var uid=(encodeURIComponent)?encodeURIComponent(id):id; 
    $.get("/topics/"+uid+"/unfollow",{}, function(res){
        $(el).replaceWith('<a onclick="return Topics.follow(this, \''+ id +'\',\''+ small +'\');" class="'+(small == 'small'?'nBtn nBtnFocus':'bBtn bBtnFocus')+'" href="javasrcipt:void(0);"></a>');
        App.loading(false);
    });
    return false;
  },

  simple_follow : function(el,id){
  App.loading();
  $.get("/topics/"+id+"/follow",{}, function(res){
      App.loading(false);
      if(!App.requireUser(res,"text")){
        return false;
      }
      $(el).replaceWith('<a onclick="return Topics.simple_unfollow(this,\''+id+'\')" href="#">取消关注</a>');
  });
  return false;
},

simple_unfollow : function(el,id){
  App.loading();
  $.get("/topics/"+id+"/unfollow",{}, function(res){
      App.loading(false);
      if(!App.requireUser(res,"text")){
        return false;
      }
   $(el).replaceWith('<a onclick="return Topics.simple_follow(this,\'' + id + '\')" href="#">关注</a>'); 
  });
  return false;
},

  //modify 2012-2-6 by lesanc.li	
  hotFollow : function(el, id, btn){
    App.loading();
    var uid=(encodeURIComponent)?encodeURIComponent(id):id; 
    $.get("/topics/"+uid+"/follow",{}, function(res){
        el.addClass("selected");
        if(btn){btn.removeClass("nBtnFocus").addClass("nBtnUnFocus")};
        App.loading(false);
    });
    return false;
  },
	//modify 2012-2-6 by lesanc.li	
  hotUnfollow : function(el, id, btn){
    App.loading();    
    var uid=(encodeURIComponent)?encodeURIComponent(id):id;
    $.get("/topics/"+uid+"/unfollow",{}, function(res){
        el.removeClass("selected");
        if(btn){btn.removeClass("nBtnUnFocus").addClass("nBtnFocus")};
        App.loading(false);
    });
    return false;
  },
  //modify 2012-2-6 by lesanc.li	
  followAll : function(el){
    var data = [];
    $("ul li",el).each(function(){
      data.push($(this).find("a").text());
      $(this).addClass("selected");
    });
    $.post("/topics_follow",{q:data.join(",")}, function(res){  
    });
  },
	//modify 2012-2-6 by lesanc.li
  unfollowAll : function(el){
    var data = [];
    $("ul li",el).each(function(){ 
      data.push($(this).find("a").text());
      $(this).removeClass("selected");
    });
    $.post("/topics_unfollow",{q:data.join(",")}, function(res){
    });
  },
  
  version : function(){}
}
