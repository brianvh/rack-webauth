class BlockedController < ApplicationController
  before_filter :login_required
  
  def index
    render :text => "Welcome #{webauth_user.name}."
  end

end
