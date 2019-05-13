class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    if current_user
      @profil = User.find(current_user.id)
      @onboarding_step = current_user.onboarding_step
      if @onboarding_step == 1      # Bloc liaison ENEDIS
        redirect_to edit_profil_path(current_user)
      elsif  @onboarding_step == 2  # Formulaire de saisie des infos compélmentaires
        redirect_to edit_profil_path(current_user)
      # elsif @onboarding_step == 3   # Tableau de bord

      end

      @housing = Housing.find(@profil.housing_id)
      # Dernier enregistrement de power associé à ce logement :
      last_power = Power.where(housing_id: @housing.id).last
      # Horodatage du dernier enregistrement :
      @last_power_date = last_power.power_time.beginning_of_day
      # Premier jour du mois évalué :
      @first_power_date = last_power.power_time.beginning_of_month

      # @periode = DataCalc.new(@profil.housing_id).actual_monthly_conso
      month_conso = DataCalc.new(@profil.housing_id).month_conso(@first_power_date, @last_power_date)
      @conso = month_conso[:month_conso] / 100
      @estimated_month_conso = month_conso[:estimated_month_conso] / 100
    end

  end
end
