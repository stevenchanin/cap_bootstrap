Capistrano::Configuration.instance(:must_exist).load do
  set_default(:postgresql_host, "localhost")
  set_default(:postgresql_user) { application }
  set_default(:postgresql_password) { Capistrano::CLI.password_prompt "PostgreSQL Password: " }
  set_default(:postgresql_database) { "#{application}_production" }

  namespace :postgresql do
    desc "Install the latest stable release of PostgreSQL."
    task :install, roles: :db, only: {primary: true} do
      run "#{sudo} add-apt-repository ppa:pitti/postgresql"
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install postgresql libpq-dev"
    end

    desc "Create a database for this application."
    task :create_database, roles: :db, only: {primary: true} do
      run %Q{#{sudo} -u postgres psql -c "create user #{postgresql_user} with password '#{postgresql_password}';"}
      run %Q{#{sudo} -u postgres psql -c "create database #{postgresql_database} owner #{postgresql_user};"}
    end

    desc "Generate the database.yml configuration file."
    task :setup, roles: :app do
      template "postgresql.yml.erb", "#{shared_path}/config/database.yml"
    end

    desc "Symlink the database.yml file into latest release"
    task :symlink, roles: :app do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
  end
end
