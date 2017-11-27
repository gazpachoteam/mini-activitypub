require_relative 'lib/activitypub'
require 'faraday'

class Client
  attr_reader :user_id

  def initialize(id)
    @user_id = id
  end

  def publish(status, recipients)
    status = ActivityStreams::Object::Note.new(
      content: status,
      to: recipients
    )

    outbox = ActivityPub::Helper.get_actor(@user_id).outbox

    Faraday.post(
      "#{outbox}",
      status.to_json
    ).body
  end
end
