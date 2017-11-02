require 'faraday'

class ActivityPub
  # @param nodo
  # @param activity
  # @param destinatarios
  def self.distribuir(activity, destinatarios)
    destinatarios.each do |destinatario|
      nodo = destinatario.split('@').last
      Faraday.post("#{nodo}/inbox", activity: activity.to_json).body
    end
  end

  # @param id
  def self.get_actor(id)
    data = JSON.parse Faraday.get(id).body
    ActivityStreams::Object::Person.new(
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
