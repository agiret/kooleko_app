class EnedisConnectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profil, :set_keys, only: [:connect]

  def connect
    # consent
    # (pour le moment pas de consent par rappor au redirect_uri)
    # get_tokens
    # refresh_tokens
    get_identity
    get_client_infos
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  # BEFORE_ACTION FUNCTIONS:
  def set_profil
    @profil = User.find(current_user.id)
  end
  def set_keys
    @client_id = ENV['ENEDIS_CLIENT_ID']
    @client_secret = ENV['ENEDIS_CLIENT_SECRET']
  end

  # ENEDIS ACCESS FUNCTIONS :
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
    @code = 'HxAjjYzjcTapEfkU7mmB8XcaNR7Cup'  #!! normalement à récupérer avec consent juste avant
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

  # ENEDIS DATAS REQUESTS :
  def get_identity
    refresh_tokens
    @housing = Housing.find(@profil.housing_id)
    @usage_point_id = @housing.enedis_usage_point_id

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

    puts '---> Identité récupérée'
  end
  def get_client_infos
    # refresh_tokens
    @housing = Housing.find(@profil.housing_id)
    @usage_point_id = @housing.enedis_usage_point_id

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

    puts '---> Identité récupérée'
  end
  def contract_datas

  end
end
