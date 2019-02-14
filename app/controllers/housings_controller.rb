class HousingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profil, :set_housing, only: [:edit, :update]

  def index
    @housings = current_user.housings
  end
  def create
    @housing = Housing.new(housing_params)
    # @housing.enedis_usage_point_id = params[:enedis_usage_point_id]

    if @housing.save
      current_user.update(housing_id: @housing.id)
      redirect_to edit_profil_path(current_user)
    else
      puts "Problem : Housing not save"
    end
  end
  def edit

  end
  def update
    redirect_to validation_profil_path(current_user)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def set_housing
    @housing = Housing.find(params[:id])
  end
  def set_profil
    @profil = User.find(current_user.id)
  end

  def housing_params
    params.permit(:enedis_usage_point_id)
  end
end
