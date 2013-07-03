class Admin < ActiveRecord::Base
  devise :database_authenticatable, :rememberable, :trackable, :validatable
  validates_format_of :username, :with => /[0-9a-zA-Z\p{Han}]{3,16}/
  validates :username, :uniqueness => { :case_sensitive => false }

  attr_accessor :login, :auth_code

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    auth_code = conditions[:auth_code]
    return false unless !!(auth_code =~ /\A[0-9]{6}\Z/)
    conditions = conditions.except(:auth_code)

    first = if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end

    require 'rotp'
    return false unless first && auth_code.to_i == ROTP::TOTP.new(first.auth_secret).now

    return first
  end

  before_validation :assign_auth_secret, :on => :create
  def assign_auth_secret
    require 'rotp'
    self.auth_secret = ROTP::Base32.random_base32
  end
end
