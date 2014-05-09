class RemoveCpfFromUsers < ActiveRecord::Migration
  def up
    drop_view :contribution_reports
    remove_column :users, :cpf

    create_view :contribution_reports, <<-SQL
      SELECT b.project_id,
        u.name,
        b.value,
        r.minimum_value,
        r.description,
        b.payment_method,
        b.payment_choice,
        b.payment_service_fee,
        b.key,
        (b.created_at)::date AS created_at,
        (b.confirmed_at)::date AS confirmed_at,
        u.email,
        b.payer_email,
        b.payer_name,
        b.payer_document,
        u.address_street,
        u.address_complement,
        u.address_number,
        u.address_neighborhood AS address_neighbourhood,
        u.address_city,
        u.address_state,
        u.address_zip_code,
        b.state
       FROM ((contributions b JOIN users u ON ((u.id = b.user_id))) LEFT JOIN rewards r ON ((r.id = b.reward_id)))
       WHERE ((b.state)::text = ANY ((ARRAY['confirmed'::character varying, 'refunded'::character varying, 'requested_refund'::character varying])::text[]));
    SQL
  end

  def down
    add_column :users, :cpf, :text

    drop_view :contribution_reports
    create_view :contribution_reports, <<-SQL
      SELECT b.project_id,
        u.name,
        b.value,
        r.minimum_value,
        r.description,
        b.payment_method,
        b.payment_choice,
        b.payment_service_fee,
        b.key,
        (b.created_at)::date AS created_at,
        (b.confirmed_at)::date AS confirmed_at,
        u.email,
        b.payer_email,
        b.payer_name,
        COALESCE(b.payer_document, u.cpf) AS cpf,
        u.address_street,
        u.address_complement,
        u.address_number,
        u.address_neighborhood AS address_neighbourhood,
        u.address_city,
        u.address_state,
        u.address_zip_code,
        b.state
       FROM ((contributions b JOIN users u ON ((u.id = b.user_id))) LEFT JOIN rewards r ON ((r.id = b.reward_id)))
       WHERE ((b.state)::text = ANY ((ARRAY['confirmed'::character varying, 'refunded'::character varying, 'requested_refund'::character varying])::text[]));
    SQL
  end
end
