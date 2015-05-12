class OrdersController < ApplicationController
  include BreadExpressHelpers::Cart
  include BreadExpressHelpers::Shipping
  
  before_action :check_login
  before_action :set_order, only: [:show, :update, :destroy]
  authorize_resource
  
  def index
    if logged_in? && !current_user.role?(:customer)
      @pending_orders = Order.not_shipped.chronological.paginate(:page => params[:page]).per_page(5)
      @all_orders = Order.chronological.paginate(:page => params[:page]).per_page(5)
    else
      @pending_orders = current_user.customer.orders.not_shipped.chronological.paginate(:page => params[:page]).per_page(5)
      @all_orders = current_user.customer.orders.chronological.paginate(:page => params[:page]).per_page(5)
    end 
  end

  def show
    @order_items = @order.order_items.to_a
    # Other previous orders not including this order
    @other_previous_orders = @order.customer.orders.chronological.to_a.delete_if{|order| order == @order}
    @previous_orders = @order.customer.orders.chronological.to_a
  end

  def new
    @order = Order.new
    @shipping_cost = calculate_cart_shipping
    @order.grand_total = calculate_cart_items_cost + @shipping_cost
  end

  def create
    @order = Order.new(order_params)
    @order.date = Date.today
    @order.grand_total = calculate_cart_items_cost + calculate_cart_shipping
    
    if @order.save
      if @order.pay
        save_each_item_in_cart(@order)
        clear_cart
        if current_user.role?(:customer)
          redirect_to @order, notice: "Your order has been successfully submitted! Thank you for ordering from Bread Express."
        else
          redirect_to @order, notice: "You have successfully submitted the order below for #{@order.customer.proper_name}."  
        end
      end
    else
      render action: 'new'
    end
  end

  def update
    if @order.update(order_params)
      redirect_to @order, notice: "Your order was revised in the system."
    else
      render action: 'edit'
    end
  end

  def destroy
    @order.destroy
    redirect_to orders_url, notice: "This order was removed from the system."
  end

  # ORDERS CANNOT BE EDITED

  private
  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params[:order][:expiration_month] = params[:order][:expiration_month].to_i
    params[:order][:expiration_year] = params[:order][:expiration_year].to_i
    params.require(:order).permit(:customer_id, :address_id, :credit_card_number, :expiration_month, :expiration_year)
  end
end