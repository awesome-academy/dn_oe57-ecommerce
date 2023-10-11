class UserMailer < ApplicationMailer
  def notice_to_user order_id
    @order = Order.find_by id: order_id
    if @order.present?
      mail(to: @order.user_email, subject: "Confirmed Order")
    else
      logger.error "Error for send email notice"
    end
  end

  def confirm_order order
    @order = order

    mail(to: @order.user.email, subject: "Confirmed Order")
  end

  def cancel_order order, reason
    @order = order
    @reason = reason

    mail(to: @order.user.email, subject: "Canceled Order")
  end
end
