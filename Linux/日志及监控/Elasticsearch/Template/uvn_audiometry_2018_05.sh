curl -XPUT '192.168.100.106:9200/uvn_audiometry_2018_05/_mapping/audiometry?pretty' -H 'Content-Type: application/json' -d '{
    "audiometry": {
        "properties": {
            "myContent": {
                "type": "keyword"
            },
            "myWhy": {
                "type": "keyword"
            },
            "myTime": {
                "type": "date",
                "format": "yyyyMMddHH:mm:ssSSS||yyyyMMddHH:mm:ss||date_time"
            },
            "ifMy": {
                "type": "boolean"
            },
            "levelId": {
                "type": "keyword"
            }
        }
    }
}
'