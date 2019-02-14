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
    end
  end
end
