module Api
  class PaymentsController < ApplicationController
    def index
      payments = Payment.all
      list = payments.map { |payment| serialize_payment(payment) }
      render json: list
    end

    def show
      payment = Payment.find_by(id: params[:id])

      if payment.present?
        render json: serialize_payment(payment)
      else
        render json: {error: "payment not found"}, status: 404
      end
    end

    def create
      validation_result = Api::CreatePaymentValidator.new.call(payment_params.to_h)
      if validation_result.failure?
        return render json: {errors: validation_result.errors.to_h}, status: 400
      end

      deal = Deal.find_by(id: params[:deal_id])
      if deal.nil?
        return render json: {error: "deal not found"}, status: 404
      end
      if deal.payment_schedule.nil?
        return render json: {error: "payments schedule not found"}, status: 404
      end

      payment = Payment.create!(
        # как работает пермит
        validation_result.to_h.merge(payment_schedule: deal.payment_schedule)
      )
      render json: serialize_payment(payment), status: 201
    end

    def update
      validation_result = Api::UpdatePaymentValidator.new.call(payment_params.to_h)
      if validation_result.failure?
        return render json: {errors: validation_result.errors.to_h}, status: 400
      end
      payment = Payment.find_by(id: params[:id])

      if payment.present?
        payment.update!(payment_params)
        render json: serialize_payment(payment)
      else
        render json: {error: "payment not found"}, status: 404
      end
    end

    def delete
      payment = Payment.find_by(id: params[:id])

      if payment.present?
        payment.destroy!
        render json: serialize_payment(payment)
      else
        render json: {error: "payment not found"}, status: 404
      end
    end

    def pay
      payment = Payment.find_by(id: params[:id])
      if payment.present?
        PerformPaymentJob.perform_async(payment.id)
        render json: serialize_payment(payment)
      else
        render json: {error: "payment not found"}, status: 404
      end
    end

    private

    def serialize_payment(payment)
      {amount: payment.amount, status: payment.status, date: payment.date, id: payment.id}
    end

    def payment_params
      params.permit(:amount, :date, :status)
    end
  end
end
