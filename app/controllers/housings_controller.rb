class HousingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @housings = current_user.housings
  end
  def create
    @housing = Housing.new(housing_params)
    # @housing.enedis_usage_point_id = params[:enedis_usage_point_id]

    if @housing.save
      current_user.update(housing_id: @housing)
      redirect_to edit_profil_path(current_user)
    else
      puts "Problem : Housing not save"
    end
  end

  private

  def housing_params
    params.permit(:enedis_usage_point_id)
  end
end
