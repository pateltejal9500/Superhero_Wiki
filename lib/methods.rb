   def email(edited, document, author)
    subscribers = Subscriber.where({document_id: params[:id]})
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

   def deleteemail(document, author)
    subscribers = Subscriber.where({document_id: params[:id]})
    subscribers.each do |subscriber|
    response = HTTParty.post "https://sendgrid.com/api/mail.send.json", :body => {
      "api_user" => "tejal",
      "api_key" => "guessthis84",
      "to" => "#{subscriber.email}",
      "toname"=> "#{subscriber.first} #{subscriber.last}",
      "from" => "tejalpatel_84@hotmail.com",
      "subject" => "#{document.name} has been deleted",
      "text" => "#{document.name.upcase} by #{author.first} #{author.last} has been deleted",
    };
    subscriber.destroy
  end
end