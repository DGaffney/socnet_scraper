class Graph
  def initialize(graph)
    @nodes = graph.nodes
    @edges = graph.edges
  end
  def to_gexf(file=StringIO.new("", "w+"))
    gexf = GEXF.new(file)
    gexf.header_declaration;false
    gexf.graph_declaration;false
    gexf.attribute_declarations(attribute_declarations);false
    gexf.nodes(@nodes);false
    gexf.edges(@edges);false
    gexf.footer;false
    gexf.file.rewind
    gexf.file
  end

  def attribute_declarations
    {node: {static: []}, edge: {static: []}}
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
end
