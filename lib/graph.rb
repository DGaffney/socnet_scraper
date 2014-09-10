class Graph
  def to_gexf(file=StringIO.new("", "w+"))
    gexf = GEXF.new(file)
    gexf.header_declaration;false
    gexf.graph_declaration;false
    gexf.attribute_declarations(attribute_declarations);false
    gexf.nodes(nodes);false
    gexf.edges(edges);false
    gexf.footer;false
    gexf.file.rewind
    gexf.file
  end

  def gexf_type(class_to_s)
    {
      "Float" => "double",
      "FalseClass" => "boolean",
      "TrueClass" => "boolean",
      "Array" => "string",
      "Hash" => "string",
      "String" => "string",
      "NilClass" => "string",
    }[class_to_s]
  end

  def nodes
    nodes = []
    @graph.nodes.each do |node_id, node_data|
      node = {:id => node_id, :label => node_data.user_screen_name, :start => node_data.created_at.to_i, :end => Time.now.to_i, :attributes => []}
      node_data.each do |k,v|
        node.attributes << {for: k, value: v}
      end
      nodes << node
    end
    nodes
  end

  def edges
    edges = []
    @graph.edges.each do |node_id, edge_data|
      edge_data.in.values.each do |edge|
        edges << {source: node_id, target: edge.id, attributes: edge.attributes}
      end
    end
    edges
  end

  def edge_attribute_exists(edge, attr_name)
    !edge.attributes.select{|x| x.for == attr_name}.first.nil?
  end

  def increment_count_for_edge_attribute(edge, attribute)
    if edge_attribute_exists(edge, attribute)
      edge.attributes.select{|x| x.for == attribute}.first.value += 1
    else
      edge.attributes << {for: attribute, value: 1}
    end
  end

  def note_interaction(acting_user, acted_user, action)
    @edges[acted_user] ||= {in: {}, out: {}, attributes: []}
    @edges[acting_user] ||= {in: {}, out: {}, attributes: []}
    @edges[acting_user].in[acted_user] ||= {id: acted_user, attributes: []}
    @edges[acted_user].in[acting_user] ||= {id: acting_user, attributes: []}
    @edges[acted_user].out[acting_user] ||= {id: acting_user, attributes: []}
    @edges[acting_user].out[acted_user] ||= {id: acted_user, attributes: []}
    increment_count_for_edge_attribute(@edges[acting_user].in[acted_user], action)
    increment_count_for_edge_attribute(@edges[acted_user].out[acting_user], action)
    increment_count_for_edge_attribute(@edges[acted_user].in[acting_user], action)
    increment_count_for_edge_attribute(@edges[acting_user].out[acted_user], action)
  end
end
