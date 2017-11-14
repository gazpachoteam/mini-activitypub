require 'activitystreams'

link = ActivityStreams::Object::Person.new(
  id: "http://joe.website.example/",
  type: "Person",
  name: "Joe Smith"
)

article = ActivityStreams::Object::Article.new(
  {
    name: 'Enviando un nuevo articulo',
    content: 'el contenido',
  }
)

actor = ActivityStreams::Object::Person.new(
  id: 'http://localhost:9999/inbox',
  name: 'manuel',
  inbox: "http://localhost:/inbox",
  outbox: "http://localhost:/outbox",
  followers: "http://localhost:/followers/",
  following: "http://localhost:/following/",
  likes: "http://localhost:/likes/"
)

activity = ActivityStreams::Activity::Like.new(
  :actor  => actor,
  :object => article,
  :published => Time.now.utc
)

puts article.to_json
