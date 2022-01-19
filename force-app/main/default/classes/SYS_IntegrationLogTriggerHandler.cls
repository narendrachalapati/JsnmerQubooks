public class SYS_IntegrationLogTriggerHandler {
    public static void handleTrigger(List<SYS_IntegrationLog__c> newLogList, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when  AFTER_INSERT  {
                if(SYS_DataCache.enableCheck.get(SYS_DataCache.INT_TYPE.toUpperCase())){
                    
                    System.debug('Extension class:'+SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE));
                    SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ApexHandler__c).newInstance();
                    appService.processLogAfterInsert(newLogList);
                }
                    
            }

            /*
            when  AFTER_UPDATE { 
                if(SYS_DataCache.enableCheck.get(SYS_DataCache.INT_TYPE.toUpperCase()))
                    processLogAfterInsert(newLogList);
            }
            */
        }
    }

}
