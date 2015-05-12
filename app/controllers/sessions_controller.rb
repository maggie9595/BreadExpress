class SessionsController < ApplicationController
  include BreadExpressHelpers::Cart
  before_action :set_item, only: [:add_item, :remove_item, :remove_one_of_item]

  def new
    if session[:cart].nil?
      create_cart
    end
  end
  
  def create
    if session[:cart].nil?
      create_cart
    end
    
    user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_url, notice: "Logged in!"
    else
      flash.now.alert = "Email or password is invalid"
      render "new"
    end
  end
  
  def destroy
    session[:user_id] = nil
    session[:cart] = nil
    redirect_to root_url, notice: "Logged out!"
  end

  def add_item
    if session[:cart].nil?
      create_cart
    end
    add_item_to_cart(@item.id)
    redirect_to cart_path, notice: "1 #{@item.name} was added to your cart."
  end

  def remove_item
    remove_item_from_cart(@item.id)
    redirect_to cart_path, notice: "#{@item.name} has been removed from your cart."
  end

  def remove_one_of_item
    remove_one_of_item_from_cart(@item.id)
    redirect_to cart_path, notice: "1 #{@item.name} has been removed from your cart."
  end

  private
  def set_item
    @item = Item.find(params[:id])
  end
end