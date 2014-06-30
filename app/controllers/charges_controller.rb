class ChargesController < ApplicationController

  # def new
  #   @stripe_btn_data = {
  #     key: "#{ Rails.configuration.stripe[:publishable_key] }",
  #     description: "Premium Membership - #{current_user.name}",
  #     amount: 1_00   # in pennies
  #   }
  # end

  def create
    @amount = params[:amount]

    # Creates a Stripe Customer object, for associating with the charge
    customer = Stripe::Customer.create(
      email: current_user.email,
      card: params[:stripeToken]
      )

    charge = Stripe::Charge.create(
      customer: customer.id, # This is different than user_id
      amount: @amount,
      description: "Premium Membership - #{current_user.email}",
      currency: 'usd'
      )

    flash[:notice] = "Thank you for your payment, #{current_user.email}.  Your account has been upgraded to Premium."
    current_user.update_attribute(:level, "premium")
    redirect_to user_path(current_user)

    # Stripe will send back CardErrors when something goes wrong
    # Rescue block below will catch and display those errors.
    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_charge_path
    end

end
