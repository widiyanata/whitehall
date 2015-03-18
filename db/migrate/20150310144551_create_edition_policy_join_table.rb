class CreateEditionPolicyJoinTable < ActiveRecord::Migration
  def change
    create_table :edition_policies do |t|
      t.references :edition
      t.integer :policy_content_id
      t.timestamps
    end
  end
end
