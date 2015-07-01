# https://github.com/ryanb/cancan/wiki/Defining-Abilities

class Ability
  include CanCan::Ability

  def initialize(user)
    # If a user is not logged they have no access
    return if user.nil?

    # I can do anything I want
    if user.email == 'mattforni@gmail.com'
      can :manage, :all and return
    end

    # All users can create and read stock models
    can [:create, :read], Stock

    # Users can only manage holding, position, portfolio and stop models they own
    can :manage, [Holding, Portfolio, Position, Stop], user_id: user.id
  end
end

