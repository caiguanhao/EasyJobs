module AdminsHelper
  def generate_google_authenticator_qrcode_for_admin(admin)
    require 'rotp'
    totp = ROTP::TOTP.new(admin.auth_secret)
    totp.provisioning_uri("EasyJobs:#{admin.username}")
    # data = totp.provisioning_uri("EasyJobs:#{admin.username}")
    # data = Rack::Utils.escape(data)
    # url = "https://chart.googleapis.com/chart?chs=230x230&chld=M|0&cht=qr&chl=#{data}"
    # return image_tag(url, :alt => 'Google Authenticator QRCode')
  end

  def generate_mobile_authentication_qrcode_for_admin(admin)
    require 'json'
    require 'base64'

    # version 1
    Base64.strict_encode64(JSON.dump({ v: 1, u: api_v1_help_url, c: admin.authentication_token }))
  end
end
