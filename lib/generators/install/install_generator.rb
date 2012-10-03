module Cruddler
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def copy_locales
        puts "locale file"
        copy_file 'cruddler.yml', "config/locales/cruddler.yml"
      end

      def copy_views
        puts "views for view inheritance"
        copy_file 'application/*', "app/views/admin/application/"
      end
    end
  end
end
