class CustomersController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_action :check_login, except: [:new, :create]
  before_action :set_customer, only: [:show, :edit, :update, :destroy]
  authorize_resource
  
  def index
    @active_customers = Customer.active.alphabetical.paginate(:page => params[:page]).per_page(10)
    @inactive_customers = Customer.inactive.alphabetical.paginate(:page => params[:page]).per_page(10)
  end

  def show
    @previous_orders = @customer.orders.chronological
  end

  def new
    @customer = Customer.new
    @customer.build_user
  end

  def edit
    # reformat phone w/ dashes when displayed for editing (preference; not required)
    @customer.phone = number_to_phone(@customer.phone)
    # should have a user associated with customer, but just in case...

  end

  def create
    @customer = Customer.new(customer_params)
    # if a new customer account is created, set the user role to be customer by default.
    @customer.user.role = "customer"

    if @customer.save
      if logged_in?
        redirect_to @customer, notice: "#{@customer.proper_name} has been added to the system."
      else  
        # if a new customer account has just been created, automatically log them into the system.
        session[:user_id] = @customer.user_id
        redirect_to home_path, notice: "Welcome to Bread Express, #{@customer.proper_name}! Shop now!"
      end
    else
      render action: 'new'
    end
  end

  def update
    # just in case customer trying to hack the http request...
    reset_username_param unless current_user.role? :admin
    if @customer.update(customer_params)
      if logged_in? && current_user.role?(:admin)
        redirect_to @customer, notice: "#{@customer.user.username} has been successfully updated."
      else
        redirect_to @customer, notice: "Your account has been successfully updated."
      end
    else
      render action: 'edit'
    end
  end

  private
  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    if logged_in? 
      if (!current_user.role?(:admin) && !current_user.role?(:shipper) && !current_user.role?(:baker))
        reset_role_param
      end
    end
    params.require(:customer).permit(:first_name, :last_name, :email, :phone, :active, user_attributes: [:id, :username, :password, :password_confirmation, :role, :_destroy])
  end

  def reset_role_param
    params[:customer][:user_attributes][:role] = "customer"
  end

  def reset_username_param
    params[:customer][:user_attributes][:username] = @customer.user.username
  end
end