module ActivityPub
  class Helper
    # @param id
    def self.get_actor(id)
      data = JSON.parse Faraday.get(id).body
      ActivityPub::Person.new(
        id: data['id'],
        name: data['name'],
        inbox: data['inbox'],
        outbox: data['outbox'],
        followers: data['followers'],
        following: data['following'],
        likes: data['likes']
      )
    end

    def self.audience(activity)
      # TODO Handle bcc, bto, audience, cc activity attributes
      activity.object.to.collect { |item| item.to_s }
    end

    def self.actor_to_resource(actor, model)
      if local_uri? actor.id.to_s
        model.find_by_username!(actor.name)
      else
        model.get_or_create_person(actor)
      end
    end


    def self.local_uri?(uri)
      uri  = Addressable::URI.parse(uri)
      host = uri.normalized_host
      host = "#{host}:#{uri.port}" if uri.port

      !host.nil? && self.local_domain?(host)
    end

    def self.local_domain?(domain)
      uri = Addressable::URI.parse("http://localhost:#{Sinatra::Application.settings.port}")
      host = uri.normalized_host
      host = "#{host}:#{uri.port}" if uri.port

      domain.nil? || domain.gsub(/[\/]/, '').casecmp(host.to_s).zero?
    end
  end
end
