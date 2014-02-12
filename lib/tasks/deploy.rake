# I have a local branch called deploy which is one commit ahead of master
# that commit is the addition of the ROM file, to keep the ROM off Github
desc 'Deploy to heroku'
task :deploy do
  `git checkout deploy`
  `git merge master`
  `git push heroku deploy:master`
  `git checkout master`
end
