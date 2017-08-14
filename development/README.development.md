# Reindex all crawler_id
1. Delete EL index: `curl -X DELETE ci.nlp-project.ru:9200/story_line2_v1`
1. Create EL empty index: `curl -X PUT ci.nlp-project.ru:9200/story_line2_v1`
1. Create EL index aliases: `curl -X PUT ci.nlp-project.ru:9200/story_line2_v1/_alias/story_line2_read_index`
1. Create EL index aliases: `curl -X PUT ci.nlp-project.ru:9200/story_line2_v1/_alias/story_line2_write_index`
1. Connect to mongodb: `mongo --port 27017 -u "server_storm" -p "server_storm" --authenticationDatabase "storyline"`
1. Delete all indexed documents:
```
use storyline
db.news_entries.drop()
use crawler
db.crawler_entries.update( {"in_process": true}, {$set: {"in_process": false}}, {multi:true})
db.crawler_entries.update( {"processed": true}, {$set: {"processed": false}}, {multi:true})
```
# Query elasticsearch
```
curl -XGET 'ci.nlp-project.ru:9200/story_line2_v1/_search?pretty' -H 'Content-Type: application/json' -d'
{
	"_source": [ "publication_date", "title", "path", "source", "image_url", "url" ],
 	"sort" : [{ "publication_date" : {"order" : "desc"}}],    
    "query" : {
        "term" : { "source" : "bnkomi.ru" }

    }
}'

```
