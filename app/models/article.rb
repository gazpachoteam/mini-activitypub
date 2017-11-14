class Article < ActiveRecord::Base
  belongs_to :person
  has_one :activity, as: :object

  validates_presence_of :title

  before_validation :set_local

  after_create do
    person.activities.create!(object: self, action: 'Create')
  end

  after_create_commit :store_uri, if: :local?

  private

  def store_uri
    update_attribute(:uri, "http://localhost:#{Sinatra::Application.settings.port}/users/#{person.username}/notes/#{id}") if uri.nil?
  end

  def set_local
    self.local = person.local?
  end
end
