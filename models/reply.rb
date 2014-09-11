class Reply
  include MongoMapper::Document
  key :subject, String
  key :from, String
  key :to, String
  key :date, Time
  key :content_type, String
  key :content, String
  key :listserv, String
end
