unless Rake::Task.task_defined?('db:rebuild')
	namespace :db do
		desc 'Run db:drop, db:create, db:migrate, and db:test:prepare in succession'
		task :rebuild do
			Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['db:test:prepare'].invoke
      Rake::Task['db:seed'].invoke
		end
	end
end