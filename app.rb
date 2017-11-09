require 'sinatra'
require "sinatra/activerecord"
require 'colorize'
require 'active_support/time'
require_relative 'helpers'
require_relative 'lib/activitypub'

require "./models.rb"

#PORT, USER_NAME = ARGV.first(2)
#set :port, PORT
set :database, "sqlite3:hanatachidb.sqlite3"

#actor = ActivityPub::Person.new(
#  id: "http://localhost:#{PORT}/@#{USER_NAME}",
#  name: USER_NAME,
#  inbox: "http://localhost:#{PORT}/inbox",
#  outbox: "http://localhost:#{PORT}/outbox",
#  followers: "http://localhost:#{PORT}/followers/",
#  following: "http://localhost:#{PORT}/following/",
#  likes: "http://localhost:#{PORT}/likes/"
#)

#inbox = ThreadSafe::Array.new
#outbox = ThreadSafe::Array.new

#every(3.seconds) do
#  render_state(actor, inbox, outbox)
#end

before do
  content_type 'application/json'
end

# @param username
get '/@:username' do
  person = Person.find_by_username!(params[:username])
  actor = ActivityPub::Person.new(
    id: "http://localhost:#{settings.port}/@#{person.username}",
    name: person.username,
    inbox: "http://localhost:#{settings.port}/@#{person.username}/inbox",
    outbox: "http://localhost:#{settings.port}/@#{person.username}/outbox",
    followers: "http://localhost:#{settings.port}/@#{person.username}/followers/",
    following: "http://localhost:#{settings.port}/@#{person.username}/following/",
    likes: "http://localhost:#{settings.port}/@#{person.username}/likes/"
  )
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
  activity.delivery
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
