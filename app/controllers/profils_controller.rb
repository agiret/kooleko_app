class ProfilsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profil, only: [:show, :edit, :update]

  def edit
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
end
