class ProfilsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profil, :set_onboarding_step, only: [:show, :edit, :update, :validation, :settings]

  def edit
    @enedis_client_id = ENV['ENEDIS_CLIENT_ID']
    @enedis_client_secret = ENV['ENEDIS_CLIENT_SECRET']
    if @onboarding_step >= 2
      @housing = Housing.find(@profil.housing_id)
    end
  end

  def update
    @housing = Housing.find(@profil.housing_id)
    if @profil.update(profil_params)
      # confirm_profil
      # Adaptation du flux si user est encore en mode onboarding :
      if @onboarding_step == 2
        # Redirection vers suite onboarding : données logement
        redirect_to edit_housing_path(@housing.id)#, notice: 'Profil enregistré.'
      elsif @onboarding_step == 3
        # Redirection vers le show du profil
        redirect_to profil_path(@profil.id)
      end
    else
      render :edit
    end
  end

  def show

  end
  def validation

  end
  def settings

  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_profil
    @profil = User.find(params[:id])
  end
  def set_onboarding_step
    @onboarding_step = current_user.onboarding_step
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def profil_params
    params.require(:user).permit(:firstname, :lastname, :phone)
  end

  # def confirm_profil
  #   if (!profil_params[:id_card].nil? || @profil.id_card?) && (!profil_params[:tax_notice].nil? || @profil.tax_notice?) && (!profil_params[:payslip].nil? || @profil.payslip?)
  #     @profil.update(profil_confirmed: true)
  #   else
  #     @profil.update(profil_confirmed: false)
  #   end
  # end
end
