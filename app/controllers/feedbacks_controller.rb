class FeedbacksController < ApplicationController
  before_action :logged_in_user
  before_action :find_product, only: %i(new create)
  before_action :load_feedback, only: :create

  def new
    @feedback = current_user.feedbacks.new
  end

  def create
    ActiveRecord::Base.transaction do
      @feedback.save!
      update_rating_product @product
      flash[:success] = t("success")
      redirect_to @product
    end
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  private

  def load_feedback
    @feedback = current_user.feedbacks.new(
      product: @product,
      content: params[:feedback][:content],
      rating: params[:feedback][:rating]
    )
    return if @feedback

    flash[:danger] = t("feedback_not_found")
    redirect_to root_url
  end

  def find_product
    @product = Product.find_by(id: params.dig(:feedback,
                                              :product_id) || params[:product_id])
    return if @product

    flash[:danger] = t("product_not_found")
    redirect_to root_url
  end

  def logged_in_user
    return if logged_in?

    flash[:danger] = t("please_log_in")
    store_location
    redirect_to login_url
  end

  def update_rating_product product
    rating_feedback = Feedback.filter_by_product_id(product.id)
    average_rating = rating_feedback.average(:rating).round(0)
    product.rating = average_rating
    product.save!
  end
end
