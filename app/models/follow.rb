class Follow < ActiveRecord::Base
  has_one :activity, as: :object

  belongs_to :person, required: true
  belongs_to :target_person, class_name: 'Person', required: true

  validates :person_id, uniqueness: { scope: :target_person_id }

  scope :recent, -> { reorder(id: :desc) }

  after_create do
    person.activities.create!(object: self, action: 'Follow')
  end
end
