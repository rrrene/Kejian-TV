$(document).ready( -> 
    $('.submit_btns').click((event) ->
      $('#'+this.id+'_form').submit()
      $(this).addClass('btn_going_in')
      $(this).text('提交中，请稍候')
      $(this).unbind('click')
      return false;
    )
)
