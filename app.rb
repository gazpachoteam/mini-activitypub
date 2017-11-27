require 'bundler/setup'
require 'sinatra'
require 'colorize'
require 'active_support/time'
require_relative 'helpers'
require_relative 'lib/activitypub'

PORT, USER_NAME = ARGV.first(2)
set :port, PORT

actor = ActivityPub::Person.new(
  id: "http://localhost:#{PORT}/@#{USER_NAME}",
  name: USER_NAME,
  inbox: "http://localhost:#{PORT}/inbox",
  outbox: "http://localhost:#{PORT}/outbox",
  followers: "http://localhost:#{PORT}/followers/",
  following: "http://localhost:#{PORT}/following/",
  likes: "http://localhost:#{PORT}/likes/"
)

inbox = ThreadSafe::Array.new
outbox = ThreadSafe::Array.new

every(3.seconds) do
  render_state(actor, inbox, outbox)
end

# example: http://localhost:1111/@bob
# @param user_name
get '/@:user_name' do
  content_type :json
  return 'UserNotFound' if params[:user_name] != USER_NAME
  actor.to_json
end

# @param body
# => {"@context": "https://www.w3.org/ns/activitystreams",
# =>  "type": "Note",
# =>  "to": ["https://chatty.example/ben/"],
# =>  "attributedTo": "https://social.example/alyssa/",
# =>  "content": "Say, did you finish reading that book I lent you?"
# => }
post '/outbox' do
  data = JSON.parse(request.body.read)
  activity = ActivityPub::Activity.factory(data, actor)
  outbox << activity
  activity.delivery # envía una petición post a los destinatarios
  "OK. Actividad agregada al outbox de #{actor.name}!"
end

# @param body
# => {"@context": "https://www.w3.org/ns/activitystreams",
# =>  "type": "Create",
# =>  "id": "https://social.example/alyssa/posts/a29a6843-9feb-4c74-a7f7-081b9c9201d3",
# =>  "to": ["https://chatty.example/ben/"],
# =>  "author": "https://social.example/alyssa/",
# =>  "object": {"type": "Note",
# =>             "id": "https://social.example/alyssa/posts/49e2d03d-b53a-4c4c-a95c-94a6abf45a19",
# =>             "attributedTo": "https://social.example/alyssa/",
# =>             "to": ["https://chatty.example/ben/"],
# =>             "content": "Say, did you finish reading that book I lent you?"}
# => }
post '/inbox' do
  data = JSON.parse(request.body.read)
  activity = ActivityPub::Activity.factory(data)
  inbox << activity
end
