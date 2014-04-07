json.array!(@coursewares) do |courseware|
  json.extract! courseware, :id
  json.url courseware_url(courseware, format: :json)
end
