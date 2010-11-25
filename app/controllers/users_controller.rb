class UsersController < ApplicationController
  before_filter :authenticate, :except => [:show, :new, :create]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user,   :only => :destroy

  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name
  end

  def new
    @user = User.new
    @title = 'Sign up'
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      @title = "Sign up"
      render 'new'
    end
  end

  def edit
    @title = "Edit user"
  end

  def update
    if params[:commit] =~ /unfollow/i
      follow = User.find(params[:user][:unfollow_id])
      if follow and current_user.unfollow! follow
        respond_to do |format|
          format.html do
            flash[:success] = "You don't follow #{follow.name} anymore."
            redirect_to follow
          end
          format.js { render 'destroy.follow', :locals => { :follow_user => follow } }
        end
      else
        flash[:error] = "An occoured an error."
        redirect_to user
      end
      return
    elsif params[:commit] =~ /follow/i
      follow = User.find(params[:user][:follow_id])
      if follow and current_user.follow! follow
        respond_to do |format|
          format.html do
            flash[:success] = "You follow #{follow.name} from now on."
            redirect_to follow
          end
          format.js { render 'create.follow', :locals => { :follow_user => follow } }
        end
      else
        flash[:error] = "An occoured an error."
        redirect_to user
      end
      return
    end

    unless params[:user][:password].nil? or params[:user][:password].empty?
      @user.updating_password = true
    end
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_path
  end


  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
  end

  private

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_path) unless  current_user.admin?
  end
end
