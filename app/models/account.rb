class Account < ApplicationRecord

  # Local users
  has_one :user, inverse_of: :account

  validates :username, presence: true

  # Remote user validations
  validates :username, uniqueness: { scope: :domain, case_sensitive: true }, if: -> { !local? && will_save_change_to_username? }


  def local?
    domain.nil?
  end

  def acct
    local? ? username : "#{username}@#{domain}"
  end

  def local_username_and_domain
    "#{username}@#{Rails.configuration.x.local_domain}"
  end

  def keypair
    @keypair ||= OpenSSL::PKey::RSA.new(private_key || public_key)
  end

  def to_param
    username
  end

  before_create :generate_keys
  before_validation :normalize_domain
  before_validation :prepare_contents, if: :local?

  private

  def prepare_contents
    display_name&.strip!
    note&.strip!
  end

  def generate_keys
    return unless local?

    keypair = OpenSSL::PKey::RSA.new(Rails.env.test? ? 512 : 2048)
    self.private_key = keypair.to_pem
    self.public_key  = keypair.public_key.to_pem
  end

  def normalize_domain
    return if local?

    #self.domain = TagManager.instance.normalize_domain(domain)
  end
end
