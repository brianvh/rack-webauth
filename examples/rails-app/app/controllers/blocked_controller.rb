class BlockedController < ApplicationController
  before_filter :login_required
  
  def index
    render :inline => "<%=h session[:webauth].inspect %>"
  end

end
