//This class is maily used for overriding the methods in the sys application service 
//for inbound processing from webhook 
public class SYS_QB_ApplicationServiceinbound extends SYS_ApplicationService {
    public SYS_QB_ApplicationServiceinbound() {
 }
   public override  List<sObject> transformJsonToSObject(String jsonBody,String resource,SYS_IntegrationLog__c log) {
        Object responseType = JSON.deserializeUntyped(jsonBody);
        system.debug('jsonBody+++===**'+jsonBody);
        Object JSONwithoutrootkey;
        if(SYS_DataCache.log.Parent__c==Null){
        if(responseType instanceof Map<String,Object>){
            JSONwithoutrootkey = (((Map<String, Object>)responseType).values())[0];
            system.debug('JSONForUpsert+++'+JSONwithoutrootkey);
            //((Map<String, Object>)responseType).get(JSONForUpsert);
            jsonBody = JSON.serialize(JSONwithoutrootkey);
              system.debug('jsonBody++++===='+jsonBody);
        }

    }
  
   system.debug('jsonBody++++===='+jsonBody);
      List<sObject> sobjlist=  SYS_Transformer.getSObjectsToUpsert(new List<String>{jsonBody},resource,(log.Type__c=='INBOUND'));
     
      system.debug('sobjlist+++++=='+sobjlist);
      
        return sobjlist;
    
    }
    Public override Boolean doUpsert(List<sObject> records,String additionalSetting,SYS_IntegrationLog__c log){
        Database.UpsertResult[] results;
        Boolean success = true;
        if(additionalSetting==''||additionalSetting==Null)
            results = Database.upsert(records, false);
        else{
            System.debug('--MS externalIdField for:'+records[0]);
            //Schema.SObjectField externalIdField = Schema.getGlobalDescribe().get(SYS_DataCache.sObjectApiName).getDescribe().fields.getMap().get(additionalSetting); 
            
            Schema.SObjectField externalIdField = records[0].getSObjectType().getDescribe().fields.getMap().get(additionalSetting); 
            System.debug('--MS externalIdField in doUpsert:'+externalIdField);
            
            results = Database.upsert(records, externalIdField, false);
        }
        
        System.debug('--MS Log check # '+log.Id+' has WhatId: '+results[0].getId());

        if(!results[0].isSuccess()){
            success = false;
            handleDMLErrors(results[0].getErrors(),log);
        }
        else{
            log.WhatId__c = results[0].getId();
        }
        System.debug('--MS Log re-check # '+log.Id+' has WhatId: '+log.WhatId__c);

        return success;
    }
    class QBResponse {
        public cls_eventNotifications[] eventNotifications;
    }
    class cls_eventNotifications {
        public String realmId; //4620816365183321250
        public cls_dataChangeEvent dataChangeEvent;
    }
    class cls_dataChangeEvent {
        public cls_entities[] entities;
    }
    class cls_entities {
        public String name; //Customer
        public String id; //21
        public String operation; //Create
        public String lastUpdated; //2021-08-02T07:54:33.000Z
    }
   

}