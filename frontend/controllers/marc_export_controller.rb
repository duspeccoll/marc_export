class MarcExportController < ApplicationController

  set_access_control "view_repository" => [:index, :export]

  include ExportHelper

  def index
  end

  def export
    if is_number?(params[:days])
      ids = JSONModel::HTTP.get_json("/repositories/#{session[:repo_id]}/resources", {:all_ids => true, :modified_since => (DateTime.now-(params[:days].to_i)).to_time.to_i} )

      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml|
        xml.collection('xmlns' => "http://www.loc.gov/MARC21/slim", 'xmlns:marc' => "http://www.loc.gov/MARC21/slim")
      }
      doc = Nokogiri::XML(builder.to_xml)

      ids.each do |id|
        marc_uri = URI("#{JSONModel::HTTP.backend_url}/repositories/2/resources/marc21/#{id}.xml")
        marc = Nokogiri::XML(JSONModel::HTTP.get_response(marc_uri).body)
        marc.remove_namespaces!
        doc.root << marc.root.children
      end

      send_data doc.to_xml, :filename => "marc_export.xml"
    else
      flash[:error] = "Error: Value must be a valid integer or float point decimal"
      redirect_to request.referer
    end
  end

  private

  def is_number?(string)
    true if Float(string) rescue false
  end

end
