# frozen_string_literal: true

class FollowService < BaseService

  # Follow a remote user, notify remote user about the follow
  # @param [Account] source_account From which to follow
  # @param [String, Account] uri User URI to follow in the form of username@domain (or account record)
  # @param [true, false, nil] reblogs Whether or not to show reblogs, defaults to true
  def call(source_account, uri, reblogs: nil)
    reblogs = true if reblogs.nil?
    target_account = uri.is_a?(Account) ? uri : ResolveAccountService.new.call(uri)

    raise ActiveRecord::RecordNotFound if target_account.nil? || target_account.id == source_account.id #|| target_account.suspended?


    return if source_account.following?(target_account)

    request_follow(source_account, target_account)
  end

  private

  def request_follow(source_account, target_account)
    follow = Follow.create!(account: source_account, target_account: target_account)

    if target_account.local?
      #NotifyService.new.call(target_account, follow_request)
    else
      ActivityPub::DeliveryWorker.perform_async(build_json(follow), source_account.id, target_account.inbox_url)
    end

    follow
  end

  def build_json(follow_request)
    Oj.dump(ActivityPub::LinkedDataSignature.new(ActiveModelSerializers::SerializableResource.new(
      follow_request,
      serializer: ActivityPub::FollowSerializer,
      adapter: ActivityPub::Adapter
    ).as_json).sign!(follow_request.account))
  end
end
