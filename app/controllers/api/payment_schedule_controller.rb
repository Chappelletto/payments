module Api
  class PaymentScheduleController < ApplicationController
    def show
      payment_schedule = PaymentSchedule.find_by(deal_id: params[:deal_id])
      if payment_schedule.present?
        render json: serialize_payment_schedule(payment_schedule)
      else
        render json: {error: "payment_schedule not found"}, status: 404
      end
    end

    def create
      
    end

    def update

    end

    def delete

    end

    def serialize_payment_schedule(payment_schedule)
      {id: payment_schedule.id, deal_id: payment_schedule.deal_id}
    end

    def payment_schedule_params
      params.permit(:id, :deal_id)
    end
  end
end
