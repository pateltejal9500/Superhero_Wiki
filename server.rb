require 'sinatra'
require 'sinatra/reloader'
require 'HTTParty'
require 'pry'
require_relative './lib/connection.rb'
require_relative './lib/changed.rb'
require_relative './lib/author.rb'
require_relative './lib/document.rb'
require_relative './lib/subscriber.rb'


after do
  ActiveRecord::Base.connection.close
end

get "/" do
  erb(:index)
end

get "/search" do
  erb(:search)
end

get "/results" do
  searchword = params[:search].downcase
  document = Document.where({name: searchword})
  erb(:results, {locals: {document: document, searchword:searchword}})
end

get "/document/:id" do
  document = Document.find_by({id: params[:id]})
  author = document.author
  if document.information.include?"[["
  replacing = (document.information).split("[[")[1].split("]]")[0] 
  end
  Document.all.each do |documents|
  if documents.name == replacing
    document.information = (document.information).gsub("[[#{replacing}]]", "<html><a href='/document/#{documents.id}'>#{documents.name}</a></html>")
  end
  end
  
  erb(:document, {locals: {document:document, author:author}})
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
  document = {name:name, information:information, author_id: author_id}
  Document.create(document)
  erb(:documents, {locals: {documents:Document.all}})
end

post "/newdocument" do
  first = params["first"]
  last = params["last"]
  author = {first: first, last:last}
  Author.create(author)
  erb(:newdocument, {locals: {authors:Author.all}})
end

get "/authors" do
  erb(:authors, {locals: {authors:Author.all}})
end

get "/author/:id" do
  author = Author.find_by({id: params[:id]})
  documents = author.document
  authoredits = Change.where({author_id: params[:id]})
  documentsedited=[]
  authoredits.each do |oneedit|
    documentsedited << oneedit.document
  end

  erb(:author, {locals: {author:author, documents:documents, documentsedited:documentsedited}})
end

get "/edit/:id" do
  document = Document.find_by({id: params[:id]})
  erb(:editdocument, {locals: {document:document, authors:Author.all}})
end

put "/document/:id" do
  document = Document.find_by({id: params[:id]})
  edited = {document_id: document.id, old_information: document.information, old_name: document.name, author_id: params[:author]}
  Change.create(edited)
  newdocument = {information: params[:information], name:params[:name]}
  document.update(newdocument)
  erb(:documents, {locals: {documents:Document.all}})
end

get "/delete/:id" do
  document = Document.find_by({id: params[:id]})
  erb(:confirmationdelete, {locals: {document:document}})
end

delete "/document/:id" do
   document = Document.find_by({id: params[:id]})
   document.destroy
   documents = Change.where({document_id: params[:id]})
   documents.each do |document|
   document.destroy
    end
   redirect "/documents"
 end

get "/history/:id" do
  document = Document.find_by({id: params[:id]})
  olddocuments = Change.where({document_id: params[:id]})
  erb(:oldversions, {locals: {olddocuments:olddocuments, document:document}})
end

get "/old/:id/:id" do
  document = Document.find_by({id: params[:captures][0]})
  olddocument = Change.find_by({id: params[:id]})
  if olddocument.old_information.include?"[["
  replacing = (olddocument.old_information).split("[[")[1].split("]]")[0] 
  end
  Document.all.each do |documents|
  if documents.name == replacing
    olddocument.old_information = (olddocument.old_information).gsub("[[#{replacing}]]", "<html><a href='/document/#{documents.id}'>#{documents.name}</a></html>")
  end
  end
erb(:oldone, {locals: {olddocument: olddocument, document:document}})
end

  
  

