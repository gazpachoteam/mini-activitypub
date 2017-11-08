module ActivityPub
  class Person < ActivityStreams::Object::Person
    attr_optional(
      :inbox,
      :outbox,
      :followers,
      :following,
      :likes
    )
  end
end
