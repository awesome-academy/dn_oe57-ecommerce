class HardJob
  include Sidekiq::Job
  sidekiq_options retry_max: 5, retry: false

  def perform order_id
    UserMailer.notice_to_user(order_id).deliver_now
  end
end
