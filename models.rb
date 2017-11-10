require 'byebug'
class Person < ActiveRecord::Base
  has_many :notes
  has_many :stream_entries, inverse_of: :person, dependent: :destroy

  def local?
    domain.nil?
  end

  def save_activity(activity)
    byebug
    case activity.type.to_s
    when 'Create'
      note = notes.create!(
        content: activity.object.content
      )
      activity.object.id = note.uri
      activity
    when 'Follow'
    else
    end
    activity
  end

  def save_remote_activity(activity)
    case activity.type.to_s
    when 'Create'
      note = Note.find_by_uri(activity.object.id.to_s)
      if note.nil?
        note = notes.create!(
          content: activity.object.content,
          uri: activity.object.id.to_s
        )
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

class Note < ActiveRecord::Base
  belongs_to :person
  has_one :stream_entry, as: :activity

  before_validation :set_local

  after_create do
    person.stream_entries.create!(activity: self) if needs_stream_entry?
  end

  after_create_commit :store_uri, if: :local?

  def needs_stream_entry?
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

class StreamEntry < ActiveRecord::Base

  belongs_to :person, inverse_of: :stream_entries
  belongs_to :activity, polymorphic: true
  belongs_to :notes, foreign_type: 'Notes', foreign_key: 'activity_id', inverse_of: :stream_entry

  validates :person, :activity, presence: true

  scope :recent, -> { reorder(id: :desc) }

end
