require 'spec_helper'
require 'pg_db_helpers'

class DummyMigration
  include PgDbHelpers::MigrationHelpers
end

describe PgDbHelpers::MigrationHelpers do
  describe 'add_foreign_key' do
    before(:each) do
      @dummy_migration = DummyMigration.new
      @dummy_migration.stub(:execute)
      PgDbHelpers::SQLHelpers.stub(:add_foreign_key_sql)
    end

    it 'should call add_foreign_key_sql' do
      PgDbHelpers::SQLHelpers.should_receive(:add_foreign_key_sql)
      @dummy_migration.add_foreign_key :tblA, :col1, :tblB
    end

    it 'should call execute' do
      @dummy_migration.should_receive(:execute)
      @dummy_migration.add_foreign_key :tblA, :col1, :tblB
    end
  end # describe 'add_foreign_key'

  describe 'drop_foreign_key' do
    before(:each) do
      @dummy_migration = DummyMigration.new
      @dummy_migration.stub(:execute)
      PgDbHelpers::SQLHelpers.stub(:drop_foreign_key_sql)
    end

    it 'should call drop_foreign_key_sql' do
      PgDbHelpers::SQLHelpers.should_receive(:drop_foreign_key_sql)
      @dummy_migration.drop_foreign_key :tblA, :columns => :col1
    end

    it 'should call execute' do
      @dummy_migration.should_receive(:execute)
      @dummy_migration.drop_foreign_key :tblA, :columns => :col1
    end
  end # describe 'drop_foreign_key'

  describe 'add_unique_constraint' do
    before(:each) do
      @dummy_migration = DummyMigration.new
      @dummy_migration.stub(:execute)
      PgDbHelpers::SQLHelpers.stub(:add_unique_constraint_sql)
    end

    it 'should call add_unique_constraint_sql' do
      PgDbHelpers::SQLHelpers.should_receive(:add_unique_constraint_sql)
      @dummy_migration.add_unique_constraint :tblA, :col1
    end

    it 'should call execute' do
      @dummy_migration.should_receive(:execute)
      @dummy_migration.add_unique_constraint :tblA, :col1
    end
  end # describe 'add_unique_constraint'

  describe 'drop_unique_constraint' do
    before(:each) do
      @dummy_migration = DummyMigration.new
      @dummy_migration.stub(:execute)
      PgDbHelpers::SQLHelpers.stub(:drop_unique_constraint_sql)
    end

    it 'should call drop_unique_constraint_sql' do
      PgDbHelpers::SQLHelpers.should_receive(:drop_unique_constraint_sql)
      @dummy_migration.drop_unique_constraint :tblA, :columns => :col1
    end

    it 'should call execute' do
      @dummy_migration.should_receive(:execute)
      @dummy_migration.drop_unique_constraint :tblA, :columns => :col1
    end
  end # describe 'drop_unique_constraint'

  describe 'add_check_constraint' do
    before(:each) do
      @dummy_migration = DummyMigration.new
      @dummy_migration.stub(:execute)
      PgDbHelpers::SQLHelpers.stub(:add_check_constraint_sql)
    end

    it 'should call add_check_constraint_sql' do
      PgDbHelpers::SQLHelpers.should_receive(:add_check_constraint_sql)
      @dummy_migration.add_check_constraint :tblA, 'some_constraint', 'col1 < col2'
    end

    it 'should call execute' do
      @dummy_migration.should_receive(:execute)
      @dummy_migration.add_check_constraint :tblA, 'some_constraint', 'col1 < col2'
    end
  end # describe 'add_check_constraint'

  describe 'drop_check_constraint' do
    before(:each) do
      @dummy_migration = DummyMigration.new
      @dummy_migration.stub(:execute)
      PgDbHelpers::SQLHelpers.stub(:drop_check_constraint_sql)
    end

    it 'should call drop_check_constraint_sql' do
      PgDbHelpers::SQLHelpers.should_receive(:drop_check_constraint_sql)
      @dummy_migration.drop_check_constraint :tblA, 'some_constraint'
    end

    it 'should call execute' do
      @dummy_migration.should_receive(:execute)
      @dummy_migration.drop_check_constraint :tblA, 'some_constraint'
    end
  end # describe 'drop_check_constraint'
end # describe MigrationHelpers

