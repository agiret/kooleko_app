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

  def actual_monthly_conso

    # month_conso
    # estimated_month_conso
    # return "month_conso € / estimated_month_conso €"
  end

  def month_conso(start_date, end_date)
    # Conso entre le dernier enregistrement (JJ/MM/YYYY) et le 01/MM/YYYY :
    # Somme des puissances relevées en HC :
    # Somme des puissances relevées en HP :
    # Somme des puissances relevées en ST :
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
    nb_days = ((end_date.to_date + 1.days) - start_date.to_date).to_i
    abo_ratio = @elec_annual_abo * nb_days / 365

    month_conso = month_conso_hc + month_conso_hp + month_conso_st + abo_ratio

    # return (@last_power_date.to_date + 1.days)
    # return nb_days
    # return abo_ratio / 100.0
    return month_conso
  end

end
