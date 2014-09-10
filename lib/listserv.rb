class Listserv
  def self.listserv_config
    {
      socnet: {
        root: "http://lists.ufl.edu/cgi-bin/wa?A0=socnet",
        month_url: lambda{|index| "http://lists.ufl.edu/cgi-bin/wa?A1=#{index}&L=SOCNET"},
        item_url: lambda{|index, item| "http://lists.ufl.edu/cgi-bin/wa?A2=#{index}&L=SOCNET&T=0&F=&S=&P=#{item}"}
      }
    }
  end
  def initialize
end
