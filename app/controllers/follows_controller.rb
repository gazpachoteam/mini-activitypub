class FollowsController < ApplicationController
  RESULTS_LIMIT = 1

  load_resource except: :create
  authorize_resource

  def index
    @account = current_account
  end

  def search
    results =  SearchService.new.call(
      params[:q],
      RESULTS_LIMIT,
      resolving_search?,
      current_account
    )

    if results[:accounts].nil?
      redirect_to follows_path
    end

    @account = results[:accounts].first
    render 'confirm'
  end

  def create
    raise ActiveRecord::RecordNotFound if follow_params[:uri].blank?

    @account = FollowService.new.call(current_user.account, target_uri).try(:target_account)

    if @account.nil?
      username, domain = target_uri.split('@')
      @account         = Account.find_remote!(username, domain)
    end

    redirect_to follows_path
  end

  private

  def target_uri
    follow_params[:uri].strip.gsub(/\A@/, '')
  end

  def follow_params
    params.permit(:uri)
  end

  def resolving_search?
    params[:resolve] == 'true'
  end
end
