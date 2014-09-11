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
        get_content: lambda{|item_content| RestClient.get(config.domain+config.get_content_link.call(item_content))},
        get_content_link_regex: /(\/cgi-bin\/wa\?A3=(.*)\&L=SOCNET\&E=0\&P=(.*)\&B=--\&T=TEXT%2FPLAIN;%20charset=US-ASCII|\/cgi-bin\/wa\?A3=(.*)\&L=SOCNET\&E=7bit\&P=(.*)\&B=--\&T=text%2Fplain;%20charset=US-ASCII|\/cgi-bin\/wa\?)/,
        get_content_link: lambda{|item_content| JSON.parse(item_content.search(config.item_content_xpath).to_json).flatten.reject{|x| x == "href"}.select{|u| u.scan(config.get_content_link_regex).first}.first || item_content.search(config.item_content_xpath).collect(&:attributes).collect(&:href).collect(&:value).select{|u| u.scan(config.get_content_link_regex).first}.first}
      },
      aoir: {
        domain: "http://listserv.aoir.org",
        root: "http://listserv.aoir.org/pipermail/air-l-aoir.org/",
        month_url: lambda{|index| "http://listserv.aoir.org/pipermail/air-l-aoir.org/#{index}/subject.html"},
        item_url: lambda{|index, item| "http://listserv.aoir.org/pipermail/air-l-aoir.org/#{index}/#{item}.html"},
        month_url_regex: /(.*)\/subject.html/,
        item_url_regex: lambda{|index| /(\d*).html/},
        resolve_url: lambda{|url| Nokogiri.parse(RestClient::Request.execute(:method => :get, :url => url))},
        root_xpath: "table td a",
        month_xpath: "ul li a"
      },
      libtech: {
        domain: "http://mailman.stanford.edu",
        root: "http://mailman.stanford.edu/pipermail/liberationtech/",
        month_url: lambda{|index| "http://mailman.stanford.edu/pipermail/liberationtech/#{index}/subject.html"},
        item_url: lambda{|index, item| "http://mailman.stanford.edu/pipermail/liberationtech/#{index}/#{item}.html"},
        month_url_regex: /(.*)\/subject.html/,
        item_url_regex: lambda{|index| /(\d*).html/},
        resolve_url: lambda{|url| Nokogiri.parse(RestClient::Request.execute(:method => :get, :url => url))},
        root_xpath: "table td a",
        month_xpath: "ul li a"
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
    content.search(config.month_xpath).collect(&:attributes).collect(&:href).compact.collect(&:value)
  end

  def parse_item(content)
    return self.send("parse_item_#{@listserv}", content) if self.respond_to?("parse_item_#{@listserv}")
  end

  def parse_item_socnet(content)
    email = Hash[[:subject, :from, :to, :date, :content_type, :content].zip([content.search(config.item_xpath).collect(&:text).values_at(1,3,5,7,9), config.get_content.call(content)].flatten)]
    email.date = Time.parse(email.date) if email.date.class != Time
    email.listserv = @listserv.to_s
    email
  end

  def parse_standard_item(content)
    {
      subject: content.search("h1")[0].text,
      from: content.search("b")[0].text+"<"+content.search("a").first.text.strip.gsub(" at ", "@")+">",
      to:  "air-l@listserv.aoir.org <air-l@listserv.aoir.org>",
      date: Time.parse(content.search("i")[0].text),
      content: content.search("pre").text,
      listserv: @listserv
    }
  end

  def parse_item_aoir(content)
    parse_standard_item(content)
  end

  def parse_item_libtech(content)
    parse_standard_item(content)
  end

  def extract_months_from_month_urls(month_urls)
    month_urls.collect{|u| u.scan(config.month_url_regex)}.flatten.reject(&:empty?)
  end

  def extract_items_from_item_urls(item_urls, index)
    item_urls.collect{|u| u.scan(config.item_url_regex.call(index))}.flatten.reject(&:empty?)
  end

  def resolve(url)
    config.resolve_url.call(url)
  end
end
