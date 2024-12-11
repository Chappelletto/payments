module Api
  class PaymentScheduleController < ApplicationController
    def show
      authenticate!
      payment_schedule = PaymentSchedule.find_by(deal_id: params[:deal_id])
      if payment_schedule.present?
        render json: serialize_payment_schedule(payment_schedule)
      else
        render json: {error: "payment_schedule not found"}, status: 404
      end
    end

    def create
      authenticate!
      deal = Deal.find_by(id: params[:deal_id])
      if deal.nil?
        return render json: {error: "deal not found"}, status: 404
      end
      payment_schedule = PaymentSchedule.find_by(deal_id: params[:deal_id])

      if payment_schedule.present?
        return render json: {error: "payment schedule is already exist"}, status: 404
      end
      payment_schedule = PaymentSchedule.create!(payment_schedule_params)
      render json: serialize_payment_schedule(payment_schedule), status: 201
    end

    def delete
      authenticate!
      payment_schedule = PaymentSchedule.find_by(deal_id: params[:deal_id])

      if payment_schedule.present?
        PaymentSchedule.transaction do
          payment_schedule.payments.each(&:destroy!)
          payment_schedule.destroy!
        end
        render json: serialize_payment_schedule(payment_schedule)
      else
        render json: {error: "payment_schedule not found"}, status: 404
      end
    end

    def serialize_payment_schedule(payment_schedule)
      {id: payment_schedule.id, deal_id: payment_schedule.deal_id}
    end

    def payment_schedule_params
      params.permit(:id, :deal_id)
    end
  end
end
