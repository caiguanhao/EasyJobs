module AdminsHelper
  def generate_google_authenticator_qrcode_for_admin(admin)
    require 'rotp'
    totp = ROTP::TOTP.new(admin.auth_secret)
    data = totp.provisioning_uri("EasyJobs:#{admin.username}")
    data = Rack::Utils.escape(data)
    url = "https://chart.googleapis.com/chart?chs=230x230&chld=M|0&cht=qr&chl=#{data}"
    return image_tag(url, :alt => 'Google Authenticator QRCode')
  end
end
