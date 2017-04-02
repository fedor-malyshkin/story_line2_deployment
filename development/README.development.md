# Reindex all crawler_id
1. Delete EL index: `curl -X DELETE ci.nlp-project.ru:9200/story_line2_read_index`
1. Connect to mongodb: `mongo --port 27017 -u "server_storm" -p "server_storm" --authenticationDatabase "storyline"`
1. Delete all indexed documents:
```
use storyline
db.news_entries.drop()
use crawler
db.crawler_entries.update( {"in_process": true}, {$set: {"in_process": false}}, {multi:true})
db.crawler_entries.update( {"processed": true}, {$set: {"processed": false}}, {multi:true})
```
