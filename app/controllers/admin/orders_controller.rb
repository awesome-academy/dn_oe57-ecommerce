class Admin::OrdersController < ApplicationController
  before_action :is_admin?
  before_action :load_orders, only: %i(batch_confirm batch_cancel)

  def index
    @pagy, @orders = pagy(Order.newest, items: Settings.orders.number_of_page_5)
  end

  def batch_confirm
    @orders.find_in_batches do |batch|
      batch.each do |order|
        handle_batch_confirm order
      end
    end
    flash[:success] = t("update_order_success")
    redirect_to admin_orders_path
  end

  def batch_cancel
    reason = params[:reason]

    @orders.find_in_batches do |batch|
      batch.each do |order|
        ActiveRecord::Base.transaction do
          order.canceled!
          handle_after_cancel order, reason
        end
      rescue ActiveRecord::RecordInvalid
        flash[:notice] = t("error")
        render "admin/orders/index", status: :unprocessable_entity
      end
    end

    respond_to do |format|
      format.json{render json: @orders}
    end
  end

  private

  def handle_batch_confirm order
    if order.confirmed!
      UserMailer.confirm_order(order).deliver_now
    else
      flash[:notice] = t("confirm_error")
      render "admin/orders/index", status: :unprocessable_entity
    end
  end

  def handle_after_cancel order, reason
    return_quantity_products order
    UserMailer.cancel_order(order, reason).deliver_now
  end

  def load_orders
    selected_order_ids = params[:order_ids] || params[:selectedOrderIds]
    @orders = Order.where(id: selected_order_ids, status: "awaiting")
    return if @orders.present?

    redirect_to admin_orders_path
    flash[:error] = t("no_order_selected")
  end

  def is_admin?
    return if current_user.is_admin

    redirect_to root_path
    flash[:danger] = t("not_admin")
  end

  def return_quantity_products order
    @order_details = order.order_details

    @order_details.each do |order_detail|
      order_detail.product.quantity += order_detail.quantity_product
      order_detail.product.save!
    end
  end
end
