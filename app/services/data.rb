class Data

  # Objectif = pouvoir apeler les fonctions de manipulation de data
  # exemple :
  # Data.new(housing_id).actual_monthly_conso
  # return --> "22 € / 43 €"

  def initialize(housing_id)
    @housing = Housing.find(housing_id)
  end

end
