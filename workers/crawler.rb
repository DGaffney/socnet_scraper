class Crawler
  def perform(list)
    Listserv.new(list).month_indices_from_root.map do |index|
      MonthCrawler.perform_async(list, index)
    end
  end
end
