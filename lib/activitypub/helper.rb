module ActivityPub
  class Helper
    # @param id
    def self.get_actor(id)
      data = JSON.parse Faraday.get(id).body
      ActivityPub::Person.new(
        id: data['id'],
        display_name: data['display_name'],
        inbox: data['inbox'],
        outbox: data['outbox'],
        followers: data['followers'],
        following: data['following'],
        likes: data['likes']
      )
    end
  end
end
