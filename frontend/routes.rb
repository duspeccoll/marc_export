ArchivesSpace::Application.routes.draw do

  match('/plugins/marc_export' => 'marc_export#index', :via => [:get])
  match('/plugins/marc_export/export' => 'marc_export#export', :via => [:get, :post])

end
