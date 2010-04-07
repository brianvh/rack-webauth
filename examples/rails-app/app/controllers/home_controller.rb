class HomeController < ApplicationController

  def index
    render :inline => "<%=h session.inspect %>"
  end

end
