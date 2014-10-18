class ChangeProjectConstraintsToAcceptImported < ActiveRecord::Migration
  def change
    change_column_null :projects, :category_id, true
    change_column_null :projects, :credit_type, true
    change_column_null :projects, :minimum_investment, true
    change_column_null :projects, :statement_file_url, true
    change_column_null :projects, :tax_exempt_yield, true
    change_column_null :projects, :summary, true
    change_column_null :projects, :headline, true
    change_column_null :projects, :goal, true
  end
end
