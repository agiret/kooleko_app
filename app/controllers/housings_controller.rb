class HousingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @housings = current_user.housings
  end
end
