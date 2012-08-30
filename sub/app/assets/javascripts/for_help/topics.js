var Topics = {
  editCover : function(el){
    jQuery(el).hover(function(){
      jQuery(".edit",jQuery(this)).show();
    }, function(){
      jQuery(".edit",jQuery(this)).hide();
    });
    jQuery(".edit a",jQuery(el)).click(function(el){
        jQuery.facebox({ div : "#edit_topic_cover" });
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
    jQuery.get("/topics/"+uid+"/follow",{}, function(res){
        jQuery(el).replaceWith('<a onclick="return Topics.unfollow(this, \''+ id +'\',\''+ small +'\');" class="'+(small == 'small'?'nBtn nBtnUnFocus':'bBtn bBtnUnFocus')+'" href="javasrcipt:void(0);"></a>');
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
    jQuery.get("/topics/"+uid+"/unfollow",{}, function(res){
        jQuery(el).replaceWith('<a onclick="return Topics.follow(this, \''+ id +'\',\''+ small +'\');" class="'+(small == 'small'?'nBtn nBtnFocus':'bBtn bBtnFocus')+'" href="javasrcipt:void(0);"></a>');
        App.loading(false);
    });
    return false;
  },

  simple_follow : function(el,id){
  App.loading();
  jQuery.get("/topics/"+id+"/follow",{}, function(res){
      App.loading(false);
      if(!App.requireUser(res,"text")){
        return false;
      }
      jQuery(el).replaceWith('<a onclick="return Topics.simple_unfollow(this,\''+id+'\')" href="#">取消关注</a>');
  });
  return false;
},

simple_unfollow : function(el,id){
  App.loading();
  jQuery.get("/topics/"+id+"/unfollow",{}, function(res){
      App.loading(false);
      if(!App.requireUser(res,"text")){
        return false;
      }
   jQuery(el).replaceWith('<a onclick="return Topics.simple_follow(this,\'' + id + '\')" href="#">关注</a>'); 
  });
  return false;
},

  //modify 2012-2-6 by lesanc.li	
  hotFollow : function(el, id, btn){
    App.loading();
    var uid=(encodeURIComponent)?encodeURIComponent(id):id; 
    jQuery.get("/topics/"+uid+"/follow",{}, function(res){
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
    jQuery.get("/topics/"+uid+"/unfollow",{}, function(res){
        el.removeClass("selected");
        if(btn){btn.removeClass("nBtnUnFocus").addClass("nBtnFocus")};
        App.loading(false);
    });
    return false;
  },
  //modify 2012-2-6 by lesanc.li	
  followAll : function(el){
    var data = [];
    jQuery("ul li",el).each(function(){
      data.push(jQuery(this).find("a").text());
      jQuery(this).addClass("selected");
    });
    jQuery.post("/topics_follow",{q:data.join(",")}, function(res){  
    });
  },
	//modify 2012-2-6 by lesanc.li
  unfollowAll : function(el){
    var data = [];
    jQuery("ul li",el).each(function(){ 
      data.push(jQuery(this).find("a").text());
      jQuery(this).removeClass("selected");
    });
    jQuery.post("/topics_unfollow",{q:data.join(",")}, function(res){
    });
  },
  
  version : function(){}
}
