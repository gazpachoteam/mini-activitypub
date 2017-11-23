require 'sinatra'
require "sinatra/activerecord"
require 'colorize'
require 'active_support/time'
require_relative 'lib/activitypub'


# Models
Dir[File.dirname(__FILE__) + '/app/models/*.rb'].each do |file|
  require_relative file
end

set :database_file, 'config/database.yml'
set :public_folder, 'public'

before do
  content_type 'application/json'
end

# @param username
get '/@:username' do
  person = Person.find_by_username(params[:username])
  halt(404, { message:'Person Not Found'}.to_json) unless person
  person.ap_json
end

# @param body
# => {"@context": "https://www.w3.org/ns/activitystreams",
# =>  "type": "Article",
# =>  "to": ["https://chatty.example/ben/"],
# =>  "attributedTo": "https://social.example/alyssa/",
# =>  "content": "Say, did you finish reading that book I lent you?"
# => }
post '/@:username/outbox' do
  person = Person.find_by_username!(params[:username])
  json = request.body.read

  return status 400 if json.empty?

  data = JSON.parse json

  if data['type'] == 'Article'

    activity = {}
    activity['object'] = data
    activity['actor'] = JSON.parse person.ap_json
    activity['published'] = Time.now.utc

    activity = ActivityPub::Activity::Create.new(
      activity.to_json,
      person
    )
  end

  if data['type'] == 'Person'

    activity = {}
    activity['object'] = data
    activity['actor'] = JSON.parse person.ap_json
    activity['published'] = Time.now.utc

    activity = ActivityPub::Activity::Follow.new(
      activity.to_json,
      person
    )
  end

  return status 400 unless activity

  if activity.type.to_s == 'Create'
    if activity.object.type.to_s == 'Article'
      article = person.articles.create!(
        title: activity.object.name,
        content: activity.object.content
      )
      activity.id = article.activity.uri
      activity.object.id = article.uri
      activity
    else
      return status 400 # bad request
    end
  elsif activity.type.to_s == 'Follow'
    if ActivityPub::Helper.local_uri? activity.object.id.to_s
      # path_params = Rails.application.routes.recognize_path(uri)
      # Investigate how to make the same but in sintra
      target_person = Person.find_by_username!(activity.object.name)
    else
      target_person = Person.get_or_create_person(activity.object)
    end

    # Already following?
    return if person.following?(target_person)

    follow = Follow.create!(person: person, target_person: target_person)
    activity.id = follow.activity.uri
    activity.object.to << target_person.uri if !ActivityPub::Helper.local_uri? activity.object.id.to_s
  else
    return status 400
  end

  activity.delivery

  headers["Location"] = activity.id.to_s
  status 201 # Created
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
post '/@:username/inbox' do
  recipient = Person.find_by_username!(params[:username])
  json = request.body.read

  return status 400 if json.empty?

  activity = ActivityPub::Activity.factory(json, recipient)
  activity.perform
end


get '/:username/dashboard' do
  content_type 'text/html'
  erb :index
end
