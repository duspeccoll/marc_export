class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/repositories/:repo_id/marc_export/:days')
    .description("Download MARC records for all collections updated in the given time period")
    .params(["repo_id", :repo_id],
            ["days", String, "Record updated in the last X days"])
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
    if is_number?(params[:days])
      dataset = CrudHelpers.scoped_dataset(Resource, {})
      modified_since_time = Time.at((DateTime.now-(params[:days].to_i)).to_time.to_i)
      dataset = dataset.where { system_mtime >= modified_since_time }

      ids = dataset.select(:id).map{|rec| rec[:id]}

      marc_export_builder(ids)
    else
      raise StandardError, 'Value must be a valid integer or float point decimal'
    end
  end
end
