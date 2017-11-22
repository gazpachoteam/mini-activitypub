class Follow < ApplicationRecord
  has_one :activity, as: :object

  belongs_to :account, required: true
  belongs_to :target_account, class_name: 'Account', required: true

  validates :account_id, uniqueness: { scope: :target_account_id }

  scope :recent, -> { reorder(id: :desc) }

  after_create do
    account.activities.create!(object: self, action: 'Follow')
  end
end
