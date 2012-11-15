# -*- encoding : utf-8 -*-
( puts <<-INSTALL
 [ERROR] You don’t appear to have ElasticSearch installed. Please install and launch it with the following commands:

  curl -k -L -o elasticsearch-0.17.6.tar.gz http://github.com/downloads/elasticsearch/elasticsearch/elasticsearch-0.17.6.tar.gz
   tar -zxvf elasticsearch-0.17.6.tar.gz
    ./elasticsearch-0.17.6/bin/elasticsearch -f
INSTALL
exit(1) 
) unless (RestClient.get('http://0.0.0.0:9200') rescue false)
