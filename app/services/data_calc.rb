class DataCalc

  # Objectif = pouvoir apeler les fonctions de manipulation de data
  # exemple :
  # Data.new(housing_id).actual_monthly_conso
  # return --> "22 € / 43 €"

  # Hypothèses simplifiées : tarifs en centimes d'euros
  @kwh_elec_hp_price = 14
  @kwh_elec_hc_price = 12
  @kwh_elec_st_price = 13
  @elec_annual_abo = 10000

  def initialize(housing_id)
    @housing = Housing.find(housing_id)

    # Dernier enregistrement de power associé à ce logement :
    last_power = Power.where(housing_id: @housing.id).last
    # Horodatage du dernier enregistrement :
    @last_power_date = last_power.power_time.beginning_of_day
    # Premier jour du mois évalué :
    @first_power_date = last_power.power_time.beginning_of_month
  end

  def test
    return "Hello from Data class !"
  end

  def actual_monthly_conso

    return "Du #{@first_power_date} au #{@last_power_date} "

    # month_conso
    # estimated_month_conso
    # return "month_conso € / estimated_month_conso €"
  end

  def month_conso
    # Conso entre le dernier enregistrement (JJ/MM/YYYY) et le 01/MM/YYYY :
    # Somme des puissances relevées en HC :
    # Somme des puissances relevées en HP :
    # Somme des puissances relevées en ST :
    powers = Power.where(housing_id: @housing.id).where("power_time >= :first_day AND power_time <= :end_day",{first_day: @first_power_date, end_day: @last_power_date + 1.days})
    puts powers
    powers_hc = []
    powers_hp = []
    powers_st = []

    return powers




    # Consos en kWh associées (E = P * tps) avec relevés toutes les 30 min :
    kwh_conso_hc = power_sum_hc * 0.5 / 1000
    kwh_conso_hp = power_sum_hp * 0.5 / 1000
    kwh_conso_st = power_sum_st * 0.5 / 1000

    # Coûts en centimes d'euros des kwh consommés :
    month_conso_hc = kwh_conso_hc * @kwh_elec_hc_price
    month_conso_hp = kwh_conso_hp * @kwh_elec_hp_price
    month_conso_st = kwh_conso_st * @kwh_elec_st_price

    # Part de l'abonnement élec :
    nb_days = (@last_power_date + 1.days - @first_power_date).to_i
    abo_ratio = @elec_annual_abo * nb_days / 365

    month_conso = month_conso_hc + month_conso_hp + month_conso_st + abo_ratio


  end

end
