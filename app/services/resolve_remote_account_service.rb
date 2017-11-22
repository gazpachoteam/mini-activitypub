# frozen_string_literal: true

class ResolveRemoteAccountService < BaseService
  include JsonldHelper

  DFRN_NS = 'http://purl.org/macgirvin/dfrn/1.0'

  # Find or create a local account for a remote user.
  # When creating, look up the user's webfinger and fetch all
  # important information from their feed
  # @param [String] uri User URI in the form of username@domain
  # @return [Account]
  def call(uri, update_profile = true, redirected = nil)
    @username, @domain = uri.split('@')
    @update_profile    = update_profile

    return Account.find_local(@username) if TagManager.instance.local_domain?(@domain)

    @account = Account.find_remote(@username, @domain)

    return @account unless webfinger_update_due?

    Rails.logger.debug "Looking up webfinger for #{uri}"

    @webfinger = Goldfinger.finger("acct:#{uri}")

    confirmed_username, confirmed_domain = @webfinger.subject.gsub(/\Aacct:/, '').split('@')

    if confirmed_username.casecmp(@username).zero? && confirmed_domain.casecmp(@domain).zero?
      @username = confirmed_username
      @domain   = confirmed_domain
    elsif redirected.nil?
      return call("#{confirmed_username}@#{confirmed_domain}", update_profile, true)
    else
      Rails.logger.debug 'Requested and returned acct URIs do not match'
      return
    end

    return if links_missing?
    return Account.find_local(@username) if TagManager.instance.local_domain?(@domain)

    @account = Account.find_remote(@username, @domain)

    if activitypub_ready?
      handle_activitypub
    end

    @account
  rescue Goldfinger::Error => e
    Rails.logger.debug "Webfinger query for #{uri} unsuccessful: #{e}"
    nil
  end

  private

  def links_missing?
    !activitypub_ready?
  end

  def webfinger_update_due?
    @account.nil? || @account.possibly_stale?
  end

  def activitypub_ready?
    !@webfinger.link('self').nil? &&
      ['application/activity+json', 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'].include?(@webfinger.link('self').type) &&
      !actor_json.nil? &&
      actor_json['inbox'].present?
  end

  def handle_ostatus
    create_account if @account.nil?
    update_account
    update_account_profile if update_profile?
  end

  def update_profile?
    @update_profile
  end

  def handle_activitypub
    return if actor_json.nil?

    @account = ActivityPub::ProcessAccountService.new.call(@username, @domain, actor_json)
  rescue Oj::ParseError
    nil
  end

  def create_account
    Rails.logger.debug "Creating new remote account for #{@username}@#{@domain}"

    @account = Account.new(username: @username, domain: @domain)
    @account.suspended   = true if auto_suspend?
    @account.silenced    = true if auto_silence?
    @account.private_key = nil
  end

  def update_account
    @account.last_webfingered_at = Time.now.utc
    @account.protocol            = :ostatus
    @account.remote_url          = atom_url
    @account.salmon_url          = salmon_url
    @account.url                 = url
    @account.public_key          = public_key
    @account.uri                 = canonical_uri
    @account.hub_url             = hub_url
    @account.save!
  end

  def auto_suspend?
    domain_block && domain_block.suspend?
  end

  def auto_silence?
    domain_block && domain_block.silence?
  end

  def domain_block
    return @domain_block if defined?(@domain_block)
    @domain_block = DomainBlock.find_by(domain: @domain)
  end

  def atom_url
    @atom_url ||= @webfinger.link('http://schemas.google.com/g/2010#updates-from').href
  end

  def salmon_url
    @salmon_url ||= @webfinger.link('salmon').href
  end

  def actor_url
    @actor_url ||= @webfinger.link('self').href
  end

  def url
    @url ||= @webfinger.link('http://webfinger.net/rel/profile-page').href
  end

  def canonical_uri
    return @canonical_uri if defined?(@canonical_uri)

    author_uri = atom.at_xpath('/xmlns:feed/xmlns:author/xmlns:uri')

    if author_uri.nil?
      owner      = atom.at_xpath('/xmlns:feed').at_xpath('./dfrn:owner', dfrn: DFRN_NS)
      author_uri = owner.at_xpath('./xmlns:uri') unless owner.nil?
    end

    @canonical_uri = author_uri.nil? ? nil : author_uri.content
  end

  def actor_json
    return @actor_json if defined?(@actor_json)

    json        = fetch_resource(actor_url, false)
    @actor_json = supported_context?(json) && json['type'] == 'Person' ? json : nil
  end
end
