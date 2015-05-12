class ItemsController < ApplicationController
  before_action :check_login, only: [:edit, :update, :destroy]
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  authorize_resource
  
  def index
    # Employees can see active and inactive items
    if logged_in? && !current_user.role?(:customer)
      @inactive_items = Item.inactive.alphabetical.paginate(:page => params[:page]).per_page(9)
    end
    # Guests and customers can only see active items
    @active_items = Item.active.alphabetical.paginate(:page => params[:page]).per_page(9)
  end

  def show
    @similar_items = Item.for_category(@item.category).active.alphabetical.delete_if{|item| item == @item}
    @price_history = ItemPrice.for_item(@item).chronological.paginate(:page => params[:page]).per_page(5)
    # New item price object for admin use when updating the current price of the item
    @item_price = ItemPrice.new
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(item_params)

    if @item.save
      redirect_to @item, notice: "#{@item.name} was added to the system."
    else
      render action: 'new'
    end
  end

  def update
    if @item.update(item_params)
      redirect_to @item, notice: "#{@item.name} was revised in the system."
    else
      render action: 'edit'
    end
  end

  def destroy
    if @item.destroy
      redirect_to items_url, notice: "The item was removed from the system."
    else
      redirect_to @item, notice: "#{@item.name} could not be deleted because it has already shipped to a customer so it has been made inactive instead."
    end
  end

  private
  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :description, :picture, :category, :units_per_item, :weight, :active)
  end

end