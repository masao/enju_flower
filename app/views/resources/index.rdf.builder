xml.instruct! :xml, :version=>"1.0" 
xml.rdf(:RDF,
        'xmlns'  => "http://purl.org/rss/1.0/",
        'xmlns:rdf'  => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
        'xmlns:foaf' => "http://xmlns.com/foaf/0.1/",
        'xmlns:prism' => "http://prismstandard.org/namespaces/basic/2.0/",
        'xmlns:rdfs' =>"http://www.w3.org/2000/01/rdf-schema#"){
  xml.channel("rdf:about" => resources_url(:params => params.merge(:format => 'rdf'))){
    xml.title t('manifestation.query_search_result', :query => @query, :library_group_name => @library_group.display_name.localize)
    xml.link "#{request.protocol}#{request.host_with_port}#{url_for(params.merge(:format => nil))}"
    xml.description "Next-L Enju, an open source integrated library system developed by Project Next-L"
    xml.language @locale
    xml.ttl "60"
    if @resources
      xml.items do
        xml.tag! "rdf:Seq" do
          @resources.each do |manifestation|
            xml.tag! "rdf:li", 'rdf:resource' => resource_url(manifestation)
          end
        end
      end
    end
  }
  @resources.each do |manifestation|
    xml << render(:partial => 'manifestations/show', :locals => {:manifestation => manifestation})
  end
}
