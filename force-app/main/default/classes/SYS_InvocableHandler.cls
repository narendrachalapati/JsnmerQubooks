global class SYS_InvocableHandler {
	
    global class MyInvocableVariable {
        @InvocableVariable(label='Id' required=true)  
        global Id recId;
    
        @InvocableVariable(label='Old Value' required=true)  
        global sObject oldVal;
    
        @InvocableVariable(label='Current Value' required=true)
        global sObject newVal;

        @InvocableVariable(label= 'Integration Setting' required = true)
        global String integrationSetting; 

        @InvocableVariable(label= 'Operation Type' required = true)
        global String operationType;
    }
    
    //TODO - remove descriptio
    @InvocableMethod(label='Old and Current Value' description='Print Old and Current Values')
    global static void printOldAndCurrentValues(List<MyInvocableVariable> myInvocableVariableList) {
    	List<sObject> newList = new List<sObject>();
        List<sObject> oldList = new List<sObject>();
        
        Map<String, Object> discountMap = new Map<String, Object>();
        String objectApiName = '';
        String operationType = myInvocableVariableList.size() > 0 ? myInvocableVariableList[0].operationType.toUppercase() : 'INSERT';

        for(MyInvocableVariable itr:myInvocableVariableList){
            objectApiName = ((Id)itr.recId).getSobjectType() + '';
            newList.add(itr.newVal);   
            oldList.add(itr.oldVal);
            SYS_Constants.INT_TYPE = itr.integrationSetting;
        } 
        Map<Id, String> newjson = SYS_Transformer.getRequestJson(newList);
        List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();
       
        if(newjson.values().size() > 0){
            for(Id iter:newjson.keyset()){ 
                system.debug('iter123'+iter);
                String addrChange;
                
                addrChange = newjson.get(iter).replace('\n',' ');
                 system.debug('i123'+addrChange);

                //TODO - QB specific change for bundle product  
                
                
                
                SYS_IntegrationLog__c  newSysLog = new SYS_IntegrationLog__c();//-- Deployment Fix SYS_integrationLogHandler.getLogsToInsert(addrChange);
                newSysLog.Status__c = 'NEW';
                newSysLog.Type__c = 'OUTBOUND';
                newSysLog.SYS_IntegrationSettings__c = SYS_Constants.INT_TYPE;
                newSysLog.SYS_Operation_Type__c = operationType;
                newSysLog.whatid__c = iter;
                insertSysLog.add(newSysLog);   
            }
            if(!insertSysLog.isEmpty() && SYS_DataCache.enableCheck.get(SYS_Constants.INT_TYPE.toUpperCase())){ 
                SYS_debug.log('inside insert'+insertSysLog.size());
                insert insertSysLog;
                system.debug('insertSysLog=='+insertSysLog);
            }
            
        }
    }

    public class productWrapper {
        public String Type;
    }
}