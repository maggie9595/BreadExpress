class HomeController < ApplicationController
  include BreadExpressHelpers::Baking
  include BreadExpressHelpers::Cart

  before_action :set_cart_items

  def home
    if logged_in?
      if current_user.role?(:admin)
        @pending_orders = Order.not_shipped.chronological.paginate(:page => params[:page]).per_page(5)
        @recent_items = Item.all.order("updated_at DESC").alphabetical.paginate(:page => params[:page]).per_page(5)
        @new_users = User.all.order("created_at DESC").alphabetical.paginate(:page => params[:page]).per_page(5)
      elsif current_user.role?(:customer)
        @pending_orders = current_user.customer.orders.not_shipped.chronological.paginate(:page => params[:page]).per_page(5)
        @suggested_items = Item.active.alphabetical.paginate(:page => params[:page]).per_page(3)
      else
        # for bakers
        @bread_baking_list = create_baking_list_for("bread")
        @muffins_baking_list = create_baking_list_for("muffins")
        @pastries_baking_list = create_baking_list_for("pastries")
        # for shippers
        @shipping_list = Order.not_shipped.chronological.paginate(:page => params[:page]).per_page(10)
      end
    end
  end

  def cart
  	@subtotal = calculate_cart_items_cost
  end

  def mark_order_item_as_shipped
  end

  private
  def set_cart_items
  	if session[:cart].nil?
      create_cart
    end
    
  	@cart_items = get_list_of_items_in_cart
  end
end