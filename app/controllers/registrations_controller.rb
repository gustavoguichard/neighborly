class RegistrationsController < Devise::RegistrationsController
  def new
    @referral_code = referral_code

    super
  end

  def create
    if referral_code.present?
      referrer = User.find_by(referral_code: referral_code)
      params[:user][:referrer_id] = referrer.id
    else
      params[:user].delete(:referrer_id)
    end

    super
  end
end
