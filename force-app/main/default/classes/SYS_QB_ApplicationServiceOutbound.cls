public class SYS_QB_ApplicationServiceOutbound extends SYS_ApplicationService {
    public SYS_QB_ApplicationServiceOutbound() {

    }
 public override SYS_IntegrationLog__c generatelogForOutboundResult(HttpResponse resp,SYS_IntegrationLog__c log){
       SYS_IntegrationLog__c logResp = getLogsToInsert(resp.getBody());
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

            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Status__c.isCreateable()) {
                logResp.Status__c = 'DONE';
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
                logResp.How_To_Process__c = 'use_custom_apex_handler';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.How_To_Process__c.isCreateable()) {
                logResp.Custom_Apex_Handler__c  = 'override_SYS_ApplicationService';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_Operation_Type__c = 'UPSERT';
            }
        }

        return logResp;
    }
    //immediate response for outbond processing response 
   public override Boolean doInbound(SYS_IntegrationLog__c log) {
        String jsonBody = '';
        
        jsonBody =  log.data0__c != null ? log.data0__c : '' +
                    log.data1__c != null ? log.data1__c : '' +
                    log.data2__c != null ? log.data2__c : '' +
                    log.data3__c != null ? log.data3__c : '' +
                    log.data4__c != null ? log.data4__c : '' +
                    log.data5__c != null ? log.data5__c : '' +
                    log.data6__c != null ? log.data6__c : '' +
                    log.data7__c != null ? log.data7__c : '' +
                    log.data8__c != null ? log.data8__c : '' +
                    log.data9__c != null ? log.data9__c : '' ;

        jsonBody = preprocessJSONForInbound(log,jsonBody);
        List<sObject> recordList = new List<sObject>();
         Map<String, Object> flatKeyMap = SYS_Transformer.makeJsonIntoKeyValuePairs(jsonBody);
        String recId = log.WhatId__c;
        String objectApiName = ((Id)recId).getSobjectType() + '';
        Object responseType = JSON.deserializeUntyped(jsonBody);
           String rootKey;
        if(responseType instanceof Map<String , Object>) {
             rootKey = new List<String>(((Map<String, Object>)responseType).keySet())[0];
        }
         String constructKey = rootKey +'.Id';
         String constructToken =  rootKey +'.SyncToken'; 
        
        String externalId = String.valueof(flatKeyMap.get(constructKey));
        String syncToken = String.valueof(flatKeyMap.get(constructToken));
        sObject record = Schema.getGlobalDescribe().get(objectApiName).newSObject(((Id)recId));
        record.put('Quickbooks_Id__c' , externalId); 
        record.put('QB_SyncToken__c', syncToken);
        List<sObject> sObjectsToDML= new List<sObject>();
                      sObjectsToDML.add(record);
        SYS_debug.log('\n\n ------------------------------- \n\n Application Service sObjects to DML:'+sObjectsToDML);

        String externalIdFieldAPIName = log.External_Id_Field_API_Name__c!=NULL?log.External_Id_Field_API_Name__c:'';
        //Schema.SObjectField externalIdField = Schema.getGlobalDescribe().get(SYS_DataCache.sObjectApiName).getDescribe().fields.getMap().get(externalIdFieldAPIName);

        //TODO DML Based on log operation type
        //Database.UpsertResult[] results = Database.upsert(sObjectsToDML,externalIdField, false);
               
        return doDML(sObjectsToDML,log.SYS_Operation_Type__c,externalIdFieldAPIName);
    }   
    
 
    //public override HttpResponse doOutbound(SYS_IntegrationLog__c log){
        //System.debug('\n In override_SYS_ApplicationService');
        //return super.doOutbound(log);
   // }

      
}