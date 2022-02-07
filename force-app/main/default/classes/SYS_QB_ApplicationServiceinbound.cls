//This class is maily used for overriding the methods in the sys application service 
//for inbound processing from webhook 
public class SYS_QB_ApplicationServiceinbound extends SYS_ApplicationService {
    public SYS_QB_ApplicationServiceinbound() {

    }
    //ToDo make url dynamic by lowercasing the entityName remove if and else statement
    
    //QB webhook is not providing the entire json so we need to do the get request and
    // give that response and return the syslog
    public override SYS_IntegrationLog__c generateLogForWebhookReq(String method) {

        String requestBody = RestContext.request.requestBody.toString();
        system.debug('requestBody====+' + requestBody);
        QBResponse respObj = (QBResponse) System.JSON.deserialize(requestBody, QBResponse.class);
        cls_eventNotifications evtNotify = respObj.eventNotifications != null ? respObj.eventNotifications[0] : new cls_eventNotifications();
        cls_dataChangeEvent dataChg = evtNotify.dataChangeEvent != null ? evtNotify.dataChangeEvent : null;
        cls_entities[] entity = dataChg != null ? (dataChg.entities != null ? dataChg.entities : null) : null;
        String entityName;
        String entityId;
        entityName = entity[0].name.toLowercase();
        system.debug('entityName===' + entityName);
        entityId = entity[0].id;
        system.debug('entityId' + entityId);
        Http http = new Http();
        HttpRequest getreq = new HttpRequest();
        IntegrationSetting__mdt integrationSetting = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE);
        String baseEndpoint = integrationSetting.BaseAPIEndPoint__c;
        List < HttpHeaders__mdt > httpHeader = SYS_DataCache.headerSetting;

        for (HttpHeaders__mdt head: httpHeader) {
            SYS_debug.log('header is = ' + head.MasterLabel + '' + head.Value__c);
            getreq.setHeader(String.valueOf(head.MasterLabel), String.valueOf(head.Value__c));

        }
        getreq.setMethod('GET');
        String resourceUrl;
        string resourcePath = '?minorversion=63';
        string resorce =  '/';
        resourceUrl = baseEndpoint + entityName +resorce + entityId + resourcePath;
        
         //  resourceUrl = baseEndpoint + entityName + '/' + entityId + resourcePath; 
       
        system.debug('resourceUrl======' + resourceUrl);
        getreq.setEndpoint(resourceUrl);

        HTTPResponse res = http.send(getreq);
        System.debug(res.getBody());
        System.debug('getStatusCode' + res.getStatusCode());
        //GET call with the event requestBody JSON as input
        //read the response and use that to generate the log record
        String getResponse = res.getBody();
        system.debug('getResponse===' + getResponse);
         
        
               
        SYS_IntegrationLog__c log = SYS_ApplicationService.getLogsToInsert(getResponse);

        //String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
        //if(algo!=NULL && algo!='')
        // log.Request_Digest__c = generateHash(requestBody,algo);

        log.Type__c = 'INBOUND';
      
          log.SYS_Operation_Type__c = 'UPSERT';   
      
          //log.SYS_Operation_Type__c = 'UPDATE'; 
        log.Flat_Key_for_Resource__c = '';
        log.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
        log.Status__c = 'NEW';
        log.External_Id_Field_API_Name__c = 'Quickbooks_Id__c';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = 'SYS_QB_ApplicationServiceinbound';
       // log.Requires_process_on_complete__c = true;

