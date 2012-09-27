# -*- encoding : utf-8 -*-
require 'fileutils'
Dir['./*'].each do |f|
  n =File.basename f
  if n[0]=='_'
    nn = n.dup
    nn=nn[1..-1]
    FileUtils.mv n,nn
  end
end
