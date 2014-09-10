class MonthCrawler
  include Sidekiq::Worker
  def perform(list, index)
    Listserv.new(list).item_ids_from_month_index(index).map do |item|
      ReplyCrawler.perform_async(list, index, item)
    end
  end
end
