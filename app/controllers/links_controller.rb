class LinksController < ApplicationController
  before_action :login_required, only: [:edit, :update, :destroy]
  before_action :set_link, only: [:edit, :update, :destroy]

  def new
    @link = Link.new
  end

  def index
    @links = Link.all
    @popular = Link.where("clicks >= ?", 1).order(clicks: :desc)
    @recent = Link.order(created_at: :desc)
    @top_users = User.top_users
    @user_links = current_user.links.order(created_at: :desc) if logged_in?
  end

  def create
    @link = Link.new(url_params)
    @link.user_id = current_user.id if logged_in?
    @link.save
    respond_to :js
  end

  def update
    @link.update(url_params)
    @user_links = current_user.links.order(created_at: :desc)
    respond_to :js
  end

  def destroy
    @link.destroy
    respond_to :js
  end

  def redirect_to_actual_link
    (link = Link.find_by(vanity_string: params[:vanity_string])) || not_found
    render(:index) && return if link.ours?
    if link.active?
      redirect_to link.actual, status: 302
      link.increment_clicks
    elsif link.inactive?
      render :inactive_page
    else
      render :deleted_page
    end
  end

  def check_vanity_string
    exists = Link.exists?(vanity_string: params[:vanity_string_])
    respond_to do |format|
      format.json { render json: { exists:  exists } }
    end
  end

  def not_found
    raise ActiveRecord::RecordNotFound.new("Not Found")
  end

  def inactive_page
  end

  def deleted_page
  end

  private

  def set_link
    @link = Link.find(params[:id])
  end

  def url_params
    params.require(:link).permit(:actual, :vanity_string, :active)
  end
end