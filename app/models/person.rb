class Person < ActiveRecord::Base
  has_many :articles
  has_many :activities, inverse_of: :person, dependent: :destroy
  has_many :attention_requests, inverse_of: :person, dependent: :destroy

  has_many :active_relationships,  class_name: 'Follow', foreign_key: 'person_id',        dependent: :destroy
  has_many :passive_relationships, class_name: 'Follow', foreign_key: 'target_person_id', dependent: :destroy

  has_many :following, -> { order('follows.id desc') }, through: :active_relationships,  source: :target_person
  has_many :followers, -> { order('follows.id desc') }, through: :passive_relationships, source: :person

  def following?(other_person)
    active_relationships.where(target_person: other_person).exists?
  end

  def local?
    domain.nil?
  end

  def uri
    if domain.nil?
      "http://localhost:#{Sinatra::Application.settings.port}/@#{username}"
    else
      domain
    end
  end

  def self.get_or_create_person(actor)
    person = self.find_by_domain(actor.id.to_s)
    if person.nil?
      person = self.create!(
        username: actor.name,
        domain: actor.id.to_s
      )
    end
    person
  end

  def ap_json
    actor = ActivityPub::Person.new(
      id: "http://localhost:#{Sinatra::Application.settings.port}/@#{username}",
      name: username,
      inbox: "http://localhost:#{Sinatra::Application.settings.port}/@#{username}/inbox",
      outbox: "http://localhost:#{Sinatra::Application.settings.port}/@#{username}/outbox",
      followers: "http://localhost:#{Sinatra::Application.settings.port}/@#{username}/followers/",
      following: "http://localhost:#{Sinatra::Application.settings.port}/@#{username}/following/",
      likes: "http://localhost:#{Sinatra::Application.settings.port}/@#{username}/likes/"
    )
    actor.to_json
  end
end
