class Account < ApplicationRecord

  include AccountFinderConcern

  # Local users
  has_one :user, inverse_of: :account

  has_many :articles
  has_many :activities, inverse_of: :account, dependent: :destroy

  validates :username, presence: true

  # Remote user validations
  validates :username, uniqueness: { scope: :domain, case_sensitive: true }, if: -> { !local? && will_save_change_to_username? }

  has_many :active_relationships,  class_name: 'Follow', foreign_key: 'account_id', dependent: :destroy
  has_many :passive_relationships, class_name: 'Follow', foreign_key: 'target_account_id', dependent: :destroy

  has_many :following, -> { order('follows.id desc') }, through: :active_relationships,  source: :target_account
  has_many :followers, -> { order('follows.id desc') }, through: :passive_relationships, source: :account

  def following?(other_account)
    active_relationships.where(target_account: other_account).exists?
  end

  def local?
    domain.nil?
  end

  def acct
    local? ? username : "#{username}@#{domain}"
  end

  def local_username_and_domain
    "#{username}@#{Rails.configuration.x.local_domain}"
  end

  def to_webfinger_s
    "acct:#{local_username_and_domain}"
  end

  def keypair
    @keypair ||= OpenSSL::PKey::RSA.new(private_key || public_key)
  end

  def save_with_optional_media!
    save!
  #rescue ActiveRecord::RecordInvalid
  #  self.avatar              = nil
  #  self.header              = nil
  #  self[:avatar_remote_url] = ''
  #  self[:header_remote_url] = ''
  #  save!
  end

  def object_type
    :person
  end  

  def to_param
    username
  end

  before_create :generate_keys
  before_validation :normalize_domain
  before_validation :prepare_contents, if: :local?

  class << self
    def search_for(terms, limit = 10)
      textsearch, query = generate_query_for_search(terms)

      sql = <<-SQL.squish
        SELECT
          accounts.*,
          ts_rank_cd(#{textsearch}, #{query}, 32) AS rank
        FROM accounts
        WHERE #{query} @@ #{textsearch}
        ORDER BY rank DESC
        LIMIT ?
      SQL

      find_by_sql([sql, limit])
    end

    def advanced_search_for(terms, account, limit = 10)
      textsearch, query = generate_query_for_search(terms)

      sql = <<-SQL.squish
        SELECT
          accounts.*,
          (count(f.id) + 1) * ts_rank_cd(#{textsearch}, #{query}, 32) AS rank
        FROM accounts
        LEFT OUTER JOIN follows AS f ON (accounts.id = f.account_id AND f.target_account_id = ?) OR (accounts.id = f.target_account_id AND f.account_id = ?)
        WHERE #{query} @@ #{textsearch}
        GROUP BY accounts.id
        ORDER BY rank DESC
        LIMIT ?
      SQL

      find_by_sql([sql, account.id, account.id, limit])
    end

    private

    def generate_query_for_search(terms)
      terms      = Arel.sql(connection.quote(terms.gsub(/['?\\:]/, ' ')))
      textsearch = "(setweight(to_tsvector('simple', accounts.display_name), 'A') || setweight(to_tsvector('simple', accounts.username), 'B') || setweight(to_tsvector('simple', coalesce(accounts.domain, '')), 'C'))"
      query      = "to_tsquery('simple', ''' ' || #{terms} || ' ''' || ':*')"

      [textsearch, query]
    end
  end


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
