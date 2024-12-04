module Api
  class DealsController < ApplicationController
    def index
      # if request.headers["HTTP_X_AUTH_TOKEN"].nil?
      #   return render json: {error: "auth token not found"}, status: 401
      # end
      # if request.headers["HTTP_X_AUTH_TOKEN"] != "api-token"
      #   return render json: {error: "auth token invalid"}, status: 401
      # end

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
      deal = Deal.find_by(id: params[:id])

      if deal.present?
        render json: serialize_deal(deal)
      else
        render json: {error: "deal not found"}, status: 404
      end
    end

    def create
      validation_result = Api::CreateDealValidator.new.call(deal_params.to_h)
      if validation_result.failure?
        return render json: {errors: validation_result.errors.to_h}, status: 400
      end

      deal = Deal.create!(validation_result.to_h)
      render json: serialize_deal(deal), status: 201
    end

    def update
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
      deal = Deal.find_by(id: params[:id])

      if deal.present?
        deal.destroy!
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
