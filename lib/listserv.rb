class Listserv
  def listserv_config
    {
      socnet: {
        domain: "http://lists.ufl.edu",
        root: "http://lists.ufl.edu/cgi-bin/wa?A0=socnet",
        month_url: lambda{|index| "http://lists.ufl.edu/cgi-bin/wa?A1=#{index}&L=SOCNET"},
        item_url: lambda{|index, item| "http://lists.ufl.edu/cgi-bin/wa?A2=#{index}&L=SOCNET&T=0&F=&S=&P=#{item}"},
        month_url_regex: /\/cgi-bin\/wa\?A1=(.*)\&L=SOCNET/,
        item_url_regex: lambda{|index| /\/cgi-bin\/wa\?A2=#{index}\&L=SOCNET&T=0\&F=\&S=\&P=(.*)/},
        resolve_url: lambda{|url| Nokogiri.parse(RestClient::Request.execute(:method => :get, :url => url, :headers => {"Cookie" => "WALOGIN=6974736D6540646576696E676166666E65792E636F6D-E8E5FEE5FEE5-AOMTs; WALOGIN=6974736D6540646576696E676166666E65792E636F6D-E8E5FEE5FEE5-AOMTs"}))},
        root_xpath: "tr.normalgroup li a",
        month_xpath: "tr.normalgroup td p.archive a",
        item_xpath: "td.normalgroup table tt",
        item_content_xpath: "td.normalgroup a",
        get_content: lambda{|item_content| resolve(config.domain+item_content.search(config.item_content_xpath).last.attributes.href.value).text}
      }
    }
  end

  def config
    listserv_config.send(@listserv)
  end

  def initialize(listserv=:socnet)
    @listserv = listserv
  end

  def month_indices_from_root
    extract_months_from_month_urls(parse_root(resolve(config.root)))
  end

  def item_ids_from_month_index(index)
    extract_items_from_item_urls(parse_month(resolve(config.month_url.call(index))), index)
  end

  def item_from_index_and_item(index, item)
    parse_item(resolve(config.item_url.call(index, item)))
  end

  def parse_root(content)
    content.search(config.root_xpath).collect(&:attributes).collect(&:href).collect(&:value)
  end

  def parse_month(content)
    content.search(config.month_xpath).collect(&:attributes).collect(&:href).collect(&:value)
  end

  def parse_item(content)
    email = Hash[[:subject, :from, :to, :date, :content_type, :content].zip([content.search(config.item_xpath).collect(&:text).values_at(1,3,5,7,9), config.get_content.call(content)].flatten)]
    email.date = Time.parse(email.date) if email.date.class != Time
    email
  end

  def extract_months_from_month_urls(month_urls)
    month_urls.collect{|u| u.scan(config.month_url_regex)}.flatten
  end

  def extract_items_from_item_urls(item_urls, index)
    item_urls.collect{|u| u.scan(config.item_url_regex.call(index))}.flatten
  end

  def resolve(url)
    config.resolve_url.call(url)
  end
end
