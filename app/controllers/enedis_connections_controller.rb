class EnedisConnectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profil, only: [:connect]

  def connect
    refresh_tokens
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def set_profil
    @profil = User.find(current_user.id)
  end
  def consent

  end
  def get_tokens

  end
  def get_identity

  end
  def get_client_infos

  end
  def contract_datas

  end
  def refresh_tokens
    client_id = ENV['ENEDIS_CLIENT_ID']
    client_secret = ENV['ENEDIS_CLIENT_SECRET']
    response = RestClient.post 'https://gw.hml.api.enedis.fr/v1/oauth2/token?redirect_uri=https://gw.hml.api.enedis.fr/redirect', {
      grant_type: 'refresh_token',
      refresh_token: 'zLuKwHTaMYbEpkjGOL8SxvcfZ1Q0euUFhxKsAM86fbA7AG',
      client_id: client_id,
      client_secret: client_secret
    }
    puts response
  end
end
