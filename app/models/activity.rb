class Activity < ApplicationRecord
  belongs_to :account, inverse_of: :activities
  belongs_to :object, polymorphic: true
  #belongs_to :articles, foreign_type: 'Articles', foreign_key: 'object_id', inverse_of: :activity

  before_validation :set_local

  validates :account, :object, presence: true

  scope :recent, -> { reorder(id: :desc) }

  after_create_commit :store_uri, if: :local?

  private
  def store_uri
    update_attribute(:uri, "#{Rails.configuration.x.local_domain}/activities/#{id}") if uri.nil?
  end

  def set_local
    self.local = account.local?
  end
end
