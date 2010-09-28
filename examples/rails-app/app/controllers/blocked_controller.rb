class BlockedController < ApplicationController
  before_filter :login_required
  
  def index
    @user = webauth_user.name
  end

end
