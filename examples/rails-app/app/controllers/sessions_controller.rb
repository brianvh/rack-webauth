class SessionsController < ApplicationController

  def new
  end

  def create
    login!
  end

  def destroy
    logout!
  end

end
