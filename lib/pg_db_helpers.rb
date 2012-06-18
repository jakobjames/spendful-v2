module PgDbHelpers
  module MigrationHelpers
    def add_foreign_key(referencing_table, referencing_columns, referenced_table, referenced_columns = [:id], name = nil)
     execute PgDbHelpers::SQLHelpers.add_foreign_key_sql(referencing_table, referencing_columns, referenced_table, referenced_columns, name)
    end

    def drop_foreign_key(table, options = {})
      execute PgDbHelpers::SQLHelpers.drop_foreign_key_sql(table, options)
    end

    def add_unique_constraint(table, columns, name = nil)
      execute PgDbHelpers::SQLHelpers.add_unique_constraint_sql(table, columns, name)
    end

    def drop_unique_constraint(table, options)
      execute PgDbHelpers::SQLHelpers.drop_unique_constraint_sql(table, options)
    end

    def add_check_constraint(table, name, expression)
      execute PgDbHelpers::SQLHelpers.add_check_constraint_sql(table, name, expression)
    end

    def drop_check_constraint(table, name)
      execute PgDbHelpers::SQLHelpers::drop_check_constraint_sql(table, name)
    end
  end # module MigrationHelpers

  module SQLHelpers
    MAX_IDENTIFIER_LENGTH = 63
    PREFIXES = {
      :foreign_key => 'fk',
      :unique => 'uc',
      :check => 'cc'
    }

    def self.add_foreign_key_sql(referencing_table, referencing_columns, referenced_table, referenced_columns = [:id], name = nil)
      self.ensure_table referencing_table, 'Must provide a referencing table'
      self.ensure_table referenced_table, 'Must provide a referenced table'

      referencing_columns = self.ensure_columns referencing_columns, 'Referencing columns must be provided'
      referenced_columns = self.ensure_columns referenced_columns, 'Referenced columns must be provided'

      raise 'Number of referencing columns must match number of referenced columns' if referencing_columns.size != referenced_columns.size

      name = self.construct_constraint_name :foreign_key, referencing_table, referencing_columns, name
      "alter table #{referencing_table} add constraint #{name} foreign key (#{referencing_columns.join(',')}) references #{referenced_table} (#{referenced_columns.join(',')})"
    end

    def self.drop_foreign_key_sql(table, options = {})
      self.ensure_table table
      self.drop_constraint_sql :foreign_key, table, options
    end

    def self.add_unique_constraint_sql(table, columns, name = nil)
      self.ensure_table table
      columns = self.ensure_columns columns
      name = self.construct_constraint_name :unique, table, columns, name
      "alter table #{table} add constraint #{name} unique (#{columns.join(',')})"
    end

    def self.drop_unique_constraint_sql(table, options = {})
      self.ensure_table table
      self.drop_constraint_sql :unique, table, options
    end

    def self.add_check_constraint_sql(table, name, expression)
      self.ensure_table table
      name = self.construct_constraint_name :check, nil, nil, name
      raise 'Must provide an expression' unless expression
      "alter table #{table} add constraint #{name} check (#{expression})"
    end

    def self.drop_check_constraint_sql(table, name)
      self.ensure_table table
      self.drop_constraint_sql :check, table, :name => name
    end

    private

    def self.ensure_table(table, message = nil)
      message ||= 'Must provide a table'
      table.strip! if table.is_a?(String)
      raise message if table.blank?
    end

    def self.ensure_columns(columns, message = nil)
      columns = [columns] unless columns.is_a?(Array)
      columns.compact!

      message ||= 'Columns must be provided'
      raise message if columns.size == 0

      columns
    end # def self.ensure_columns
    
    def self.construct_constraint_name(constraint_type, table, columns, name)
      if constraint_type == :check
        raise 'Must provide a name' unless name
      else
        name ||= "#{PREFIXES[constraint_type]}_#{table}_#{columns.join('_')}"
      end

      name = "#{PREFIXES[constraint_type]}_#{name}" unless /^#{PREFIXES[constraint_type]}_/.match(name)
      raise "PostgreSQL identifier (#{name}) too long (max #{MAX_IDENTIFIER_LENGTH})" if name.size > MAX_IDENTIFIER_LENGTH
      name
    end # def self.construct_constraint_name

    def self.drop_constraint_sql(constraint_type, table, options)
      if constraint_type == :check
        raise 'Must provide a name' unless name
      else
        raise 'Must provide either columns or name' unless options[:columns] || options[:name]
      end

      columns = nil
      name = nil

      unless options[:name]
        columns = self.ensure_columns options[:columns]
        name = "#{PREFIXES[constraint_type]}_#{table}_#{columns.join('_')}"
      end

      name = self.construct_constraint_name constraint_type, table, columns, (name || options[:name])
      "alter table #{table} drop constraint if exists #{name}"
    end # def self.drop_constraint_sql
  end # module SQLHelpers
end