module Api
  class DealsController < ApplicationController
    def index
      authenticate!

      deals = Deal.all

      if params[:status].present?
        deals = deals.where(status: params[:status])
      end
      if params[:created_after].present?
        deals = deals.where("created_at > ?", params[:created_after])
      end
      if params[:order_created_at].present?
        deals = deals.order(created_at: params[:order_created_at])
      end

      list = deals.map { |deal| serialize_deal(deal) }
      render json: list
    end

    def show
      authenticate!

      deal = Deal.find_by(id: params[:id])

      if deal.present?
        render json: serialize_deal(deal)
      else
        render json: {error: "deal not found"}, status: 404
      end
    end

    def create
      authenticate!

      validation_result = Api::CreateDealValidator.new.call(deal_params.to_h)
      if validation_result.failure?
        return render json: {errors: validation_result.errors.to_h}, status: 400
      end

      Deal.all.each do |deal|
        pp "===================="
        pp deal
        pp deal.contract_number
        if deal.contract_number == deal_params.to_h[:contract_number]
          render json: {error: "contract_number should be uniq"}, status: 404
        end
      end

      deal = Deal.create!(validation_result.to_h)
      render json: serialize_deal(deal), status: 201
    end

    def update
      authenticate!

      validation_result = Api::UpdateDealValidator.new.call(deal_params.to_h)
      if validation_result.failure?
        return render json: {errors: validation_result.errors.to_h}, status: 400
      end
      deal = Deal.find_by(id: params[:id])

      if deal.present?
        deal.update!(deal_params)
        render json: serialize_deal(deal)
      else
        render json: {error: "deal not found"}, status: 404
      end
    end

    def delete
      authenticate!

      deal = Deal.find_by(id: params[:id])

      if deal.present?
        Deal.transaction do
          deal.payment_schedule&.payments&.each(&:destroy!)
          deal.payment_schedule&.destroy!
          deal.destroy!
        end
        render json: serialize_deal(deal)
      else
        render json: {error: "deal not found"}, status: 404
      end
    end

    def serialize_deal(deal)
      {contract_number: deal.contract_number, status: deal.status, id: deal.id}
    end

    def deal_params
      params.permit(:contract_number, :status)
    end
  end
end
