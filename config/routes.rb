IiifPrint::Engine.routes.draw do
  post "split_pdfs/:file_set_id" => "split_pdfs#create", as: :split_pdf
end
