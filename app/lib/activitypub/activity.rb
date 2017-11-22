module ActivityPub
  class Activity < ActivityStreams::Activity

    def initialize(json, recipient, options = {})
      attributes = {}
      _type_ = if self.class.superclass == Activity
        self.class.name.demodulize.camelize
      end
      attributes = {:type => _type_}.merge(attributes)

      @recipient = recipient
      @json = JSON.parse json

      # actor attributes
      actor = @json['actor']
      attributes = {
        :actor => ActivityPub::Person.new(actor.deep_symbolize_keys)
      }.merge(attributes)

      # object attributes
      object = @json['object']
      case object['type']
      when 'Article'
        object = ActivityStreams::Object::Article.new(object.deep_symbolize_keys)
      when 'Person'
        object = ActivityPub::Person.new(object.deep_symbolize_keys)
      else
        raise Exception.new("Invalid object type")
      end

      attributes = {:object => object }.merge(attributes)
      attributes = {:id => @json['id'] }.merge(attributes)
      attributes = {:published => @json['published'].to_time.utc }.merge(attributes)
      super attributes
    end

    def perform
      process_attention_request if ActivityPub::Helper.audience(self).include? @recipient.uri
    end

    class << self
      def factory(json, recipient, options = {})
        @json = JSON.parse json
        klass&.new(json, recipient, options)
      end

      private

      def klass
        case @json['type']
        when 'Create'
          ActivityPub::Activity::Create
        when 'Follow'
          ActivityPub::Activity::Follow
        end
      end
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

    def person_from_actor(actor, model = ActiveRecord::Base::Person)
      ActivityPub::Helper.actor_to_resource(actor, model)
    end

    def process_attention_request
      @recipient.attention_requests.create!(
        activity: @persisted_activity,
        from_person: @actor
      )
    end
  end
end

Dir[File.dirname(__FILE__) + '/activity/*.rb'].each do |file|
  require_relative file
end
