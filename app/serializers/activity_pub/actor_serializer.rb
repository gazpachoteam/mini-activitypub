# frozen_string_literal: true

class ActivityPub::ActorSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :type, :following, :followers,
             :inbox, :outbox, :featured,
             :preferred_username, :name, :summary,
             :url

  has_one :public_key, serializer: ActivityPub::PublicKeySerializer

  class EndpointsSerializer < ActiveModel::Serializer
    include RoutingHelper

    attributes :shared_inbox

    def shared_inbox
      inbox_url
    end
  end

  has_one :endpoints, serializer: EndpointsSerializer

  #has_one :icon,  serializer: ActivityPub::ImageSerializer, if: :avatar_exists?
  #has_one :image, serializer: ActivityPub::ImageSerializer, if: :header_exists?

  def id
    account_url(object)
  end

  def type
    #object.bot? ? 'Service' : 'Person'
    'Person'
  end

  def following
    account_following_index_url(object)
  end

  def followers
    account_followers_url(object)
  end

  def inbox
    account_inbox_url(object)
  end

  def outbox
    account_outbox_url(object)
  end

  def featured
    account_collection_url(object, :featured)
  end

  def endpoints
    object
  end

  def preferred_username
    object.username
  end

  def name
    object.display_name
  end

  def summary
    Formatter.instance.simplified_format(object)
  end

  def icon
    object.avatar
  end

  def image
    object.header
  end

  def public_key
    object
  end

  def url
    short_account_url(object)
  end

  def avatar_exists?
    object.avatar.exists?
  end

  def header_exists?
    object.header.exists?
  end

  class Account::FieldSerializer < ActiveModel::Serializer
    attributes :type, :name, :value

    def type
      'PropertyValue'
    end

    def value
      Formatter.instance.format_field(object.account, object.value)
    end
  end
end