class Admin::OrdersController < ApplicationController
  before_action :is_admin?
  before_action :load_order, only: %i(confirm cancel reason)
  before_action :check_status, only: %i(confirm cancel)

  def index
    @pagy, @orders = pagy(Order.newest, items: Settings.orders.number_of_page_5)
  end

  def confirm
    if @order.confirmed!
      UserMailer.confirm_order(@order).deliver_now
      redirect_to admin_orders_path, notice: t("order_has_been_confirmed")
    else
      flash[:notice] = t("error")
      render "admin/orders/index", status: :unprocessable_entity
    end
  end

  def reason; end

  def cancel
    ActiveRecord::Base.transaction do
      if params[:reason].present?
        @order.canceled!
        handle_after_cancel
        redirect_to admin_orders_path, notice: t("order_has_been_cancelled")
      else
        flash[:danger] = t("enter_reason")
        render "admin/orders/reason", status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid
    flash[:notice] = t("error")
    render "admin/orders/index", status: :unprocessable_entity
  end

  private

  def handle_after_cancel
    return_quantity_products @order
    UserMailer.cancel_order(@order, params[:reason]).deliver_now
  end

  def is_admin?
    return if current_user.is_admin

    redirect_to root_path
    flash[:danger] = t("not_admin")
  end

  def load_order
    @order = Order.find_by id: params[:order_id]
    return if @order

    flash[:danger] = t("order_not_found")
    redirect_to root_url
  end

  def return_quantity_products order
    @order_details = order.order_details

    @order_details.each do |order_detail|
      order_detail.product.quantity += order_detail.quantity_product
      order_detail.product.save!
    end
  end

  def check_status
    return if @order.awaiting?

    flash[:danger] = t("can_not_update_order")
    redirect_to admin_orders_path
  end
end
