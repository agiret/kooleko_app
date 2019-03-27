class EnedisConnectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profil, :set_keys, only: [:connect, :courbe_conso]

  def connect
    # consent
    # (pour le moment pas de consent par rapport au redirect_uri)
    # get_tokens
    # refresh_tokens
    create_housing      # Création du logement associé au user
    get_identity        # Prénom, nom
    get_client_infos    # N° de téléphone
    contract_datas      # Données de ligne ENEDIS
    get_address         # Adresse du logement
    courbe_conso        # Récupération des consos /30min des 7 jours précédents
    @profil.update(onboarding_step: 2)
    redirect_to  edit_profil_path(@profil)
  end
  def courbe_conso
    puts '---> Récupération des conos ?'
    @housing = Housing.find(@profil.housing_id)
    @today = DateTime.now()
    # On va récupérer le dernier enregistrement de power associé à ce logement
    last_power = Power.where(housing_id: @housing.id).last

    if @profil.onboarding_step >= 2 &&! last_power.nil?
      # récupérer horodatage du dernier enregistrement
      puts '---> Le logement associé à cet utilisateur a déjà des données de conos'
      @last_power_date = last_power.power_time.beginning_of_day
      start_date = (@last_power_date + 1.days)
      end_date = [@last_power_date + 7.days, @today.beginning_of_day - 1.days].min
    else
      puts '---> Pas encore de données de consos pour ce logement'
      start_date = (@today.beginning_of_day - 8.days)
      end_date = (@today.beginning_of_day - 1.days)
    end
    # prévoir cas où start_date = end_date :
    get_courbe_conso(start_date.strftime("%Y-%m-%d"), end_date.strftime("%Y-%m-%d")) if start_date < end_date
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  # BEFORE_ACTION FUNCTIONS:
  # ------------------------
  def set_profil
    @profil = User.find(current_user.id)
  end
  def set_keys
    @client_id = ENV['ENEDIS_CLIENT_ID']
    @client_secret = ENV['ENEDIS_CLIENT_SECRET']
  end
  def create_housing
    @usage_point_id = "22516914714270"  #!! A récupérer dans le consent
    new_housing = Housing.create(enedis_usage_point_id: @usage_point_id)  #!! voir pourquoi ça ne semble pas passer par méthode create du controller Housings !
    @profil.housing_id = new_housing.id  #!! inutile si ça passait bien dans la méthode create du controller
    @profil.save
    # redirect_to housings_path(enedis_usage_point_id: @usage_point_id), method: :post
  end

  # ENEDIS ACCESS FUNCTIONS :
  # -------------------------
  def consent
    # affecter une valeur à enedis_state du current_user
    if @profil.enedis_state == nil
      @profil.enedis_state = @profil.id
      @profil.save
    end
    @state = @profil.enedis_state
    link = 'https://gw.hml.api.enedis.fr/group/espace-particuliers/consentement-linky/oauth2/authorize'
    # response = RestClient.get link, {
    #   client_id: client_id,
    #   state: @state,
    #   duration: 'P6M',
    #   response_type: 'code',
    #   redirect_uri: 'https://gw.hml.api.enedis.fr/redirect'
    # }
    # @consent_response = response
    duration = 'P6M'
    redirect_uri = ENV['ENEDIS_REDIRECT_URI']
    redirect_to "#{link}?client_id=#{@client_id}&state=#{@state}&duration=#{duration}&response_type=code&redirect_uri=#{redirect_uri}"

    # enregistrer 'code' dans une varaible @code
    # stocker usage_point_id dans housings
  end
  def get_tokens
    redirect_uri = ENV['ENEDIS_REDIRECT_URI']
    link = "#{ENV['ENEDIS_DOMAIN']}oauth2/token"
    @code = '1i4Fl3rVoCDWq9ZIOwZHIXjLFkcwbR'  #!! normalement à récupérer avec consent juste avant
    # response = RestClient.post link, params, headers
    response = RestClient::Request.execute(
      method: 'POST',
      url: link,
      payload: {
        grant_type: 'authorization_code',
        code: @code,
        client_id: @client_id,
        client_secret: @client_secret
      },
      headers: {
        params: {redirect_uri: redirect_uri }
      }
    )
    token_response = JSON.parse(response)
    @profil.enedis_refresh_token = token_response['refresh_token']
    @profil.enedis_access_token = token_response['access_token']
    @profil.save
    puts '---> access_token et refresh_token récupérés et sauvegardés ! (get_tokens)'
  end
  def refresh_tokens
    link = "#{ENV['ENEDIS_DOMAIN']}oauth2/token?redirect_uri=#{ENV['ENEDIS_REDIRECT_URI']}"
    response = RestClient.post link, {
      grant_type: 'refresh_token',
      refresh_token: @profil.enedis_refresh_token,
      client_id: @client_id,
      client_secret: @client_secret
    }
    refresh_response = JSON.parse(response)
    @profil.enedis_refresh_token = refresh_response['refresh_token']
    @profil.enedis_access_token = refresh_response['access_token']
    @profil.save
    puts '---> refresh_token !'
  end

  # ENEDIS DATA REQUESTS :
  # ----------------------
  def get_identity
    refresh_tokens
    @housing = Housing.find(@profil.housing_id)
    @usage_point_id = @housing.enedis_usage_point_id  #!! @profil.housing.enedis_usage_point_id ne fonctionne pas

    link = "https://gw.hml.api.enedis.fr/v3/customers/identity"
    response = RestClient::Request.execute(
      method: 'GET',
      url: link,
      headers: {
        accept: 'application/json',
        authorization: "Bearer #{@profil.enedis_access_token}",
        params: {usage_point_id: "#{@housing.enedis_usage_point_id}" }
      }
    )
    identity_response = JSON.parse(response)
    @firstname = identity_response[0]['customer']['identity']['natural_person']['firstname']
    @lastname = identity_response[0]['customer']['identity']['natural_person']['lastname']
    @profil.firstname = @firstname
    @profil.lastname = @lastname
    @profil.save
    puts '---> Identité récupérée (Prénom, Nom)'
  end
  def get_client_infos
    # refresh_tokens
    # @housing = Housing.find(@profil.housing_id)
    # @usage_point_id = @housing.enedis_usage_point_id  #!! @profil.housing.enedis_usage_point_id ne fonctionne pas

    link = "https://gw.hml.api.enedis.fr/v3/customers/contact_data"
    response = RestClient::Request.execute(
      method: 'GET',
      url: link,
      headers: {
        accept: 'application/json',
        authorization: "Bearer #{@profil.enedis_access_token}",
        params: {usage_point_id: "#{@housing.enedis_usage_point_id}" }
      }
    )
    contact_response = JSON.parse(response)
    @phone = contact_response[0]['customer']['contact_data']['phone']
    @profil.phone = @phone
    @profil.save
    puts '---> Numéro de téléphone récupéré'
  end
  def contract_datas
    # refresh_tokens
    # @housing = Housing.find(@profil.housing_id)
    # @usage_point_id = @housing.enedis_usage_point_id  #!! @profil.housing.enedis_usage_point_id ne fonctionne pas
    enedis_datum = EnedisDatum.new(housing_id: @housing.id)  #!! prévoir cas où un enedis_datum basé sur ce @housing existe déjà ??

    link = "https://gw.hml.api.enedis.fr/v3/customers/usage_points/contracts"
    response = RestClient::Request.execute(
      method: 'GET',
      url: link,
      headers: {
        accept: 'application/json',
        authorization: "Bearer #{@profil.enedis_access_token}",
        params: {usage_point_id: "#{@housing.enedis_usage_point_id}" }
      }
    )
    contract_response = JSON.parse(response)
    # Récupération des données :
    @usage_point_status = contract_response[0]['customer']['usage_points'][0]['usage_point']['usage_point_status']
    @meter_type = contract_response[0]['customer']['usage_points'][0]['usage_point']['meter_type']
    @segment = contract_response[0]['customer']['usage_points'][0]['usage_point']['contracts']['segment']
    @subscribed_power = contract_response[0]['customer']['usage_points'][0]['usage_point']['contracts']['subscribed_power']
    @last_activation_date = contract_response[0]['customer']['usage_points'][0]['usage_point']['contracts']['last_activation_date']
    @distri_tarif = contract_response[0]['customer']['usage_points'][0]['usage_point']['contracts']['distribution_tariff']
    @offpeak_hours = contract_response[0]['customer']['usage_points'][0]['usage_point']['contracts']['offpeak_hours']
    @contract_type = contract_response[0]['customer']['usage_points'][0]['usage_point']['contracts']['contract_type']
    @contract_status = contract_response[0]['customer']['usage_points'][0]['usage_point']['contracts']['contract_status']
    @last_distri_tarif_change_date = contract_response[0]['customer']['usage_points'][0]['usage_point']['contracts']['last_distribution_tariff_change_date']
    # Enregistrement des données :
    enedis_datum.usage_point_status = @usage_point_status
    enedis_datum.meter_type = @meter_type
    enedis_datum.segment = @segment
    enedis_datum.subscribed_power = @subscribed_power
    enedis_datum.last_activation_date = @last_activation_date
    enedis_datum.distri_tarif = @distri_tarif
    enedis_datum.offpeak_hours = @offpeak_hours
    enedis_datum.contract_type = @contract_type
    enedis_datum.contract_status = @contract_status
    enedis_datum.last_distri_tarif_change_date = @last_distri_tarif_change_date
    enedis_datum.save
    puts '---> Données de ligne ENEDIS récupérées'
  end
  def get_address
    # refresh_tokens
    # @housing = Housing.find(@profil.housing_id)
    # @usage_point_id = @housing.enedis_usage_point_id  #!! @profil.housing.enedis_usage_point_id ne fonctionne pas

    link = "https://gw.hml.api.enedis.fr/v3/customers/usage_points/addresses"
    response = RestClient::Request.execute(
      method: 'GET',
      url: link,
      headers: {
        accept: 'application/json',
        authorization: "Bearer #{@profil.enedis_access_token}",
        params: {usage_point_id: "#{@housing.enedis_usage_point_id}" }
      }
    )
    address_response = JSON.parse(response)
    # Récupération des données :
    @address_street = address_response[0]['customer']['usage_points'][0]['usage_point']['usage_point_addresses']['street']
    @address_locality = address_response[0]['customer']['usage_points'][0]['usage_point']['usage_point_addresses']['locality']
    @address_postal_code = address_response[0]['customer']['usage_points'][0]['usage_point']['usage_point_addresses']['postal_code']
    @address_insee_code = address_response[0]['customer']['usage_points'][0]['usage_point']['usage_point_addresses']['insee_code']
    @address_city = address_response[0]['customer']['usage_points'][0]['usage_point']['usage_point_addresses']['city']
    @address_country = address_response[0]['customer']['usage_points'][0]['usage_point']['usage_point_addresses']['country']
    # Enregistrement des données :
    @housing.address_street = @address_street
    @housing.address_locality = @address_locality
    @housing.address_postal_code = @address_postal_code
    @housing.address_insee_code = @address_insee_code
    @housing.address_city = @address_city
    @housing.address_country = @address_country
    @housing.save
    puts '---> Adresse du logement récupérée'
  end
  def get_courbe_conso(start_date, end_date)
    puts "---> Récupération des consos du #{start_date} au #{end_date}..."
    puts "---> ....."
    refresh_tokens
    @housing = Housing.find(@profil.housing_id)
    @usage_point_id = @housing.enedis_usage_point_id  #!! @profil.housing.enedis_usage_point_id ne fonctionne pas
    link = "https://gw.hml.api.enedis.fr/v3/metering_data/consumption_load_curve"
    response = RestClient::Request.execute(
      method: 'GET',
      url: link,
      headers: {
        accept: 'application/json',
        authorization: "Bearer #{@profil.enedis_access_token}",
        params: {
          usage_point_id: "#{@housing.enedis_usage_point_id}",
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
    @enedis_datum = EnedisDatum.where(housing_id: @housing.id)[0]  # format avec .where = [ ]
    @distri_tarif_contract = @enedis_datum.distri_tarif
    puts "---> Code option tarifaire du contrat : #{@distri_tarif_contract}"
    @offpeak_hours_contract = @enedis_datum.offpeak_hours
    puts "---> Plage horaire heures creuses : #{@offpeak_hours_contract}"
    @offpeak_start = @offpeak_hours_contract[0..4]  # format = string "22h00"
    @offpeak_end = @offpeak_hours_contract[-5..-1]  # format = string "06h00"

    @data_response.each do |data|
      # tariff_option(data) = ?? (appeler une méthdoe dédiée qui renvoir la réponse à chaque tour)
      tariff_option = tariff_option(time)
      puts "---> Conso en #{tariff_option}"
      data = Power.new(
        housing_id: @housing.id,
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

end
