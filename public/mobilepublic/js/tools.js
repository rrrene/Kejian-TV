function replyVote(id,type) {
	$.ajax({
		url: "/answers/"+id+"/vote",
		data: { inc : type },
		cache: false,
		success: function(result){
			if (result === '_nologin_') {
				$.mobile.changePage('/mobile/login');
			}
            var n1 = result.split('|')[0];
            $('.voteNo').html(n1);
            alert('\u6295\u7968\u6210\u529f');
            /*
			// 投票成功
			var n1 = result.split('|')[0], // 返回的赞成票数
				n2 = result.split('|')[1]; // 返回的反对票数
				
			$('#voteBtnA').find('em').html(n1);
			$('#voteBtnB').find('em').html(n2);
            */
		}
	});
	
}