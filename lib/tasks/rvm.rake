namespace :rvm do

  namespace :dotfiles do
    desc 'Links the ruby-*.dev files'
    task :link do
      sh %(ln -s .ruby-gemset.dev .ruby-gemset;
           ln -s .ruby-version.dev .ruby-version;)
      puts %(Activate environment via 'cd .')
    end

    desc 'Unlinks the ruby-*.dev files'
    task :unlink do
      sh %(unlink .ruby-gemset;
           unlink .ruby-version;)
    end
  end
end
