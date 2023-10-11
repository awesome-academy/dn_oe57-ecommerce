class OrdersController < ApplicationController
  include CartHelper
  before_action :logged_in_user
  before_action :load_product_in_cart, :total_price, only: :create
  before_action :load_order, only: %i(show cancel)
  before_action :correct_user, only: :cancel

  def index
    @orders = current_user.orders.includes(:order_details).newest
  end

  def show; end

  def create
    ActiveRecord::Base.transaction do
      @order = current_user.orders.build order_params
      @order.save!
      create_order_detail @order
      update_quantity_products
    end
    clear_cart
    HardJob.perform_async @order.id
    flash[:success] = t("success")
    redirect_to root_path
  rescue ActiveRecord::RecordInvalid
    flash[:notice] = t("error")
    render "cart/index", status: :unprocessable_entity
  end

  def cancel
    ActiveRecord::Base.transaction do
      @order.canceled!
      return_quantity_products @order
      redirect_to orders_path, notice: t("order_has_been_cancelled")
    end
  rescue ActiveRecord::RecordInvalid
    flash[:notice] = t("error")
    render "orders/index", status: :unprocessable_entity
  end
  private
  def clear_cart
    session[:cart].clear
  end

  def order_params
    extracted_params = params.require(:order).permit(
      :reciver_name,
      :reciver_address,
      :reciver_phone,
      :status
    )
    extracted_params[:total_price] = @total_price
    extracted_params
  end

  def load_order
    @order = Order.includes(:order_details).find_by id: params[:id] || params[:order_id]
    return if @order

    flash[:danger] = t("order_not_found")
    redirect_to root_url
  end

  def logged_in_user
    return if logged_in?

    flash[:danger] = t("please_log_in")
    store_location
    redirect_to login_url
  end

  def create_order_detail order
    keys_session = session[:cart]&.keys&.map(&:to_i)
    @products = Product.find_id keys_session
    @order_details = []
    @products.each do |product|
      order_detail = OrderDetail.new(
        product:,
        order:,
        price_product: product.price,
        quantity_product: session[:cart][product.id.to_s]
      )
      @order_details << order_detail
    end
    @order_details.each(&:save!)
  end

  def update_quantity_products
    keys_session = session[:cart]&.keys&.map(&:to_i)
    @products = Product.find_id keys_session
    @products.each do |product|
      product.quantity = product.quantity - session[:cart][product.id.to_s]
    end
    @products.each(&:save!)
  end

  def return_quantity_products order
    @order_details = order.order_details
    @order_details.each do |order_detail|
      order_detail.product.quantity += order_detail.quantity_product
      order_detail.product.save!
    end
  end

  def correct_user
    @order = current_user.orders.find_by id: params[:order_id]
    return if @order

    flash[:danger] = t("order_invalid")
    redirect_to request.referer || root_url
  end
end
