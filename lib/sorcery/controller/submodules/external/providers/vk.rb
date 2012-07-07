module Sorcery
  module Controller
    module Submodules
      module External
        module Providers
          # This module adds support for OAuth with vk.com.
          # When included in the 'config.providers' option, it adds a new option, 'config.vk'.
          # Via this new option you can configure vk specific settings like your app's key and secret.
          #
          #   config.vk.key = <key>
          #   config.vk.secret = <secret>
          #   ...
          #
          module Vk
            def self.included(base)
              base.module_eval do
                class << self
                  attr_reader :vk                           # access to vk_client.
                  
                  def merge_vk_defaults!
                    @defaults.merge!(:@vk => VkClient)
                  end
                end
                merge_vk_defaults!
                update!
              end
            end
          
            module VkClient
              class << self
                attr_accessor :key,
                              :secret,
                              :callback_url,
                              :site,
                              :user_info_path,
                              :scope,
                              :user_info_mapping
                            
                include Protocols::Oauth2
            
                def init
                  @site           = "https://oauth.vk.com/authorize"
                  @user_info_path = "https://api.vk.com/method/getProfiles"
                  @scope          = "offline"
                  @user_info_mapping = {}
                end
                
                def get_user_hash
                  user_hash = {}
                  response = @access_token.get(@user_info_path, :uid => @user_id)
                  user_hash[:user_info] = JSON.parse(response)['response'].first
                  user_hash[:uid] = user_hash[:user_info]['uid']
                  user_hash
                end
                
                def has_callback?
                  true
                end
                
                # calculates and returns the url to which the user should be redirected,
                # to get authenticated at the external provider's site.
                def login_url(params,session)
                  self.authorize_url()
                end
                
                # tries to login the user from access token
                def process_callback(params,session)
                  args = {}
                  args.merge!({:code => params[:code]}) if params[:code]
                  @access_token = self.get_access_token(args)
                  @user_id = @access_token.params['user_id']
                end
                
              end
              init
            end
            
          end
        end    
      end
    end
  end
end
