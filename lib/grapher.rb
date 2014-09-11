class Grapher
  def initialize(list)
    @listserv = list
    @thread_tree = {}
    @edges = []
    @nodes = {}
  end

  def cursor
    Reply.where(listserv: @listserv).fields(:from, :date, :subject).order(:date)
  end

  def remove_re(subject)
    subject.downcase.strip.gsub("re:", "").strip
  end

  def construct_thread_tree
    cursor.each do |email|
      next if email.from.nil?
      @thread_tree[remove_re(email.subject)] ||= []
      @thread_tree[remove_re(email.subject)] << {name: email.from, date: email.date}
      print "."
    end
  end

  def graph_from_thread_tree
    @thread_tree.each do |topic, actors|
      a = actors
      actors = actors.collect(&:name).uniq.reverse.collect(&:strip).collect(&:downcase).collect{|a| CGI.escape(a)}
      actors.each do |actor|
        if actor != actors.last
          @edges << {:source => actor, :target => actors[actors.index(actor)+1]}
          @nodes[actor] ||= {:id => actor, :label => actor, :start => a.select{|x| CGI.escape(x.name.downcase.strip) == actor }.first.date, :end => Time.now}
        end
      end
    end
    # Digest::SHA1.hexdigest "blah"
  end

  def get_nodes_and_edges
    construct_thread_tree
    graph_from_thread_tree
    {nodes: @nodes.values, edges: @edges}
  end
end
