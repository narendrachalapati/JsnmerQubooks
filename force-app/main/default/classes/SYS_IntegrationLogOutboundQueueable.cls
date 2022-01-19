public class SYS_IntegrationLogOutboundQueueable implements Queueable, Database.AllowsCallouts{ 
   
    private List<Id> sysLogIds = new List<Id>();
    
    public SYS_IntegrationLogOutboundQueueable(List<Id> idList){
        this.sysLogIds = idList;
    }
    public void execute(QueueableContext context){

        List<Id> sysLogResponse = new List<Id>(); //user to trigger the async class to update SyncToken from response.
        
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        List<SYS_IntegrationLog__c> insertResponse = new List<SYS_IntegrationLog__c>();
        List<SYS_IntegrationLog__c> sysLog = [SELECT id,
                                              data0__c,
                                              data1__c,
                                              data2__c,
                                              data3__c,
                                              data4__c,
                                              data5__c,
                                              data6__c,
                                              data7__c,
                                              data8__c,
                                              data9__c,
                                              Type__c,WhatId__c,Parent__c,Order__c
                                              FROM SYS_IntegrationLog__c WHERE Id in:sysLogIds];
        //TODO - the below code will cosider parent__c look up as empty and order__c as empty. 
        List<IntegrationSetting__mdt> integrationSetting = SYS_DataCache.integrationSetting;
        String baseEndpoint = integrationSetting[0].BaseAPIEndPoint__c;
        List<sObject> recordList = new List<sObject>();
        //TODO - field for QB 
        //TODO - class for setting http req.
        //TODO - HTTPBuilder, SYS_IntegrationLogHandler global class(override for integration and prod specific)
        if(integrationSetting.size() != 0){
            List<HttpHeaders__mdt> httpHeader = SYS_DataCache.headerSetting;
            req.setMethod(integrationSetting[0].UpdateMethod__c);
            for(HttpHeaders__mdt head:httpHeader){
                SYS_debug.log('header is = '+head.MasterLabel + ''+head.Value__c);
                req.setHeader(String.valueOf(head.MasterLabel), String.valueOf(head.Value__c));
                
            } 
            
            for(SYS_IntegrationLog__c log:sysLog) {
                SYS_debug.log('inside for loop'+Id.valueof(log.WhatId__c).getsobjecttype());
                String body = log.data0__c != null ? log.data0__c : '' +
                            log.data1__c != null ? log.data1__c : '' +
                            log.data2__c != null ? log.data2__c : '' +
                            log.data3__c != null ? log.data3__c : '' +
                            log.data4__c != null ? log.data4__c : '' +
                            log.data5__c != null ? log.data5__c : '' +
                            log.data6__c != null ? log.data6__c : '' +
                            log.data7__c != null ? log.data7__c : '' + 
                            log.data8__c != null ? log.data8__c : '' +
                            log.data9__c != null ? log.data9__c : '' ; 
            
                
                Schema.SObjectType objectApiName = Id.valueof(log.WhatId__c).getsobjecttype();
                SYS_debug.log('sObject api name ='+objectApiName); 
                req.setEndpoint(SYS_HttpBuilder.getResourceUrlFromObjectApi( String.valueOf(objectApiName)));
                req.setBody(body);
                system.debug('body'+body);
                 
                //##Hit the webservice
                //TODO - Use limit api to avoid gov limit
                //TODO - add a method for response log
                HttpResponse resp = http.send(req);
                if(resp.getStatusCode() != 201){
                    SYS_debug.log('#### resp status: '+resp.getStatus());
                    SYS_debug.log('#### resp code: '+resp.getStatusCode()); 
                    SYS_debug.log('#### resp: '+resp.getBody());

                    SYS_IntegrationLog__c logResp = new SYS_IntegrationLog__c();//--M SYS_integrationLogHandler.getLogsToInsert(resp.getBody());
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
                    // if (Schema.sObjectType.SYS_IntegrationLog__c.fields.QB_Entity__c.isCreateable()) {
                    logResp.QB_Entity__c = objectApiName + '';
                    
                    if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Type__c.isCreateable()) {
                    logResp.Type__c = 'INBOUND';
                    }
                    if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                    logResp.SYS_Operation_Type__c = 'RESPONSE';
                    }
                    if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                        logResp.SYS_IntegrationSettings__c = SYS_Constants.INT_TYPE;
                    }
                    insertResponse.add(logResp);
                }
                else{
                    
                    SYS_IntegrationLog__c logResp = new SYS_IntegrationLog__c();//-- M SYS_integrationLogHandler.getLogsToInsert(resp.getBody());
                    if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Http_Status__c.isCreateable()) {
                    logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
                    }
                    if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_RequestId__c.isCreateable()) {
                    logResp.SYS_RequestId__c = log.Id;
                    }
                    if (Schema.sObjectType.SYS_IntegrationLog__c.fields.WhatId__c.isCreateable()) {
                    logResp.WhatId__c = log.WhatId__c;
                    }
                    // if (Schema.sObjectType.SYS_IntegrationLog__c.fields.QB_Entity__c.isCreateable()) {
                    logResp.QB_Entity__c = objectApiName + '';
                    // }
                    if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Type__c.isCreateable()) {
                    logResp.Type__c = 'INBOUND';
                    }
                    if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                        logResp.SYS_IntegrationSettings__c = SYS_Constants.INT_TYPE;
                    }
                    if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                    logResp.SYS_Operation_Type__c = 'RESPONSE';
                    }
                    insertResponse.add(logResp);
                }
        	}
            
            if(insertResponse.size() > 0){
                SYS_debug.log('##insert all response logs');
                Database.SaveResult[] results = Database.insert(insertResponse, false);
                for(Database.SaveResult result : results){
                    if(result.isSuccess()){
                        sysLogResponse.add(result.getId());
                    } else {
                        SYS_debug.log('Insertion error has occured.');
                        for(Database.Error err : result.getErrors()) {
                            SYS_debug.log('The following error has occurred.');                    
                            SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
                            SYS_debug.log('Fields affected are: ' + err.getFields());
                        }
                    }
                }
                //TODO - Add the queueable class to process response.
                //System.enqueueJob(new SYS_processResponse_QB(sysLogResponse));
                // SYS_processResponse_QB instance = new SYS_processResponse_QB(sysLogResponse);
                // if(SYS_Constants.INT_TYPE == 'Quickbooks')
                //     instance.updateSyncToken();
            } 
            
        } else {
            
        }
    }
   
}