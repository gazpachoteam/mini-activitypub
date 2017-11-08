module ActivityPub
  class Activity < ActivityStreams::Activity

    def initialize(attributes = {})
      _type_ = if self.class.superclass == Activity
        self.class.name.demodulize.camelize
      end
      attributes = {:type => _type_}.merge(attributes)
      super attributes
    end

    def self.factory(json, actor = nil)
      if actor.nil?
        actor = ActivityPub::Person.new(json['actor'].deep_symbolize_keys)
      end

      if json['type'] == 'Note'
        object = ActivityStreams::Object::Note.new(json.deep_symbolize_keys)

        activity = ActivityPub::Activity::Create.new(
          actor:  actor,
          object: object,
          published: Time.now.utc
        )
      end

      if json['type'] == 'Create'
        object = ActivityStreams::Object::Note.new(json['object'].deep_symbolize_keys)

        activity = ActivityPub::Activity::Create.new(
          actor:  actor,
          object: object,
          published: json['published'].to_time.utc
        )
      end
      activity
    end

    def delivery
      self.object.to.each do |recipient|
        inbox = ActivityPub::Helper.get_actor(recipient).inbox
        Faraday.post(
          "#{inbox}",
          self.to_json
        ).body
      end
    end
  end
end

Dir[File.dirname(__FILE__) + '/activity/*.rb'].each do |file|
  require_relative file
end
