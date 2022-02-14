public class SYS_QB_ApplicationServiceOutbound extends SYS_ApplicationService {
    public SYS_QB_ApplicationServiceOutbound() {

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

    //     //here we are doing comparison with the what id in the syslog to elemenate the duplicate record creation
    //     String jsonBody = '';
       
    //     jsonBody =  logResp.data0__c != null ? logResp.data0__c : '' +
    //                 logResp.data1__c != null ? logResp.data1__c : '' +
    //                 logResp.data2__c != null ? logResp.data2__c : '' +
    //                 logResp.data3__c != null ? logResp.data3__c : '' +
    //                 logResp.data4__c != null ? logResp.data4__c : '' +
    //                 logResp.data5__c != null ? logResp.data5__c : '' +
    //                 logResp.data6__c != null ? logResp.data6__c : '' +
    //                 logResp.data7__c != null ? logResp.data7__c : '' +
    //                 logResp.data8__c != null ? logResp.data8__c : '' +
    //                 logResp.data9__c != null ? logResp.data9__c : '' ;

      
    //     List<sObject> recordList = new List<sObject>();
        
    //      Map<String, Object> flatKeyMap = SYS_Transformer.makeJsonIntoKeyValuePairs(jsonBody);
    //         system.debug('flatKeyMap'+flatKeyMap);
    //     String recId = log.WhatId__c;
    //     //String triggering_flow__c = logResp.Custom_Field_Value__c;
        
    //     if( (recId !='' || recId != null) && log.SYS_Operation_Type__c =='INSERT'){
    //     String objectApiName = ((Id)recId).getSobjectType() + '';
    //     Object responseType = JSON.deserializeUntyped(jsonBody);
    //        String rootKey;
    //     if(responseType instanceof Map<String , Object>) {
    //          rootKey = new List<String>(((Map<String, Object>)responseType).keySet())[0];
    //     }

    //     String constructKey = rootKey +'.Id';
    //     String constructToken =  rootKey +'.SyncToken';
        
    //     String externalId = String.valueof(flatKeyMap.get(constructKey));
    //     String syncToken = String.valueof(flatKeyMap.get(constructToken));
    //     sObject record = Schema.getGlobalDescribe().get(objectApiName).newSObject(((Id)recId));
    //     // if(rootKey.equalsIgnoreCase('Invoice') ) {
    //     //     record.put('CloseDate',System.Today());
    //     //     record.put(' Name','testing');
    //     //     record.put('StageName','Qualification');
    //     // }
    //     record.put('Id' , recId); 
    //     //record.put ('triggering_flow__c',logResp.Custom_Field_Value__c);
    //     record.put('Quickbooks_Id__c' , externalId); 
    //     record.put('QB_SyncToken__c', syncToken);
    //     List<sObject> sObjectsToDML= new List<sObject>();
    //                   sObjectsToDML.add(record);
    //     SYS_debug.log('\n\n ------------------------------- \n\n Application Service sObjects to DML:'+sObjectsToDML);

    //     String externalIdFieldAPIName = '';
    //   // Boolean triggering_flow__c = logResp.Custom_Field_Value__c ;
               
    //    Boolean sobj =   doDML(sObjectsToDML,logResp.SYS_Operation_Type__c,externalIdFieldAPIName);
    //     }
        return logResp;
    }
    public override List<sObject> getMissingIdForUpdate(List<sObject> sObjectsToDML) {
        for(sObject s:sObjectsToDML){
            if(s.Id == NULL){
                s.Id = SYS_DataCache.log.WhatId__c;
            }
        }
        return sObjectsToDML;
    }
}
 