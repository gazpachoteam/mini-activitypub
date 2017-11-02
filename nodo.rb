require 'sinatra'
require 'colorize'
require 'activitystreams'
require 'active_support/time'
require_relative 'helpers'
require_relative 'activity_pub'

PORT, USER_NAME = ARGV.first(2)
set :port, PORT

$ACTOR = ActivityStreams::Object::Person.new(
  id: "http://localhost:#{PORT}/@#{USER_NAME}",
  display_name: USER_NAME,
  inbox: "http://localhost:#{PORT}/inbox",
  outbox: "http://localhost:#{PORT}/outbox",
  followers: "http://localhost:#{PORT}/followers/",
  following: "http://localhost:#{PORT}/following/",
  likes: "http://localhost:#{PORT}/likes/"
)

$INBOX = ThreadSafe::Array.new
$OUTBOX = ThreadSafe::Array.new

every(3.seconds) do
  render_state
end

# @param user_name
get '/@?:user_name?' do
  return 'UserNotFound' if params[:user_name] != USER_NAME
  $ACTOR.to_json
end

# @param mensaje
# @param destinatarios
post '/outbox' do
  status = ActivityStreams::Object::Note.new(content: params[:mensaje])

  $OUTBOX << activity = ActivityStreams::Activity.new(
    actor: $ACTOR,
    object: status,
    verb: ActivityStreams::Verb::Post.new,
    published: Time.now.utc
  )

  unless params[:destinatarios].nil?
    ActivityPub.distribuir(
      activity,
      params[:destinatarios]
    )
  end

  "OK. Actividad agregada al outbox de #{$ACTOR.display_name}!"
end

# @param activity
post '/inbox' do
  data = JSON.parse params[:activity]
  status = ActivityStreams::Object::Note.new(
    content: data['object']['content']
  )
  actor = ActivityPub.get_actor(data['actor']['id'])
  activity = ActivityStreams::Activity.new(
    actor: actor,
    object: status,
    verb: ActivityStreams::Verb::Post.new,
    published: data['published'].to_time.utc
  )
  $INBOX << activity
end
