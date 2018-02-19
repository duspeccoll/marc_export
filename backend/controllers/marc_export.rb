class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/repositories/:repo_id/marc_export')
    .description("Download MARC records for all collections updated in the given time period")
    .params(["repo_id", :repo_id],
            ["modified_since", String, "Time since the last MARC export"])
    .permissions([])
    .returns([200, "OK"]) \
  do
    marc = marc_export(params)

    xml_response(marc)
  end

  private

  def is_number?(string)
    true if Float(string) rescue false
  end

  def marc_export_builder(ids)
    builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
      xml.collection('xmlns' => "http://www.loc.gov/MARC21/slim", 'xmlns:marc' => "http://www.loc.gov/MARC21/slim")
    end

    doc = Nokogiri::XML(builder.to_xml)

    ids.each do |id|
      marc = Nokogiri::XML(generate_marc(id))
      doc.root << marc.root.children
    end

    doc.to_xml
  end

  def marc_export(params)
    if is_number?(params[:modified_since])
      dataset = CrudHelpers.scoped_dataset(Resource, {})
      dataset = dataset.where { system_mtime >= Time.at(params[:modified_since].to_i) }

      ids = dataset.select(:id).map{|rec| rec[:id]}

      if ids.empty?
        raise StandardError, 'No new or updated resources for the time period'
      else
        marc_export_builder(ids)
      end
    else
      raise StandardError, 'Value must be a valid integer or float point decimal'
    end
  end
end
