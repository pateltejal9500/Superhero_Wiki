def email(edited, document, author, subscribers)
  subscribers.each do |subscriber|
    response = HTTParty.post "https://sendgrid.com/api/mail.send.json", :body => {
      "api_user" => "tejal",
      "api_key" => "guessthis84",
      "to" => "#{subscriber.email}",
      "toname"=> "#{subscriber.first} #{subscriber.last}",
      "from" => "tejalpatel_84@hotmail.com",
      "subject" => "#{document.name} has been #{edited}",
      "text" => "#{document.name.upcase} by #{author.first} #{author.last} has been #{edited}",
    };
  end
end

def deleteemail(edited, document, author, subscribers)
  subscribers.each do |subscriber|
    response = HTTParty.post "https://sendgrid.com/api/mail.send.json", :body => {
      "api_user" => "tejal",
      "api_key" => "guessthis84",
      "to" => "#{subscriber.email}",
      "toname"=> "#{subscriber.first} #{subscriber.last}",
      "from" => "tejalpatel_84@hotmail.com",
      "subject" => "#{document.name} has been #{edited}",
      "text" => "#{document.name.upcase} by #{author.first} #{author.last} has been #{edited}",
    };
        subscriber.destroy
  end
end