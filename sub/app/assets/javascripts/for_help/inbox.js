var Inbox = {
  newMessage : function(){
    jQuery.facebox({ ajax : "/inbox/new", overlay : false });
    return false;
  },

  version : function() {}
}
