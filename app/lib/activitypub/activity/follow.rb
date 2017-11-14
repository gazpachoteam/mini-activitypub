module ActivityPub
  class Activity::Follow < Activity
    def perform
      @actor = person_from_actor(actor)
      @target_person = person_from_actor(object)

      # Already following?
      return if @actor.following?(@target_person)
      process_follow
      super
    end


    def process_follow
      follow = ActiveRecord::Base::Follow.create!(person: @actor, target_person: @target_person)
      follow.activity.update_attributes(
        uri: id.to_s
      )
      @persisted_activity = follow.activity
      follow
    end
  end
end
