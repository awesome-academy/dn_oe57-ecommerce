class FeedbacksController < ApplicationController
  load_and_authorize_resource

  before_action :find_product, only: %i(new create)

  def new
    @feedback = current_user.feedbacks.new
  end

  def create
    ActiveRecord::Base.transaction do
      @feedback = current_user.feedbacks.build feedback_params
      @feedback.save!
      update_rating_product @product
      flash[:success] = t("success")
      redirect_to @product
    end
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  private

  def feedback_params
    extracted_params = params.require(:feedback).permit(
      :content,
      :rating,
      :product_id
    )
  end

  def find_product
    @product = Product.find_by(
      id: params.dig(:feedback, :product_id) || params[:product_id]
    )
    return if @product

    flash[:danger] = t("product_not_found")
    redirect_to root_url
  end

  def update_rating_product product
    rating_feedback = Feedback.filter_by_product_id(product.id)
    average_rating = rating_feedback.average(:rating).round(0)
    product.rating = average_rating
    product.save!
  end
end
