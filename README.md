# ruby scripts for sfdc
|script|describe|status|
|---|---|---|
|delete_custom_field|delete custom field from json file|available|
|view_objects_list|view custom object list|available|
|view_layout_list|view layout list|available|

## to be improve
+ add test
+ delete over 10 fields
  + 各実行でresultを見て、失敗時だけ結果をputsするようにする

## connection setting
create service/sfdc.yaml, like this.
```yaml
username: xxx@xxx.co.jp
password: xxxxxxxx
security_token: 
endpoint: https://test.salesforce.com/services/Soap/u/38.0
```

## specify delete field
create delete_custom_field/target.json, like this.
```json
{
  "CustomObject1__c": [
    "Field1__c",
    "Field2__c"
  ],
  "CustomObject2__c": [
    "Field3__c",
    "Field4__c"
  ]
}
```

# future
go gem
