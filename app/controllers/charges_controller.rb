class ChargesController < ApplicationController

  def create
   customer = Stripe::Customer.create(
     email: current_user.email,
     card: params[:stripeToken]
   )

   charge = Stripe::Charge.create(
     customer: customer.id,
     amount: Amount.default,
     description: "Premium Account - #{current_user.email}",
     currency: 'usd'
   )

   flash[:success] = "Thank you for upgrading your account. You can now enjoy full access!"
   current_user.upgrade_account(customer)
   redirect_to root_path

   rescue Stripe::CardError => e
     flash[:alert] = e.message
     redirect_to new_charge_path
 end

 def new
   @stripe_btn_data = {
     key: "#{ Rails.configuration.stripe[:publishable_key] }",
     description: "Premium Account - #{current_user.email}",
     amount: Amount.default
   }
 end

 def refund
  customer = current_user.stripe_id

  refund = Stripe::Refund.create(
    customer: customer,
    amount: Amount.refund(current_user)
    )

  flash[:success] = "Your account downgrade has been processed."
  redirect_to edit_user_registration_path

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end

private

 class Amount
   @default_amount = 10_00

   def self.default
     @default_amount
   end

   def self.refund(current_user)
      if (Time.now - current_user.charge_date)/(60*60*24*365) < 1
        refund_time =  Time.now.month - current_user.charge_date.month
        @default_amount - refund_time
      else
        0
      end
    end
  end
end
