public class SYS_QB_ApplicationServiceOutbound extends SYS_ApplicationService {
    public SYS_QB_ApplicationServiceOutbound() {

    }
    //We are removing the root of the json to make sure that inbound and outbound mappings are same
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
  

    public override SYS_IntegrationLog__c generateLogForChildRecords(String parentLogId,String resource,String recordsJson,String integrationSetting) {
        SYS_IntegrationLog__c log = SYS_Helper.getLogsToInsert(recordsJson);
        system.debug('log+++'+log);

        String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
        if(algo!=NULL && algo!='')
            log.Request_Digest__c = generateHash(recordsJson,algo);

        SYS_debug.log('MS SYS_DataCache.log in generate child log:'+SYS_DataCache.log.Id);
        log.Parent__c = parentLogId;
        log.Resource__c = resource;
        log.Type__c = 'INBOUND';
        //Todo
        log.SYS_Operation_Type__c = 'UPSERT';
        log.Flat_Key_for_Resource__c = '';
        log.SYS_IntegrationSettings__c = integrationSetting;
        log.Status__c = 'NEW';//'WAITING_FOR_PARENT';
       
        /**
         * Applies when the child records require parenting after creation
         */
        log.Requires_process_on_complete__c = true;
        log.On_Complete_Handler__c = 'SYS_ApplicationService';
        /** */

        //log.External_Id_Field_API_Name__c = 'SYS_Child_Key__c';
        log.How_to_process__c = 'ignore_log';
        log.Custom_Apex_Handler__c = 'SYS_QB_ApplicationServiceOutbound';

        return log;
    }

   
   }
   

 