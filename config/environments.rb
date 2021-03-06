configure :production, :development do
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

  ActiveRecord::Base.establish_connection(
      :adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      :host     => db.host,
      :username => db.user,
      :password => db.password,
      :database => db.path[1..-1],
      :encoding => 'utf8'
  )
end


# require 'active_record'

# ActiveRecord::Base.establish_connection({
# :adapter => "postgresql",
# :host => "localhost",
# :username => "susrutcarpenter",
# :database => "superhero_wiki"

# # })
# ActiveRecord::Base.logger = Logger.new(STDOUT)