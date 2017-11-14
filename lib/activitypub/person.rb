module ActivityPub
  class Person < ActivityStreams::Object::Person
    attr_optional(
      :inbox,
      :outbox,
      :followers,
      :following,
      :likes
    )

    def initialize(attributes = {})
      _type_ = if self.class.superclass == ActivityStreams::Object::Person
        self.class.name.demodulize.camelize
      end
      attributes = {:type => _type_}.merge(attributes)
      super attributes
    end
  end
end
