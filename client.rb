require_relative 'lib/activitypub'
require 'faraday'

class Client
  def initialize(id)
    @user_id = id
  end

  def publish(title = '', content ='', recipients)
    article = ActivityStreams::Object::Article.new(
      name: title,
      content: content,
      to: recipients
    )

    outbox = ActivityPub::Helper.get_actor(@user_id).outbox

    Faraday.post(
      "#{outbox}",
      article.to_json
    ).body
  end

  def follow(target_user_id = '')
    return 'Target user id is required' if target_user_id.nil?

    data = JSON.parse ActivityPub::Helper.get_actor(target_user_id).to_json
    person = ActivityPub::Person.new(data.deep_symbolize_keys)

    outbox = ActivityPub::Helper.get_actor(@user_id).outbox

    Faraday.post(
      "#{outbox}",
      person.to_json
    ).body
  end
end
