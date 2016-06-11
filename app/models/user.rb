class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def upgrade_account(stripe_customer)
    update_attributes(stripe_id: stripe_customer.id, charge_date: Time.now, role:'premium')

  end
end
