class UsersController < ApplicationController
  before_action :check_login, only: [:edit, :update]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  authorize_resource

  def new
    @user = User.new
  end

  def edit
    # @user = current_user
  end

  def show
  end

  def index
    @active_employees = User.employees.active.by_role.alphabetical.paginate(:page => params[:page]).per_page(10)
    @inactive_employees = User.employees.inactive.by_role.alphabetical.paginate(:page => params[:page]).per_page(10)
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: "#{@user.username} has been added to the system."
    else
      flash[:error] = "This user could not be created."
      render "new"
    end
  end

  def update
    # @user = current_user
    if @user.update_attributes(user_params)
      if @user == current_user
        # Show a different message if an admin is editing his/her own account.
        flash[:notice] = "Your account has been successfully updated."
      else
        flash[:notice] = "#{@user.username} has been successfully updated."
      end
      redirect_to @user
    else
      render :action => 'edit'
    end
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation, :role, :active)  
  end
end