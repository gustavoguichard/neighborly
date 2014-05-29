class PayableResourceSerializer
  attr_reader :resource

  def initialize(resource)
    @resource = resource
  end

  def to_json
    json = resource.as_json(only: %i(
      payment_service_fee
      payment_service_fee_paid_by_user
    ))

    json[:project] = project
    json[:user]    = user
    json[:reward]  = reward if resource.respond_to? :reward

    json
  end

  private

  def project
    {
      id:        resource.project_id,
      name:      resource.project.name,
      permalink: resource.project.permalink,
      user:      resource.project.user_id
    }
  end

  def user
    {
      id:      resource.user_id,
      name:    resource.user.display_name,
      email:   resource.user.email,
      address: {
        line1:       resource.user.address_street,
        city:        resource.user.address_city,
        state:       resource.user.address_state,
        postal_code: resource.user.address_zip_code
      }
    }
  end

  def reward
    {
      id:          resource.reward.try(:id),
      title:       resource.reward.try(:title),
      description: resource.reward.try(:description)
     }
  end
end
