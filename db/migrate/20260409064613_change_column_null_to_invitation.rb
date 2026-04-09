class ChangeColumnNullToInvitation < ActiveRecord::Migration[7.1]
  def change
    change_column_null :invitations, :company_id, true
  end
end
