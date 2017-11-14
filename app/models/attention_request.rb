class AttentionRequest < ActiveRecord::Base
  belongs_to :person
  belongs_to :from_person, class_name: 'Person'
  belongs_to :activity
end
