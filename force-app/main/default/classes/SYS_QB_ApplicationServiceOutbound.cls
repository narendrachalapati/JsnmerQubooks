public class SYS_QB_ApplicationServiceOutbound extends SYS_ApplicationService {
    public SYS_QB_ApplicationServiceOutbound() {

    }
    public override List<sObject> transformJsonToSObject(String jsonBody,String resource) {
        Object responseType = JSON.deserializeUntyped(jsonBody);
        Object JSONwithoutrootkey ;
        if(responseType instanceof Map<String,Object>){
            JSONwithoutrootkey = (((Map<String, Object>)responseType).values())[0];
            system.debug('JSONForUpsert+++'+JSONwithoutrootkey);
            //((Map<String, Object>)responseType).get(JSONForUpsert);
            jsonBody = JSON.serialize(JSONwithoutrootkey);
              system.debug('jsonBody++++===='+jsonBody);
        }
      system.debug('jsonBody++++===='+jsonBody);

        return SYS_Transformer.getSObjectsToUpsert(new List<String>{jsonBody},resource);
    }
  
public override SYS_IntegrationLog__c generatelogForOutboundResult(HttpResponse resp,SYS_IntegrationLog__c log){
         SYS_IntegrationLog__c logResp = SYS_Helper.getLogsToInsert(resp.getBody());
         system.debug('logResp++'+logResp);
        if(resp.getStatusCode() != 201 && resp.getStatusCode() != 200){
            SYS_debug.log('#### resp status: '+resp.getStatus());
            SYS_debug.log('#### resp code: '+resp.getStatusCode()); 
            SYS_debug.log('#### resp: '+resp.getBody());
    
            
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Status__c.isCreateable()) {
                logResp.Status__c = 'ERROR';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Http_Status__c.isCreateable()) {
                logresp.SYS_Http_Status__c = integer.valueOf(resp.getStatusCode());
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_RequestId__c.isCreateable()) {
                logResp.SYS_RequestId__c = log.Id;
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.WhatId__c.isCreateable()) {
                logResp.WhatId__c = log.WhatId__c;
            }
            
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Type__c.isCreateable()) {
                logResp.Type__c = 'INBOUND';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_Operation_Type__c = 'RESPONSE';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.How_To_Process__c.isCreateable()) {
                logResp.How_To_Process__c = 'ignore_log';
                
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
            }
            
        }
        else{
    
    
            //--EX
            // logResp = new SYS_IntegrationLog__c();
            // List<SYS_IntegrationLog__c> exLogs = [Select Id,data0__c from SYS_IntegrationLog__c WHERE Id=:log.Id];
            // system.debug('exLogs===='+exLogs);
            // logResp = exLogs[0].clone(false,true,true,false);
            //EX--
    
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Status__c.isCreateable()) {
                //--EX logResp.Status__c = 'DONE';
                logResp.Status__c = 'NEW';
            }
            
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Http_Status__c.isCreateable()) {
                logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_RequestId__c.isCreateable()) {
                logResp.SYS_RequestId__c = log.Id;
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.WhatId__c.isCreateable()) {
                logResp.WhatId__c = log.WhatId__c;
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Type__c.isCreateable()) {
                logResp.Type__c = 'INBOUND';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.How_To_Process__c.isCreateable()) {
                //todo
             logResp.How_To_Process__c = 'use_object_setting';
                // logResp.How_To_Process__c = 'use_object_setting';
            }
            // if (Schema.sObjectType.SYS_IntegrationLog__c.fields.How_To_Process__c.isCreateable()) {
            //     //--EX logResp.How_To_Process__c = 'ignore_log';
            //     logResp.External_Id_Field_API_Name__c = 'Quickbooks_Id__c';
            // }
            
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                System.debug('MS log.SYS_Operation_Type__c:'+log.Parent__r.SYS_Operation_Type__c);
                if(log.SYS_Operation_Type__c == 'INSERT'){
                    logResp.SYS_Operation_Type__c = 'UPDATE';
                }
                else{
                    logResp.SYS_Operation_Type__c = log.SYS_Operation_Type__c;
                }
            }
            //logResp.Custom_Apex_Handler__c = 'SYS_ApplicationService';
           // logResp.Flat_Key_for_Resource__c = 'attributes.type'; //not required if JSON has root
            logResp.External_Id_Field_API_Name__c = SYS_DataCache.objectSettingsMap.get(SYS_DataCache.OBJ_TYPE).ExternalFieldApi__c;
            logResp.Custom_Field_Value__c = 'false';
        }

        return logResp;
    }
  
}
 