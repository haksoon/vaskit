# rails generate migration change_to_utf8mb_encoding

class ChangeToUtf8mbEncoding < ActiveRecord::Migration
  def db
    ActiveRecord::Base.connection
  end

  def up
    execute "ALTER DATABASE `#{db.current_database}` CHARACTER SET utf8mb4;"
    db.tables.each do |table|
      execute "ALTER TABLE `#{table}` CHARACTER SET = utf8mb4;"
      db.columns(table).each do |column|
        case column.sql_type
        when "text"
          execute "ALTER TABLE `#{table}` CHANGE `#{column.name}` `#{column.name}` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
        when /varchar\(([0-9]+)\)/i
          # InnoDB has a maximum index length of 767 bytes, so for utf8 or utf8mb4
          # columns, you can index a maximum of 255 or 191 characters, respectively.
          # If you currently have utf8 columns with indexes longer than 191 characters,
          # you will need to index a smaller number of characters.
          indexed_column = db.indexes(table).any? { |index| index.columns.include?(column.name) }
          sql_type  = (indexed_column && $1.to_i > 191) ? 'VARCHAR(191)' : column.sql_type.upcase
          default   = (column.default.blank?) ? '' : "DEFAULT '#{column.default}'"
          null      = (column.null) ? '' : 'NOT NULL'
          execute "ALTER TABLE `#{table}` CHANGE `#{column.name}` `#{column.name}` #{sql_type} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci #{default} #{null};"
        end
      end
    end
  end

  def down
    execute "ALTER DATABASE `#{db.current_database}` CHARACTER SET utf8;"
    db.tables.each do |table|
      execute "ALTER TABLE `#{table}` CHARACTER SET = utf8;"
      db.columns(table).each do |column|
        case column.sql_type
        when "text"
          execute "ALTER TABLE `#{table}` CHANGE `#{column.name}` `#{column.name}` TEXT CHARACTER SET utf8 COLLATE utf8_general_ci;"
        when /varchar\(([0-9]+)\)/i
          # InnoDB has a maximum index length of 767 bytes, so for utf8 or utf8mb4
          # columns, you can index a maximum of 255 or 191 characters, respectively.
          # If you currently have utf8 columns with indexes longer than 191 characters,
          # you will need to index a smaller number of characters.
          indexed_column = db.indexes(table).any? { |index| index.columns.include?(column.name) }
          sql_type  = (indexed_column && $1.to_i > 191) ? 'VARCHAR(255)' : column.sql_type.upcase
          default   = (column.default.blank?) ? '' : "DEFAULT '#{column.default}'"
          null      = (column.null) ? '' : 'NOT NULL'
          execute "ALTER TABLE `#{table}` CHANGE `#{column.name}` `#{column.name}` #{sql_type} CHARACTER SET utf8 COLLATE utf8_general_ci #{default} #{null};"
        end
      end
    end
  end
end
