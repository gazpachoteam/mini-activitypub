class Activity < ActiveRecord::Base

  belongs_to :person, inverse_of: :activities
  belongs_to :object, polymorphic: true
  belongs_to :articles, foreign_type: 'Articles', foreign_key: 'object_id', inverse_of: :activity
  has_many :attention_requests

  before_validation :set_local

  validates :person, :object, presence: true

  scope :recent, -> { reorder(id: :desc) }

  after_create_commit :store_uri, if: :local?

  private
  def store_uri
    update_attribute(:uri, "http://localhost:#{Sinatra::Application.settings.port}/activities/#{id}") if uri.nil?
  end

  def set_local
    self.local = person.local?
  end
end
