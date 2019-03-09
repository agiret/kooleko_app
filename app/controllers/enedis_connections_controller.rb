class EnedisConnectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profil, :set_keys, only: [:connect]

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
    @profil.update(onboarding_step: 2)
    redirect_to  edit_profil_path(@profil)
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
    @usage_point_id = "12345678901234"  #!! A récupérer dans le consent
    new_housing = Housing.create(enedis_usage_point_id: @usage_point_id)  #!! voir pourquoi ça ne semble pas passer par méthode create du controller Housings !
    @profil.housing_id = new_housing.identity_response  #!! inutile si ça passait bie dans la méthode create du controller
    @profil.save
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
    @enedis_datum = EnedisDatum.new(housing_id: @housing.id)  #!! prévoir cas où un enedis_datum basé sur ce @housing existe déjà ??

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
    @enedis_datum.usage_point_status = @usage_point_status
    @enedis_datum.meter_type = @meter_type
    @enedis_datum.segment = @segment
    @enedis_datum.subscribed_power = @subscribed_power
    @enedis_datum.last_activation_date = @last_activation_date
    @enedis_datum.distri_tarif = @distri_tarif
    @enedis_datum.offpeak_hours = @offpeak_hours
    @enedis_datum.contract_type = @contract_type
    @enedis_datum.contract_status = @contract_status
    @enedis_datum.last_distri_tarif_change_date = @last_distri_tarif_change_date
    @enedis_datum.save
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
end
