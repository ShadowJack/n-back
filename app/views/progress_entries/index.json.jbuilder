json.array!(@progress_entries) do |progress_entry|
  json.extract! progress_entry, :id, :opt,, :accuracy
  json.url progress_entry_url(progress_entry, format: :json)
end
