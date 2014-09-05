CREATE DATABASE superhero_wiki
\c superhero_wiki

CREATE TABLE authors(first varchar(250), last varchar(250), id serial primary key);
CREATE TABLE documents(name varchar(250), information text, author_id integer, id serial primary key);
CREATE TABLE subscribers(document_id integer, id serial primary key);
CREATE TABLE changes(document_id integer, id serial primary key, old_information text, old_name varchar(250), author_id integer);
