public class SYS_IntegrationLogOutboundQueueable implements Queueable, Database.AllowsCallouts{ 
   
    private List<Id> sysLogIds = new List<Id>();
    
    public SYS_IntegrationLogOutboundQueueable(List<Id> idList){
        this.sysLogIds = idList;
    }
    public void execute(QueueableContext context){

        List<Id> sysLogResponse = new List<Id>(); //user to trigger the async class to update SyncToken from response.
 
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
                                              Type__c,WhatId__c,Parent__c,Order__c,ObjectSettingId__c,SYS_IntegrationSettings__c
                                              FROM SYS_IntegrationLog__c WHERE Id in:sysLogIds];
        //TODO - the below code will cosider parent__c look up as empty and order__c as empty. 
        
        List<sObject> recordList = new List<sObject>();
        //TODO - field for QB 
        //TODO - class for setting http req.
        //TODO - HTTPBuilder, SYS_IntegrationLogHandler global class(override for integration and prod specific)
        //if(integrationSetting.size() != 0){
            
            for(SYS_IntegrationLog__c log:sysLog) {
                SYS_debug.log('inside for loop'+Id.valueof(log.WhatId__c).getsobjecttype());
                
                SYS_DataCache.INT_TYPE = log.SYS_IntegrationSettings__c;
                SYS_DataCache.OBJ_TYPE = log.ObjectSettingId__c;
                SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ApexHandler__c).newInstance();
                HttpResponse outboundResponse = appService.doOutbound(log);

                insertResponse.add(appService.processOutboundResult(outboundResponse,log));

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
                
            } 
            
       // }else {
            //Integration Setting not found
       // }
    }
   
}