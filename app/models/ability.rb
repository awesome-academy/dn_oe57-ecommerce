# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize user, controller_namespace
    return if user.nil?

    case controller_namespace
    when "Admin"
      can :manage, :all if user.is_admin?
    else
      if user.is_admin?
        can :manage, :all
      else
        can :manage, Order, user_id: user.id
        can :create, Feedback
        can :read, Product
        can :manage, :cart
      end
    end
  end
end
