require 'spec_helper'

describe Project::OrganizationType do
  it { expect(Project.organization_types).to eq [:municipality, :neighborhood_organization, :cid_bid, :registered_nonprofit, :nonprofit_501c3, :public_private_partnership, :other, :not_sure] }
  it { expect(Project.organization_type_array.size).to eq Project.organization_types.size + 1 }
end