describe PgDbHelpers::SQLHelpers do
	describe 'add_foreign_key_sql' do
    it 'should require referencing table' do
      expect { PgDbHelpers::SQLHelpers.add_foreign_key_sql nil, :col1, :tblB, :col1 }.to raise_error
      expect { PgDbHelpers::SQLHelpers.add_foreign_key_sql '', :col1, :tblB, :col1 }.to raise_error
    end

    it 'should require referenced table' do
      expect { PgDbHelpers::SQLHelpers.add_foreign_key_sql :tblA, :col1, nil, :col1 }.to raise_error
      expect { PgDbHelpers::SQLHelpers.add_foreign_key_sql :tblA, :col1, '', :col1 }.to raise_error
    end

    it 'should accept a single column' do
      sql = PgDbHelpers::SQLHelpers.add_foreign_key_sql :tblA, :col1, :tblB, :col1
      sql.should == 'alter table tblA add constraint fk_tblA_col1 foreign key (col1) references tblB (col1)'
    end

    it 'should accept multiple columns' do
      sql = PgDbHelpers::SQLHelpers.add_foreign_key_sql :tblA, [:col1, :col2], :tblB, [:col1,:col2]
      sql.should == 'alter table tblA add constraint fk_tblA_col1_col2 foreign key (col1,col2) references tblB (col1,col2)'
    end

    it 'should raise an error if referencing and referenced columns are not same size' do
      expect { PgDbHelpers::SQLHelpers.add_foreign_key_sql :tblA, [:col1, :col2], :tblB, :col1 }.to raise_error
    end

    it 'should raise an error if no referencing columns are provided' do
      expect { PgDbHelpers::SQLHelpers.add_foreign_key_sql :tblA, [], :tblB, :col1 }.to raise_error
      expect { PgDbHelpers::SQLHelpers.add_foreign_key_sql :tblA, nil, :tblB, :col1 }.to raise_error
    end

    it 'should raise an error if no referenced columns are provided' do
      expect { PgDbHelpers::SQLHelpers.add_foreign_key_sql :tblA, :col1, :tblB, [] }.to raise_error
      expect { PgDbHelpers::SQLHelpers.add_foreign_key_sql :tblA, :col1, :tblB, nil }.to raise_error
    end

    it 'should default referenced column to :id' do
      sql = PgDbHelpers::SQLHelpers.add_foreign_key_sql :tblA, :col1, :tblB
      sql.should == 'alter table tblA add constraint fk_tblA_col1 foreign key (col1) references tblB (id)'
    end

    it 'should use a provided name' do
      sql = PgDbHelpers::SQLHelpers.add_foreign_key_sql :tblA, :col1, :tblB, :col1, "#{PgDbHelpers::SQLHelpers::PREFIXES[:foreign_key]}_some_constraint_name"
      sql.should == "alter table tblA add constraint #{PgDbHelpers::SQLHelpers::PREFIXES[:foreign_key]}_some_constraint_name foreign key (col1) references tblB (col1)"
    end

    it 'should prepend the appropriate prefix to the name if necessary' do
      sql = PgDbHelpers::SQLHelpers.add_foreign_key_sql :tblA, :col1, :tblB, :col1, :some_constraint_name
      sql.should == "alter table tblA add constraint #{PgDbHelpers::SQLHelpers::PREFIXES[:foreign_key]}_some_constraint_name foreign key (col1) references tblB (col1)"
    end

    it 'should raise an error if name is over 63 characters' do
      name = 'this_is_a_really_really_really_really_really_really_really_really_long_name'
      expect { PgDbHelpers::SQLHelpers.add_foreign_key_sql :tblA, :col1, :tblB, :col1, name }.to raise_error
    end
	end # describe 'add_foreign_key_sql'

	describe 'drop_foreign_key_sql' do
    it 'should require table' do
      expect { PgDbHelpers::SQLHelpers.drop_foreign_key_sql nil, :columns => :col1 }.to raise_error
      expect { PgDbHelpers::SQLHelpers.drop_foreign_key_sql '', :columns => :col1 }.to raise_error
    end

    it 'should accept a single column' do
      sql = PgDbHelpers::SQLHelpers.drop_foreign_key_sql :tblA, :columns => :col1
      sql.should == 'alter table tblA drop constraint if exists fk_tblA_col1'
    end

    it 'should accept multiple columns' do
      sql = PgDbHelpers::SQLHelpers.drop_foreign_key_sql :tblA, :columns => [:col1, :col2]
      sql.should == 'alter table tblA drop constraint if exists fk_tblA_col1_col2'
    end

    it 'should use a provided name' do
      sql = PgDbHelpers::SQLHelpers.drop_foreign_key_sql :tblA, :name => "#{PgDbHelpers::SQLHelpers::PREFIXES[:foreign_key]}_some_constraint_name"
      sql.should == "alter table tblA drop constraint if exists #{PgDbHelpers::SQLHelpers::PREFIXES[:foreign_key]}_some_constraint_name"
    end

    it 'should prepend the appropriate prefix to the name if necessary' do
      sql = PgDbHelpers::SQLHelpers.drop_foreign_key_sql :tblA, :name => :some_constraint_name
      sql.should == "alter table tblA drop constraint if exists #{PgDbHelpers::SQLHelpers::PREFIXES[:foreign_key]}_some_constraint_name"
    end

    it 'should raise an error if name is over 63 characters' do
      name = 'this_is_a_really_really_really_really_really_really_really_really_long_name'
      expect { PgDbHelpers::SQLHelpers.drop_foreign_key_sql :tblA, :name => name }.to raise_error
    end

    it 'should raise an error if neither columns or name is provided' do
      expect { PgDbHelpers::SQLHelpers.drop_foreign_key_sql :tblA }.to raise_error
    end

    it 'should raise an error if columns is empty' do
      expect { PgDbHelpers::SQLHelpers.drop_foreign_key_sql :tblA, :columns => [] }.to raise_error
      expect { PgDbHelpers::SQLHelpers.drop_foreign_key_sql :tblA, :columns => nil }.to raise_error
    end

    it 'should prefer name over columns' do
      sql = PgDbHelpers::SQLHelpers.drop_foreign_key_sql :tblA, :columns => :col1, :name => "#{PgDbHelpers::SQLHelpers::PREFIXES[:foreign_key]}_some_constraint_name"
      sql.should == "alter table tblA drop constraint if exists #{PgDbHelpers::SQLHelpers::PREFIXES[:foreign_key]}_some_constraint_name"
    end
	end # describe 'drop_foreign_key_sql'

  describe 'add_unique_constraint_sql' do
    it 'should require table' do
      expect { PgDbHelpers::SQLHelpers.add_unique_constraint_sql nil, :col1 }.to raise_error
      expect { PgDbHelpers::SQLHelpers.add_unique_constraint_sql '', :col1 }.to raise_error
    end

    it 'should accept a single column' do
      sql = PgDbHelpers::SQLHelpers.add_unique_constraint_sql :tblA, :col1
      sql.should == 'alter table tblA add constraint uc_tblA_col1 unique (col1)'
    end

    it 'should accept multiple columns' do
      sql = PgDbHelpers::SQLHelpers.add_unique_constraint_sql :tblA, [:col1, :col2]
      sql.should == 'alter table tblA add constraint uc_tblA_col1_col2 unique (col1,col2)'
    end

    it 'should use a provided name' do
      sql = PgDbHelpers::SQLHelpers.add_unique_constraint_sql :tblA, :col1, "#{PgDbHelpers::SQLHelpers::PREFIXES[:unique]}_some_constraint_name"
      sql.should == "alter table tblA add constraint #{PgDbHelpers::SQLHelpers::PREFIXES[:unique]}_some_constraint_name unique (col1)"
    end

    it 'should prepend the appropriate prefix to the name if necessary' do
      sql = PgDbHelpers::SQLHelpers.add_unique_constraint_sql :tblA, :col1, :some_constraint_name
      sql.should == "alter table tblA add constraint #{PgDbHelpers::SQLHelpers::PREFIXES[:unique]}_some_constraint_name unique (col1)"
    end

    it 'should raise an error if name is over 63 characters' do
      name = 'this_is_a_really_really_really_really_really_really_really_really_long_name'
      expect { PgDbHelpers::SQLHelpers.add_unique_constraint_sql :tblA, :col1, name }.to raise_error
    end

    it 'should raise an error if columns is empty' do
      expect { PgDbHelpers::SQLHelpers.add_unique_constraint_sql :tblA, [] }.to raise_error
      expect { PgDbHelpers::SQLHelpers.add_unique_constraint_sql :tblA, nil }.to raise_error
    end
  end # describe 'add_unique_constraint_sql'

  describe 'drop_unique_constraint_sql' do
    it 'should require table' do
      expect { PgDbHelpers::SQLHelpers.drop_unique_constraint_sql nil, :columns => :col1 }.to raise_error
      expect { PgDbHelpers::SQLHelpers.drop_unique_constraint_sql '', :columns => :col1 }.to raise_error
    end

    it 'should accept a single column' do
      sql = PgDbHelpers::SQLHelpers.drop_unique_constraint_sql :tblA, :columns => :col1
      sql.should == 'alter table tblA drop constraint if exists uc_tblA_col1'
    end

    it 'should accept multiple columns' do
      sql = PgDbHelpers::SQLHelpers.drop_unique_constraint_sql :tblA, :columns => [:col1, :col2]
      sql.should == 'alter table tblA drop constraint if exists uc_tblA_col1_col2'
    end

    it 'should use a provided name' do
      sql = PgDbHelpers::SQLHelpers.drop_unique_constraint_sql :tblA, :name => "#{PgDbHelpers::SQLHelpers::PREFIXES[:unique]}_some_constraint_name"
      sql.should == "alter table tblA drop constraint if exists #{PgDbHelpers::SQLHelpers::PREFIXES[:unique]}_some_constraint_name"
    end

    it 'should prepend the appropriate prefix to the name if necessary' do
      sql = PgDbHelpers::SQLHelpers.drop_unique_constraint_sql :tblA, :name => :some_constraint_name
      sql.should == "alter table tblA drop constraint if exists #{PgDbHelpers::SQLHelpers::PREFIXES[:unique]}_some_constraint_name"
    end

    it 'should raise an error if name is over 63 characters' do
      name = 'this_is_a_really_really_really_really_really_really_really_really_long_name'
      expect { PgDbHelpers::SQLHelpers.drop_unique_constraint_sql :tblA, :name => name }.to raise_error
    end

    it 'should raise an error if neither columns or name is provided' do
      expect { PgDbHelpers::SQLHelpers.drop_unique_constraint_sql :tblA }.to raise_error
    end

    it 'should raise an error if columns is empty' do
      expect { PgDbHelpers::SQLHelpers.drop_unique_constraint_sql :tblA, :columns => [] }.to raise_error
      expect { PgDbHelpers::SQLHelpers.drop_unique_constraint_sql :tblA, :columns => nil }.to raise_error
    end

    it 'should prefer name over columns' do
      sql = PgDbHelpers::SQLHelpers.drop_unique_constraint_sql :tblA, :columns => :col1, :name => "#{PgDbHelpers::SQLHelpers::PREFIXES[:unique]}_some_constraint_name"
      sql.should == "alter table tblA drop constraint if exists #{PgDbHelpers::SQLHelpers::PREFIXES[:unique]}_some_constraint_name"
    end
  end # describe 'drop_unique_constraint_sql'

  describe 'add_check_constraint_sql' do
    it 'should require table' do
      expect { PgDbHelpers::SQLHelpers.add_check_constraint_sql nil, :some_constraint_name, 'col1 > col2' }.to raise_error
      expect { PgDbHelpers::SQLHelpers.add_check_constraint_sql '', :some_constraint_name, 'col1 > col2' }.to raise_error
    end

    it 'should require name' do
      expect { PgDbHelpers::SQLHelpers.add_check_constraint_sql :tblA, nil, 'col1 > col2' }.to raise_error
    end

    it 'should require expression' do
      expect { PgDbHelpers::SQLHelpers.add_check_constraint_sql :tblA, :some_constraint_name, nil }.to raise_error
    end

    it 'should use the name provided' do
      sql = PgDbHelpers::SQLHelpers.add_check_constraint_sql :tblA, "#{PgDbHelpers::SQLHelpers::PREFIXES[:check]}_some_constraint_name", 'col1 > col2'
      sql.should == "alter table tblA add constraint #{PgDbHelpers::SQLHelpers::PREFIXES[:check]}_some_constraint_name check (col1 > col2)"
    end

    it 'should prepend the appropriate prefix to the name if necessary' do
      sql = PgDbHelpers::SQLHelpers.add_check_constraint_sql :tblA, :some_constraint_name, 'col1 > col2'
      sql.should == "alter table tblA add constraint #{PgDbHelpers::SQLHelpers::PREFIXES[:check]}_some_constraint_name check (col1 > col2)"
    end
  end # describe 'add_check_constraint_sql'

  describe 'drop_check_constraint_sql' do
    it 'should require table' do
      expect { PgDbHelpers::SQLHelpers.drop_check_constraint_sql nil, :some_constraint_name }.to raise_error
      expect { PgDbHelpers::SQLHelpers.drop_check_constraint_sql '', :some_constraint_name }.to raise_error
    end

    it 'should require name' do
      expect { PgDbHelpers::SQLHelpers.drop_check_constraint_sql :tblA, nil }.to raise_error
    end

    it 'should use the name provided' do
      sql = PgDbHelpers::SQLHelpers.drop_check_constraint_sql :tblA, "#{PgDbHelpers::SQLHelpers::PREFIXES[:check]}_some_constraint_name"
      sql.should == "alter table tblA drop constraint if exists #{PgDbHelpers::SQLHelpers::PREFIXES[:check]}_some_constraint_name"
    end

    it 'should prepend the appropriate prefix to the name if necessary' do
      sql = PgDbHelpers::SQLHelpers.drop_check_constraint_sql :tblA, :some_constraint_name
      sql.should == "alter table tblA drop constraint if exists #{PgDbHelpers::SQLHelpers::PREFIXES[:check]}_some_constraint_name"
    end
  end # describe 'drop_check_constraint_sql'
end