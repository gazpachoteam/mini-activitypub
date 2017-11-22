class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Article # permissions for every user, even if not logged in
    if user.present?  # additional permissions for logged in users (they can manage their posts)
      can :manage, Follow, account_id: user.account.id
    end
  end
end
