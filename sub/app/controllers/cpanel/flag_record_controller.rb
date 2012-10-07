class Cpanel::FlagRecordController < ApplicationController
 
  def index
      @frs = FlagRecord.all.desc('created_at')
      @frs = @frs.paginate(:page =>params[:page], :per_page => 10)
  end
  
end
