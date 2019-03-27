#-------------------------------------------------------------------------------
# Seed sur Heroku :
  # rails db:seed
  # rails db:dump
  # git add .
  # git commit -m "dumping-db"
  # git push heroku master
  # rails db:restore_production
  # -> kooleko_app
#-------------------------------------------------------------------------------

# Nettoyage :
puts 'Suppression des EnedisDatum...'
# EnedisDatum.destroy_all
puts 'Suppression des Power...'
# Power.destroy_all
puts 'Suppression des Housings...'
# Housing.destroy_all
puts 'Suppression des Users...'
# User.destroy_all

# Création des users :
# ----------------------
# client 0 du bac à sable Enedis :
client0_code = "1MKr2ZD5sYhxXlvvWGkBQ7pjxUiEmQ"
client0_usage_point_id = "22516914714270"  #!! A récupérer dans le consent

client0 = User.create!(
  email: "client0@gmail.com",
  password: "azerty",
  onboarding_step: 3,
  enedis_state: 20190000,
  firstname: "Yvon",
  lastname: "Laramée",
  phone: "0641415265"
  )

client0_housing = Housing.create!(
  surface_area: 102,
  heat_system: "",
  hot_water_system: "",
  enedis_usage_point_id: client0_usage_point_id,
  address_street: "12, rue d'Austerlitz",
  address_locality: "Tourtouze",
  address_postal_code: "32400",
  address_insee_code: "32244",
  address_city: "Maulichères",
  address_country: "France"
  )
client0.housing_id = client0_housing.id

client0_housing_enedis_datum = EnedisDatum.create!(
  housing_id: client0_housing.id,
  usage_point_status: "com",
  meter_type: "AMM",
  segment: "C5",
  subscribed_power: "6",
  last_activation_date: "18/10/2014",
  distri_tarif: "BTINFCUST",
  offpeak_hours: "22h00 - 06h00",
  contract_status: "SERVC",
  last_distri_tarif_change_date: "20/02/2017",
  contract_type: ""
  )


# !!!!!!!!! à continuer....

# client0_housing_powers = Power.create!(
#   housing_id: client0_housing.id,
#   power_time: Tue, 19 Mar 2019 00:30:00 UTC +00:00,
#   interval: 1800,
#   power: 1485,
#   tariff_option: "HC"
#   )

# user_step1 :
puts 'Création du user_step1...'
user_step1 = User.create!(
  email: "user_step1@gmail.com",
  password: "azerty"
  )
