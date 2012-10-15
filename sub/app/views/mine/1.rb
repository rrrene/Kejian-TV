Dir['./*.erb'].each do |filepath|
  File.open(filepath) do |f|
    while(line=f.gets)
      if line=~/src="\/\/([^"]+)"/
        now = "http://"+ $1
        puts "wget -x #{now}"
      end
    end
  end
end
