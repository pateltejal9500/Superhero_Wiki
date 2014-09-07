require 'active_record'
class Subscriber < ActiveRecord::Base

  def email 
    document = Document.find_by({id:params[:id]})
    author = Author.find_by({id: document.author_id})
    subscribers.each do |subscriber| 
    response = HTTParty.post "https://sendgrid.com/api/mail.send.json", :body => {
      "api_user" => "tejal",
      "api_key" => "guessthis84",
      "to" => "#{self.email}",
      "toname"=> "#{self.first} #{self.last}",
      "from" => "tejalpatel_84@hotmail.com",
      "subject" => "#{document.name.upcase} has been edited",
      "text" => "#{document.name.upcase} by #{author.first} #{author.last} has been edited",
    };
  
end
end
end

