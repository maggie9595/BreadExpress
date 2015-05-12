class ItemPricesController < ApplicationController
  before_action :check_login
  authorize_resource

  def new
    @item_price = ItemPrice.new
  end

  def create
    @item_price = ItemPrice.new(item_price_params)
    @item_price.start_date = Date.today

    if @item_price.save
      redirect_to @item_price.item, notice: "The price for #{@item_price.item.name} has been updated."
    else
      redirect_to @item_price.item, notice: "Please try again."
    end
  end

  private
  def item_price_params
    params.require(:item_price).permit(:price, :start_date, :end_date, :item_id)
  end
end