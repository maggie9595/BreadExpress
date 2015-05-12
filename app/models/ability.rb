class Ability
  include CanCan::Ability
  
  def initialize(user)
    # set user to new User if not logged in
    user ||= User.new # i.e., a guest user
    
    # set authorizations for different user roles
    if user.role? :admin
      # they get to do it all
      can :manage, :all

    elsif user.role? :shipper 
      # can see a list of all users
      can :index, User

      # can see a list of all items
      can :index, Item
      
      can :read, Item
      
      # they can read their own profile
      can :show, User do |u|  
        u.id == user.id
      end

      # they can update their own profile
      can :update, User do |u|  
        u.id == user.id
      end

      can :read, Address

    elsif user.role? :baker
    	# can see a list of all users
      can :index, User

      # can see a list of all items
      can :index, Item
      
      can :read, Item

      # they can read their own profile
      can :show, User do |u|  
        u.id == user.id
      end

      # they can update their own profile
      can :update, User do |u|  
        u.id == user.id
      end
      	
    elsif user.role? :customer
      # they can read their own profile
      can :show, User do |u|  
        u.id == user.id
      end
      can :show, Customer do |c|  
        c.id == user.customer.id
      end

      # they can update their own profile
      can :update, User do |u|  
        u.id == user.id
      end
      can :update, Customer do |c|  
        c.id == user.customer.id
      end

      # they can see the a list of their addresses
      can :index, Address

      # they can create addresses
      can :create, Address

      # they can see their own addresses
      can :show, Address do |this_address|  
        my_addresses = user.customer.addresses.map(&:id)
        my_addresses.include? this_address.id 
      end

      # they can update their own addresses
      can :update, Address do |this_address|  
        my_addresses = user.customer.addresses.map(&:id)
        my_addresses.include? this_address.id 
      end

      # they can delete their own addresses
      can :destroy, Address do |this_address|  
        my_addresses = user.customer.addresses.map(&:id)
        my_addresses.include? this_address.id 
      end

      # they can see the list of their past orders
      can :index, Order

      # they can place a new order
      can :create, Order

      # they can see their own orders
      can :show, Order do |this_order|  
        my_orders = user.customer.orders.map(&:id)
        my_orders.include? this_order.id 
      end
      
      # can see a list of all items
      can :index, Item

      # can read items
      can :read, Item

    else # guests
      # can see a list of all items
      can :index, Item

      # can read items
      can :read, Item
     
     	# can create new customer (along with its user account)
     	can :create, Customer
     	can :create, User
    end
  end
end