class EnedisConnectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profil, only: [:connect]

  def connect
    # consent
    # (pour le moment pas de consent par rappor au redirect_uri)
    get_tokens
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def set_profil
    @profil = User.find(current_user.id)
  end
  def consent
    # affecter une valeur à enedis_state du current_user
    if @profil.enedis_state == nil
      @profil.enedis_state = @profil.id
      @profil.save
    end
    @state = @profil.enedis_state
    client_id = ENV['ENEDIS_CLIENT_ID']
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
    redirect_uri = 'https://gw.hml.api.enedis.fr/redirect'
    redirect_to "#{link}?client_id=#{client_id}&state=#{@state}&duration=#{duration}&response_type=code&redirect_uri=#{redirect_uri}"
  end
  def get_tokens
    client_id = ENV['ENEDIS_CLIENT_ID']
    client_secret = ENV['ENEDIS_CLIENT_SECRET']
    redirect_uri = 'https://gw.hml.api.enedis.fr/redirect'
    link = "https://gw.hml.api.enedis.fr/v1/oauth2/token?redirect_uri=#{redirect_uri}"
    # response = RestClient.post link, {
    #   grant_type: 'authorization_code',
    #   code: 'ciLHi5vBgX7LxPM6ekewQGMZ0U1sivraUFHVYxObINMpY7',
    #   client_id: client_id,
    #   client_secret: client_secret
    # }
    params = {
      redirect_uri: redirect_uri,
      body: {
        grant_type: 'authorization_code',
        code: '576c61wMkOlrCMhjro0mbOAlPKtksk',
        client_id: client_id,
        client_secret: client_secret
      }
    }

    response = RestClient.post link, params, headers

    @token_response = JSON.parse(response)
    @refresh_token = @token_response['refresh_token']
    @access_token = @token_response['access_token']

    # Test avec gem oauth2 :
    # redirect_uri  = 'https://gw.hml.api.enedis.fr/redirect' # your client's redirect uri
    # site          = "http://localhost:3000" # your provider server, mine is running on localhost

    # client = OAuth2::Client.new(client_id, client_secret, :site => site)
    # code = "Y22qqsmXegVPgcnJQJZoYXDtguWdjr" # code you got in the redirect uri
    # token = client.auth_code.get_token(code, :redirect_uri => redirect_uri)

  end
  def get_identity
    refresh_tokens

  end
  def get_client_infos

  end
  def contract_datas

  end
  def refresh_tokens
    client_id = ENV['ENEDIS_CLIENT_ID']
    client_secret = ENV['ENEDIS_CLIENT_SECRET']
    link = 'https://gw.hml.api.enedis.fr/v1/oauth2/token?redirect_uri=https://gw.hml.api.enedis.fr/redirect'
    response = RestClient.post link, {
      grant_type: 'refresh_token',
      refresh_token: 'ciLHi5vBgX7LxPM6ekewQGMZ0U1sivraUFHVYxObINMpY7',
      client_id: client_id,
      client_secret: client_secret
    }
    @refresh_response = JSON.parse(response)
    @refresh_token = @refresh_response['refresh_token']
    @access_token = @refresh_response['access_token']
  end
end
