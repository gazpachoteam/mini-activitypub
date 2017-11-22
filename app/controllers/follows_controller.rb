class FollowsController < ApplicationController
  RESULTS_LIMIT = 1

  load_and_authorize_resource

  def index
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

  def resolving_search?
    params[:resolve] == 'true'
  end
end
