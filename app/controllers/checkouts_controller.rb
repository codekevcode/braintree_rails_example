class CheckoutsController < ApplicationController
  def new
    @client_token = Braintree::ClientToken.generate
  end

  def show
    @transaction = Braintree::Transaction.find(params[:id])
  end

  def create
    amount = params["amount"] # In production you should not take amounts directly from clients
    nonce = params["payment_method_nonce"]

    result = Braintree::Transaction.sale(
      amount: amount,
      payment_method_nonce: nonce,
    )

    if result.success?
      redirect_to checkout_path(result.transaction.id)
    elsif result.transaction
      flash[:error] = "Transaction status - #{result.transaction.status}"
      redirect_to checkout_path(result.transaction.id)
    else
      error_messages = result.errors.map { |error| "Error: #{error.code}: #{error.message}" }
      flash[:error] = error_messages
      redirect_to new_checkout_path
    end
  end
end
