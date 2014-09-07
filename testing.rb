require "httparty"
url = "https://sendgrid.com/api/mail.send.json"

response = HTTParty.post url, :body => {
"api_user" => "tejal",
"api_key" => "guessthis84",
"to" => "tejalpatel_84@hotmail.com",
"from" => "tejalpatel_84@hotmail.com",
"subject" => "Hello world",
"text" => "Congrats! You've sent your first email with SendGrid."
};

