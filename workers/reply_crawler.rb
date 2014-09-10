class ReplyCrawler
  include Sidekiq::Worker
  def perform(list, index, item)
    reply = Reply.new(Listserv.new(list).item_from_index_and_item(index, item))
    raise "Cookie is failing!" if reply.from.include?("<[log in to unmask]>") || reply.to.include?("<[log in to unmask]>")
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    reply.content = ic.iconv(reply.content)
    reply.from = ic.iconv(reply.from)
    reply.to = ic.iconv(reply.to)
    reply.subject = ic.iconv(reply.subject)
    reply.save!
  end
end
