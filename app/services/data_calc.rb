class DataCalc

  # Objectif = pouvoir apeler les fonctions de manipulation de data
  # exemple :
  # Data.new(housing_id).actual_monthly_conso
  # return --> "22 € / 43 €"


  def initialize(housing_id)
    @housing = Housing.find(housing_id)

    # Hypothèses simplifiées : tarifs en centimes d'euros
    @kwh_elec_hp_price = 14
    @kwh_elec_hc_price = 12
    @kwh_elec_st_price = 13
    @elec_annual_abo = 10000
  end

  def month_conso(start_date, end_date)
    # Conso entre le dernier enregistrement (end_date) et le 1er du mois (start_date) :
    powers = Power.where(housing_id: @housing.id).where("power_time >= :start_day AND power_time <= :end_day",{start_day: start_date, end_day: end_date + 1.days})
    powers_hc = []
    powers_hp = []
    powers_st = []

    powers.each do |power|
      powers_hc << power.power if power.tariff_option == "HC"
      powers_hp << power.power if power.tariff_option == "HP"
      powers_st << power.power if power.tariff_option == "ST"
    end

    # Consos en kWh associées (E = P * tps) avec relevés toutes les 30 min :
    kwh_conso_hc = powers_hc.sum * 0.5 / 1000
    kwh_conso_hp = powers_hp.sum * 0.5 / 1000
    kwh_conso_st = powers_st.sum * 0.5 / 1000

    # Coûts en centimes d'euros des kwh consommés :
    month_conso_hc = kwh_conso_hc * @kwh_elec_hc_price
    month_conso_hp = kwh_conso_hp * @kwh_elec_hp_price
    month_conso_st = kwh_conso_st * @kwh_elec_st_price

    # return "HC : #{(month_conso_hc / 100).round} € - HP : #{(month_conso_hp / 100).round} € - ST : #{month_conso_st / 100} €"

    # Part de l'abonnement élec :
    @nb_jrs_mesures = ((end_date.to_date + 1.days) - start_date.to_date).to_i
    abo_ratio = @elec_annual_abo * @nb_jrs_mesures / 365

    @month_conso = month_conso_hc + month_conso_hp + month_conso_st + abo_ratio

    # Estimation du mois au global :
    estimated_month_conso = estimated_month_conso(start_date, end_date)

    results = {
      month_conso: @month_conso,
      estimated_month_conso: estimated_month_conso
    }
    return results
  end

  def estimated_month_conso(start_date, end_date)
    # Définir la période qui reste à estimer :
    month_days_nb = Time.days_in_month(end_date.month)
    remaining_days_nb = month_days_nb - @nb_jrs_mesures

    # Prise en compte d'une répartition forfaitaire des consos par poste et énergies
      # Différents cas de figure selon isolation du logement, modes de chauffage et ECS
      # Une base fixe liées à l'électrodomestique, VMC, cuisson, ECS, éclairage...
        # (à voir si variation éventuelle =  f (scénario de présence)
        # OU détection par analyse de la courbe de charge)
    # Une part variable = f (Te)

    # --> kwh_conso_jr = A + k * (Ti - Te)
      # avec une limite de chauffage pour Te > 15°C ?
      # "A" déterminé en amont
      # "kwh_conso_jr" mesurée au compteur = kwh_consos / jr [kWh / jr]
      # "Ti" fixée à 20°C pour le moment
      # "Te" = f (localisation) --> par API météo
      # Donc avec chaque jour passé, et A fixé, on peut déterminer un k moyen
      # Et connaissant les futurs Te (météo à +de 15 jrs ? + moyennes années passées ? ou / évolution fichiers météo RT12 ?)
      # --> on peut évaluer les "conso_jr" des jours restants du mois

    # Analyse des consos passées
      # Pour le moment : simple = au prorata des jrs restants / moy 30 jrs passés glissants
      history_days_nb = 30
      start_date = end_date - history_days_nb.days
      end_date = end_date

      #-----
      # Conso entre le dernier enregistrement (end_date) et start_date :
      powers = Power.where(housing_id: @housing.id).where("power_time >= :start_day AND power_time <= :end_day",{start_day: start_date, end_day: end_date + 1.days})
      powers_hc = []
      powers_hp = []
      powers_st = []

      powers.each do |power|
        powers_hc << power.power if power.tariff_option == "HC"
        powers_hp << power.power if power.tariff_option == "HP"
        powers_st << power.power if power.tariff_option == "ST"
      end

      # Consos en kWh associées (E = P * tps) avec relevés toutes les 30 min :
      kwh_conso_hc = powers_hc.sum * 0.5 / 1000
      kwh_conso_hp = powers_hp.sum * 0.5 / 1000
      kwh_conso_st = powers_st.sum * 0.5 / 1000
      #-----

      kwh_conso_hc_jr = kwh_conso_hc / history_days_nb
      kwh_conso_hp_jr = kwh_conso_hp / history_days_nb
      kwh_conso_st_jr = kwh_conso_st / history_days_nb

      # Coûts en centimes d'euros des kwh consommés / jr :
      jr_conso_hc = kwh_conso_hc_jr * @kwh_elec_hc_price
      jr_conso_hp = kwh_conso_hp_jr * @kwh_elec_hp_price
      jr_conso_st = kwh_conso_st_jr * @kwh_elec_st_price

      rest_month_conso = (jr_conso_hc + jr_conso_hp + jr_conso_st) * remaining_days_nb

    # Evaluation des consos pour l'ensemble du mois en cts d'euros :
    estimated_month_conso = @month_conso + rest_month_conso
    return estimated_month_conso


  end

end
