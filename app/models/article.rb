class Article < ApplicationRecord
  belongs_to :account, inverse_of: :articles, required: true
  has_one :activity, as: :object

  validates_presence_of :title

  before_validation :set_local

  after_create do
    account.activities.create!(object: self, action: 'Create')
  end

  after_create_commit :store_uri, if: :local?

  private

  def store_uri
    update_attribute(:uri, "#{Rails.configuration.x.local_domain}/users/#{account.username}/articles/#{id}") if uri.nil?
  end

  def set_local
    self.local = account.local?
  end
end
