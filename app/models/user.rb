class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :housings, required: false

  validates :email, presence: true

  after_initialize :init

  def init
    # Set the default value to 1 only if it's nil
    self.onboarding_step ||= 1
  end

  # Rafraîchissement du token si expiré :
  # (exemple de code copié sur : https://stackoverflow.com/questions/21707734/refresh-token-using-omniauth-oauth2-in-rails-application/21879758)
  # def refresh_token_if_expired
  #   if token_expired?
  #     response    = RestClient.post "#{ENV['ENEDIS_DOMAIN']}oauth2/token", :grant_type => 'refresh_token', :refresh_token => self.refresh_token, :client_id => ENV['ENEDIS_CLIENT_ID'], :client_secret => ENV['ENEDIS_CLIENT_SECRET']
  #     refreshhash = JSON.parse(response.body)

  #     token_will_change!
  #     expiresat_will_change!

  #     self.token     = refreshhash['access_token']
  #     self.expiresat = DateTime.now + refreshhash["expires_in"].to_i.seconds

  #     self.save
  #     puts 'Saved'
  #   end
  # end
  # def token_expired?
  #   expiry = Time.at(self.expiresat)
  #   return true if expiry < Time.now # expired token, so we should quickly return
  #   token_expires_at = expiry
  #   save if changed?
  #   false # token not expired. :D
  # end
end