        return log;
    }
    /*public override String getResourceFromJSON(SYS_IntegrationLog__c log,String jsonBody){

        String resource = '';
        if(log.Flat_Key_for_Resource__c == NULL || log.Flat_Key_for_Resource__c == ''){
            //Root element identifies Resource
            Object responseType = JSON.deserializeUntyped(jsonBody);
            if(responseType instanceof Map<String,Object>){
                resource = new List<String>(((Map<String, Object>)responseType).keySet())[0];
            }
        }
        else{
            //Key mentioned in Flat_Key_for_Resource__c identifies Resource
            Map<String, Object> flatKeyMap = SYS_Transformer.makeJsonIntoKeyValuePairs(jsonBody);
            resource = (String)flatKeyMap.get(log.Flat_Key_for_Resource__c);
        }

        return resource;
    }*/
    //overriding the inbound class for preprocess the sys_logs before insert
   public override Boolean doInbound(SYS_IntegrationLog__c log) {
        String jsonBody = '';

        jsonBody = log.data0__c != null ? log.data0__c : '' +
            log.data1__c != null ? log.data1__c : '' +
            log.data2__c != null ? log.data2__c : '' +
            log.data3__c != null ? log.data3__c : '' +
            log.data4__c != null ? log.data4__c : '' +
            log.data5__c != null ? log.data5__c : '' +
            log.data6__c != null ? log.data6__c : '' +
            log.data7__c != null ? log.data7__c : '' +
            log.data8__c != null ? log.data8__c : '' +
            log.data9__c != null ? log.data9__c : '';
     system.debug('jsonBody++++'+jsonBody);
        string logJSONBody;
        logJSONBody = preprocessJSONForInbound(log, jsonBody);
        List < sObject > sObjectsToDML = transformJsonToSObject(logJSONBody, getResourceFromJSON(log, jsonBody));

        SYS_debug.log('\n\n - \n\n Application Service sObjects to DML:' + sObjectsToDML);

        String externalIdFieldAPIName = log.External_Id_Field_API_Name__c != NULL ? log.External_Id_Field_API_Name__c : '';
        //Schema.SObjectField externalIdField = Schema.getGlobalDescribe().get(SYS_DataCache.sObjectApiName).getDescribe().fields.getMap().get(externalIdFieldAPIName);

        //TODO DML Based on log operation type
        //Database.UpsertResult[] results = Database.upsert(sObjectsToDML,externalIdField, false);

        return doDML(sObjectsToDML, log.SYS_Operation_Type__c, externalIdFieldAPIName);
    }
      /* public override List<sObject> transformJsonToSObject(String jsonBody,String resource) {
      
             Object responseType = JSON.deserializeUntyped(jsonBody);
            Object JSONForUpsert ;
            if(responseType instanceof Map<String,Object>){
                JSONForUpsert = (((Map<String, Object>)responseType).values())[0];
                system.debug('JSONForUpsert+++'+JSONForUpsert);
                //((Map<String, Object>)responseType).get(JSONForUpsert);
                jsonBody = JSON.serialize(JSONForUpsert);
                  system.debug('jsonBody++++===='+jsonBody);
            }
          system.debug('jsonBody++++===='+jsonBody);
             return SYS_Transformer.getSObjectsToUpsert(new List<String>{jsonBody},resource);
    }*/
   public override String preprocessJSONForInbound(SYS_IntegrationLog__c log,String jsonBody) {
          Object responseType = JSON.deserializeUntyped(jsonBody);
            Object JSONForUpsert ;
            if(responseType instanceof Map<String,Object>){
                JSONForUpsert = (((Map<String, Object>)responseType).values())[0];
                system.debug('JSONForUpsert+++'+JSONForUpsert);
                //((Map<String, Object>)responseType).get(JSONForUpsert);
                jsonBody = JSON.serialize(JSONForUpsert);
                  system.debug('jsonBody++++===='+jsonBody);
            }
          system.debug('jsonBody++++===='+jsonBody);
        return jsonBody;
    }
   /*public override Boolean doUpsert(List<sObject> records,String additionalSetting){
       Database.UpsertResult[] results;
        Boolean success = true;
        if(additionalSetting=='')
           
            results = Database.upsert(records, false);
        else{
            Schema.SObjectField externalIdField = Schema.getGlobalDescribe().get(SYS_DataCache.sObjectApiName).getDescribe().fields.getMap().get(additionalSetting); 
            
            
            results = Database.upsert(records, externalIdField, false);
            system.debug('results==++'+results);
        }
        
        if(!results[0].isSuccess()){
            success = false;
            handleDMLErrors(results[0].getErrors());
        }

        return success; 
   }*/
   
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