class RenameEditionsLocaleToPrimaryLocale < ActiveRecord::Migration
  def change
    rename_column :editions, :locale, :primary_locale
  end
end
