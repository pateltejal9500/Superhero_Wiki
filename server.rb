require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

require_relative './config/enviroments.rb'
require_relative './lib/changed.rb'
require_relative './lib/author.rb'
require_relative './lib/document.rb'
require_relative './lib/subscriber.rb'
require_relative './lib/activity.rb'
require_relative './lib/methods.rb'

after do
  ActiveRecord::Base.connection.close
end

get "/" do
  recent = Activity.all
  recent = recent.sort.reverse {|time|time.created_at} 
  recentstuff = []
  i = 0
  while i < 10 && i < (recent.length)
    recentstuff<< recent[i]
    i += 1
  end
  erb(:index, {locals:{recentstuff:recentstuff}})
end

get "/search" do
  erb(:search)
end

get "/results" do
  searchword = params[:search].downcase
  document = Document.where({name: searchword})
  documents = []
  Document.all.each do |doc|
    if (doc.information).scan(/#{searchword}/).count > 0
      documents << doc
    end
  end
  erb(:results, {locals: {document: document, documents: documents,searchword:searchword}})
end

get "/document/:id" do
  document = Document.find_by({id: params[:id]})
  author = document.author
  authoredited = document.edited
  if document.information.include?"[["
    replacing = (document.information).split("[[")[1].split("]]")[0] 
  end
  Document.all.each do |documents|
  if documents.name == replacing
    document.information = (document.information).gsub("[[#{replacing}]]", "<html><a href='/document/#{documents.id}'>#{documents.name}</a></html>")
  end
  end
  renderer = Redcarpet::Render::HTML.new
  markdown = Redcarpet::Markdown.new(renderer, extensions={})
erb(:document, {locals: {document:document, author:author, authoredited: authoredited, markdown: markdown}})
end

get "/newdocument" do
  erb(:newdocument, {locals: {authors: Author.all}})
end

get "/documents" do
  erb(:documents, {locals: {documents:Document.all}})
end

post "/documents" do
  name = params["name"].downcase
  information = params["information"]
  author_id = params["author"]
  url = params["url"]
  author = Author.find_by({id: author_id})
  document = {
              name: name, 
              information: information, 
              author_id: author_id, 
              edited_id: author_id,
              url: url,
            }
  Document.create(document)
  recent = {
            document_name: name, 
            author_first:" by #{author.first}", 
            author_last: author.last, 
            action: "added",
          }
  Activity.create(recent)
  erb(:documents, {locals: {documents:Document.all}})
end

post "/newdocument" do
  first = params["first"]
  last = params["last"]
  author = {first: first, last:last}
  Author.create(author)
  recent = {
            document_name: "", 
            author_first: first, 
            author_last: last, 
            action: "added as an author",
          }
  Activity.create(recent)
  erb(:newdocument, {locals: {authors:Author.all}})
end

get "/authors" do
  erb(:authors, {locals: {authors:Author.all}})
end

get "/author/:id" do
  author = Author.find_by({id: params[:id]})
  documents = author.document
  editeddocuments = Document.where({edited_id: params[:id]})
  authoredits = Change.where({edited_id: params[:id]})
  documentsedited=[]
  authoredits.each do |oneedit|
    documentsedited << oneedit.document
  end
  erb(:author, {locals: {author:author, documents:documents, documentsedited:documentsedited, editeddocuments: editeddocuments}})
end

get "/edit/:id" do
  renderer = Redcarpet::Render::HTML.new
  markdown = Redcarpet::Markdown.new(renderer, extensions={})
  document = Document.find_by({id: params[:id]})
  erb(:editdocument, {locals: {document:document, markdown:markdown,authors:Author.all}})
end

put "/document/:id" do
  newauthor = params["author"]
  document = Document.find_by({id:params[:id]})
  author = Author.find_by({id: document.author_id})
  edited = {
    document_id: document.id, 
    old_information: document.information, 
    old_name: document.name, 
    author_id: document.author_id,
    edited_id: document.edited_id, 
    old_url: document.url,
  }
  newdocument = {
    information: params[:information], 
    name: params[:name],
    edited_id: params[:author],
    url: params[:url],
  }
  
  recent = {
    document_name: document.name, 
    author_first:" by #{author.first}", 
    author_last: author.last, 
    action: "edited"
  }
   subscribers = Subscriber.where({document_id: params[:id]})
   email("has been edited", document, author, subscribers)
  Activity.create(recent)
  document.update(newdocument)
  Change.create(edited)
erb(:documents, {locals: {documents:Document.all}})
end

get "/delete/:id" do
  document = Document.find_by({id: params[:id]})
  erb(:confirmationdelete, {locals: {document:document}})
end

delete "/document/:id" do
  document = Document.find_by({id: params[:id]})
  author = Author.find_by({id: document.author_id})
  subscribers = Subscriber.where({document_id: params[:id]})
    if subscribers.length > 0
     deleteemail("deleted", document, author, subscribers)
    end
   recent = {document_name: document.name, author_first: " by #{author.first}", author_last: author.last, action: "deleted"}
  Activity.create(recent)
  document.destroy
  documents = Change.where({document_id: params[:id]})
  documents.each do |document|
     document.destroy
  end
  erb(:documents, {locals: {documents:Document.all}})
  # redirect "/documents"
  #cant use redirect for some reason
end

get "/history/:id" do
  document = Document.find_by({id: params[:id]})
  olddocuments = Change.where({document_id: params[:id]})
  erb(:oldversions, {locals: {olddocuments:olddocuments, document:document}})
end

get "/old/:id/:id" do
  document = Document.find_by({id: params[:captures][0]})
  olddocument = Change.find_by({id: params[:id]})
  author = document.author
  editedauthor = olddocument.editedauthor
  if olddocument.old_information.include?"[["
    replacing = (olddocument.old_information).split("[[")[1].split("]]")[0] 
  end
  Document.all.each do |documents|
    if documents.name == replacing
      olddocument.old_information = (olddocument.old_information).gsub("[[#{replacing}]]", "<html><a href='/document/#{documents.id}'>#{documents.name}</a></html>")
    end
  end
  renderer = Redcarpet::Render::HTML.new
  markdown = Redcarpet::Markdown.new(renderer, extensions={})
erb(:oldone, {locals: {olddocument: olddocument, document:document, author:author, editedauthor:editedauthor,markdown:markdown}})
end

put "/document/change/:id" do
  documentchanging = Change.find_by({id:params[:name]})
  document = Document.find_by({id: params[:id]})
  author = Author.find_by({id: document.author_id})
  newdocument = {
    name: documentchanging.old_name, 
    information: documentchanging.old_information, 
    edited_id: documentchanging.edited_id, 
    url: documentchanging.old_url,
  }
  newolddocument = {
    old_name: document.name, 
    old_information: document.information, 
    edited_id: document.edited_id, 
    old_url: document.url
  }
  recent = {
    document_name: document.name,
     author_first: " by #{author.first}",
      author_last: author.last, 
      action:"back to original",
    }
  subscribers = Subscriber.where({document_id: params[:id]})
  email("has been changed to a different version", document, author, subscribers)
  documentchanging.update(newolddocument)
  document.update(newdocument)
erb(:documents, {locals: {documents:Document.all}})
end
  
get "/subscribe/:id" do
  document = Document.find_by({id:params[:id]})
  erb(:subscribe, {locals: {document: document}})
end

post "/document/subscribe/:id" do
  first = params["first"]
  email = params["email"]
  last = params["last"]
  email = params["email"]
  document = Document.find_by({id:params[:id]})
  author = Author.find_by({id: document.author_id})
  subscriber = {first: first, 
    last: last,
     email: email, 
     document_id: document.id
   }
  subscriber = Subscriber.create(subscriber)
   response = HTTParty.post "https://sendgrid.com/api/mail.send.json", :body => {
      "api_user" => "tejal",
      "api_key" => "guessthis84",
      "to" => "#{subscriber.email}",
      "toname"=> "#{subscriber.first} #{subscriber.last}",
      "from" => "tejalpatel_84@hotmail.com",
      "subject" => "#{document.name} has been added to your subscription",
      "text" => "#{document.name} by #{author.first} #{author.last} has been added",
    };

 erb(:thankyou,{locals: {document:document}})
end

get "/unsubscribe/:id" do
  document = Document.find_by({id:params[:id]})
  erb(:unsubscribe,{locals: {document:document}})
end

get "/notvalid" do
  erb(:notvalid)
end

delete "/document/unsubscribe/:id" do
  document = Document.find_by({id:params[:id]})
  author = Author.find_by({id: document.author_id})
  email = params[:email]
  subscribers = Subscriber.where(email:email, document_id: document.id)
  if subscribers.length == 0
    redirect "/notvalid"
  elsif subscribers.length > 0
    deleteemail("unsubscibed too", document, author, subscribers)
    erb(:documents, {locals: {documents:Document.all}})
  end
end


