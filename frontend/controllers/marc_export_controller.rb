class MarcExportController < ApplicationController

  set_access_control "view_repository" => [:index, :export]

  def index
  end

  def export
    response = JSONModel::HTTP.post_form("/repositories/#{JSONModel::repository}/marc_export/#{params[:days]}")
    if response.code == '200'
      respond_to do |format|
        format.html {
          self.response.headers["Content-Type"] = "application/xml"
          self.response.headers["Content-Disposition"] = "attachment; filename=marc_export.xml"

          self.response_body = response.body
        }
      end
    else
      # there must be a better way to override the default Sinatra::NotFound message on a 404
      error = case response.code
      when '404'
        "'days' is a required parameter"
      else
        ASUtils.json_parse(response.body)['error']
      end

      flash['error'] = I18n.t("plugins.marc_export.error", error: error)
      redirect_to request.referer
    end
  end
end
