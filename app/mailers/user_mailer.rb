class UserMailer < ApplicationMailer
  def notice_to_user order_id
    @order = Order.find_by id: order_id
    if @order.present?
      mail(to: @order.user_email, subject: "Confirmed Order")
    else
      logger.error "Error for send email notice"
    end
  end
end
