class Person < ActiveRecord::Base
  has_many :articles
  has_many :activities, inverse_of: :person, dependent: :destroy

  def local?
    domain.nil?
  end

  def save_activity(activity)
    case activity.type.to_s
    when 'Create'
      case activity.object.type.to_s
      when 'Article'
        article = articles.create!(
          content: activity.object.content
        )
        activity.object.id = article.uri
        activity
      else
        # code
      end
    when 'Follow'
    else
    end
    activity
  end

  def save_remote_activity(activity)
    case activity.type.to_s
    when 'Create'
      case activity.object.type.to_s
      when 'Article'
        article = Article.find_by_uri(activity.object.id.to_s)
        if article.nil?
          article = articles.create!(
            content: activity.object.content,
            uri: activity.object.id.to_s
          )
        end
      else
        # code
      end
    when 'Follow'
    else
    end
    activity
  end

  def self.get_or_create_person(activity)
    person = self.find_by_domain(activity.actor.id.to_s)
    if person.nil?
      person = self.create!(
        username: activity.actor.name,
        domain: activity.actor.id.to_s
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

class Article < ActiveRecord::Base
  belongs_to :person
  has_one :activity, as: :object

  before_validation :set_local

  after_create do
    person.activities.create!(object: self) if needs_activity_entry?
  end

  after_create_commit :store_uri

  def needs_activity_entry?
    person.local?
  end

  private

  def store_uri
    update_attribute(:uri, "http://localhost:#{Sinatra::Application.settings.port}/users/#{person.username}/notes/#{id}") if uri.nil?
  end

  def set_local
    self.local = person.local?
  end
end

class Activity < ActiveRecord::Base

  belongs_to :person, inverse_of: :activities
  belongs_to :object, polymorphic: true
  belongs_to :articles, foreign_type: 'Articles', foreign_key: 'object_id', inverse_of: :activity

  validates :person, :object, presence: true

  scope :recent, -> { reorder(id: :desc) }

  after_create_commit :store_uri

  private
  def store_uri
    update_attribute(:uri, "http://localhost:#{Sinatra::Application.settings.port}/activities/#{id}") if uri.nil?
  end
end
