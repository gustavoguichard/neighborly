# This migration comes from neighborly_balanced_bankaccount (originally 20140813180429)
class UseHrefsForBalancedResources < ActiveRecord::Migration
  def up
    rename_column :balanced_contributors, :uri, :href
    rename_column :balanced_contributors, :bank_account_uri, :bank_account_href
    migrate_uris(:up)
  end

  def down
    rename_column :balanced_contributors, :href, :uri
    rename_column :balanced_contributors, :bank_account_href, :bank_account_uri
    migrate_uris(:down)
  end

  private

  def migrate_uris(direction)
    Neighborly::Balanced::Contributor.reset_column_information
    Neighborly::Balanced::Contributor.all.each do |contributor|
      migrate_attr(contributor, :bank_account_uri, :bank_account_href, direction)
      migrate_attr(contributor, :uri, :href, direction)
      status = contributor.save(validate: false)
      Rails.logger.info "Migrated Contributor ##{contributor.id}. Successful? #{status}"
    end
  end

  def migrate_attr(object, fst_attr, snd_attr, direction)
    if direction.eql? :up
      attr = snd_attr
      old_value = object.send(attr)
      if old_value.present?
        object.public_send("#{attr}=", old_value.sub('/v1', ''))
      end
    else
      attr = fst_attr
      old_value = object.send(attr)
      if old_value.present?
        object.public_send("#{attr}=", '/v1' + old_value)
      end
    end
  end
end
