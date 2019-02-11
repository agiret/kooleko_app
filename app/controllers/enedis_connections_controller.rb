class EnedisConnectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profil, :set_keys, only: [:connect]

  def connect
    # consent
    # (pour le moment pas de consent par rappor au redirect_uri)
    get_tokens
    # refresh_tokens
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
  end
  def get_tokens
    redirect_uri = ENV['ENEDIS_REDIRECT_URI']
    link = "#{ENV['ENEDIS_DOMAIN']}oauth2/token"
    @code = 'fz8Ij9bED6fgF1Xk4G5tqG0AJvtqIM'  #!! normalement à récupérer avec consent juste avant
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
  end

  # ENEDIS DATAS REQUESTS :
  def get_identity
    refresh_tokens

  end
  def get_client_infos

  end
  def contract_datas

  end
end
