module ActivityPub
  class Activity::Create < Activity

    def perform
      case object.type.to_s
      when 'Article'
        article = find_existing_article
        process_article if article.nil?
      end
      super
    end


    def process_article
        @actor = person_from_actor(actor)
        article = @actor.articles.create!(
          title: object.name,
          content: object.content,
          uri: object.id.to_s
        )
        # Updates the just created remote activity with it's remotes id
        article.activity.update_attributes(
          uri: id.to_s
        )
        @persisted_activity = article.activity
        article
    end

    def find_existing_article
      Article.find_by_uri(object.id.to_s)
    end
  end
end
