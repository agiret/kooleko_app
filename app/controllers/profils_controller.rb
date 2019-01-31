class ProfilsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profil, :set_onboarding_step, only: [:show, :edit, :update]

  def edit
    @enedis_client_id = ENV['ENEDIS_CLIENT_ID']
    @enedis_client_secret = ENV['ENEDIS_CLIENT_SECRET']
  end

  def update
  end

  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def set_profil
    @profil = User.find(params[:id])
  end
  def set_onboarding_step
    @onboarding_step = current_user.onboarding_step
  end
end
