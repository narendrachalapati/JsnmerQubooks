public class SYS_IntegrationLogTriggerHandler {
    public static void handleTrigger(List<SYS_IntegrationLog__c> newLogList, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when  AFTER_INSERT  {
                if(SYS_DataCache.enableCheck.get(SYS_Constants.INT_TYPE.toUpperCase())){
                    
                    SYS_DataCache.objectApiName = 'Custom_Parent__c';
                    System.debug('Extension class:'+SYS_DataCache.objectSettingMap.get(SYS_DataCache.objectApiName));
                    SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.objectSettingMap.get(SYS_DataCache.objectApiName).ApexHandler__c).newInstance();
                    appService.processLogAfterInsert(newLogList);
                }
                    
            }

            /*
            when  AFTER_UPDATE { 
                if(SYS_DataCache.enableCheck.get(SYS_Constants.INT_TYPE.toUpperCase()))
                    processLogAfterInsert(newLogList);
            }
            */
        }
    }

}
