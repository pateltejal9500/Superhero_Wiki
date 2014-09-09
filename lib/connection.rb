require 'active_record'

ActiveRecord::Base.establish_connection({
  :adapter => "postgresql",
  :host => "localhost",
  :username => "susrutcarpenter",
  :database => "superhero_wiki"
})

ActiveRecord::Base.logger = Logger.new(STDOUT)