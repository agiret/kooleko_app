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
code = "1MKr2ZD5sYhxXlvvWGkBQ7pjxUiEmQ"

# client0 = User.create!(
#   email: "client0@gmail.com",
#   password: "azerty",
#   onboarding_step: 3,
#   enedis_state: 20190000,

#   )

# user_step1 :
puts 'Création du user_step1...'
user_step1 = User.create!(
  email: "user_step1@gmail.com",
  password: "azerty"
  )
