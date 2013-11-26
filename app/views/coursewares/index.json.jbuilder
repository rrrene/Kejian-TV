json.result @coursewares do |json,item|
  json.partial! 'pin_cw', courseware: item
end

json.hasNextPage (@page_count > @page)
json.hasPrePage (@page > 1)
json.pageNo @page
json.boards []
