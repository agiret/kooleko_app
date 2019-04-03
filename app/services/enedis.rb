class Enedis
  # attr_reader :html_doc

  def initialize
    # RestClient.proxy = ENV['PROXY_ADDRESS']
    # html_file = RestClient.get(url)
    # @html_doc = Nokogiri::HTML(html_file)
  end

  def get_courbe_conso(start_date, end_date, housing_id, user_id)
    puts "---> Récupération des consos du #{start_date} au #{end_date}..."
    puts "---> ....."
    # refresh_tokens  #!! basculé côté controller avant appel de get_courbe_conso

    # Avoir housing_id et user_id
    # @housing = Housing.find(@profil.housing_id)
    # @usage_point_id = @housing.enedis_usage_point_id  #!! @profil.housing.enedis_usage_point_id ne fonctionne pas

    user = User.find(user_id)
    housing = Housing.find(housing_id)
    link = "https://gw.hml.api.enedis.fr/v3/metering_data/consumption_load_curve"
    response = RestClient::Request.execute(
      method: 'GET',
      url: link,
      headers: {
        accept: 'application/json',
        authorization: "Bearer #{user.enedis_access_token}",
        params: {
          usage_point_id: "#{housing.enedis_usage_point_id}",
          start: start_date,
          end: end_date
          }
      }
    )
    data_response = JSON.parse(response)
    # Récupération des données :
    @data_start = DateTime.parse(data_response['usage_point'][0]['meter_reading']['start'])
    @data_end = DateTime.parse(data_response['usage_point'][0]['meter_reading']['end'])
    @data_response = data_response['usage_point'][0]['meter_reading']['interval_reading']

    interval = 1800.seconds
    time = @data_start  # format Datetime
    records = 0

    # Récupération du code de l'option tarifaire du contrat :
    enedis_datum = EnedisDatum.where(housing_id: housing_id)[0]  # format avec .where = [ ]
    @distri_tarif_contract = enedis_datum.distri_tarif
    puts "---> Code option tarifaire du contrat : #{@distri_tarif_contract}"
    offpeak_hours_contract = enedis_datum.offpeak_hours
    puts "---> Plage horaire heures creuses : #{offpeak_hours_contract}"
    @offpeak_start = offpeak_hours_contract[0..4]  # format = string "22h00"
    @offpeak_end = offpeak_hours_contract[-5..-1]  # format = string "06h00"

    @data_response.each do |data|
      # tariff_option(data) = ?? (appeler une méthdoe dédiée qui renvoir la réponse à chaque tour)
      tariff_option = tariff_option(time)
      puts "---> Conso en #{tariff_option}"
      data = Power.new(
        housing_id: housing_id,
        power_time: time,
        interval: interval,
        power: data['value'],
        tariff_option: tariff_option
        )
      data.save
      time += interval
      records += 1
    end
    puts "---> #{records} enregistrements effectués !"
    powers = Power.last(records)
    return powers

  end
  def tariff_option(time)
    if @distri_tarif_contract[-2..-1] == "ST"
      puts "---> Plage horaire en Simple Tarif"
      return "ST"
    elsif @distri_tarif_contract[-2..-1] == "DT"
      puts "---> Plage horaire en Double Tarif"
      if time_between?(time, @offpeak_start, @offpeak_end)
        return "HC"
      else
        return "HP"
      end
        # prévoir par la suite d'autres formats ? "HP" ou "HC" ou "HP" ou autres ?
    else
      puts "---> Code distri_tarif '#{@distri_tarif}' non pris en charge !"
    end
  end
  def time_between?(datetime, offpeak_start, offpeak_end)
    # Convertir datetime en un string au format "13h41" :
    time = datetime.strftime("%Hh%M")
    puts "---> Power time : #{time}"
    # Conversion des heures en minutes :
    time = time[0..1].to_i * 60 + time[-2..-1].to_i
    offpeak_start = offpeak_start[0..1].to_i * 60 + offpeak_start[-2..-1].to_i
    offpeak_end = offpeak_end[0..1].to_i * 60 + offpeak_end[-2..-1].to_i
    # Test si offpeak_start est avant offpeak_end
    if (offpeak_start < offpeak_end)
      # renvoi true si time est entre [offpeak_start ; offpeak_end]
      return offpeak_start <= time && time <= offpeak_end;
    # Sinon, offpeak_start est après offpeak_end, donc on fait la comparaison opposée
    else
      # renvoi !true (=false) si time est entre [offpeak_end ; offpeak_start]
      # renvoi !false (=true) si time n'est pas entre [offpeak_end ; offpeak_start]
      return !(offpeak_end < time && time < offpeak_start)
    end
  end

  private


end

