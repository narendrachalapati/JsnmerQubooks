//This class is maily used for overriding the methods in the sys application service 
//for inbound processing from webhook 
public class SYS_QB_ApplicationServiceinbound extends SYS_ApplicationService {
    public SYS_QB_ApplicationServiceinbound() {

    }
    public static final Map<String,String> resourceChildMap = new Map<String,String>{'invoice'=>'line','refundreceipt'=>'salesitemlinedetail'};
    //ToDo make url dynamic by lowercasing the entityName remove if and else statement
    
    //QB webhook is not providing the entire json so we need to do the get request and
    // give that response and return the syslog
    public override SYS_IntegrationLog__c generateLogForWebhookReq(String method) {
        String resource = '';

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
         
        Object responseType = JSON.deserializeUntyped(getResponse);
        // if(responseType instanceof Map<String,Object>){
        //     resource = new List<String>(((Map<String, Object>)responseType).keySet())[0];
        //     resource;
        //     system.debug('resource+++++++===='+resource);
        // }
               
        SYS_IntegrationLog__c log = SYS_Helper.getLogsToInsert(getResponse);

        //String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
        //if(algo!=NULL && algo!='')
        // log.Request_Digest__c = generateHash(requestBody,algo);

        String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
        if(algo!=NULL && algo!='')
        log.Request_Digest__c = generateHash(requestBody,algo);

        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = getOperationTypeFor(method);
        log.Resource__c = resource;
        log.Integration_Setting__c = SYS_DataCache.INT_TYPE;
        log.Status__c = 'NEW';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c;
        log.Resource__c = entityName;
        
        return log;
    }
  
    //when we removed the root key it not returing the restresorce that path so it not identifying the sobject so thats why 
    //we overriden the get resource method for identifying the ecaxt resource path 

  /**
     * This hook is called from doInbound to identify resource from incoming JSON
     * Arguement: SYS Log record and JSON Body
     * Default is return the root if it exists or the value of falt key mentioned in Flat_Key_for_Resource__c field on log record
     * Override if custom implementation is required for identifying the resoruce for inbound request
     */
    public override List<sObject> transformJsonToSObject(String jsonBody,String resource) {
        Object responseType = JSON.deserializeUntyped(jsonBody);
        system.debug('jsonBody+++===**'+jsonBody);
        Object JSONwithoutrootkey;
        if(SYS_DataCache.log.Parent__c==Null){
        if(responseType instanceof Map<String,Object>){
            JSONwithoutrootkey = (((Map<String, Object>)responseType).values())[0];
            system.debug('JSONForUpsert+++'+JSONwithoutrootkey);
            //((Map<String, Object>)responseType).get(JSONForUpsert);
            jsonBody = JSON.serialize(JSONwithoutrootkey);
              system.debug('jsonBody++++===='+jsonBody);
        }

    }
  
  
      system.debug('jsonBody++++===='+jsonBody);
      List<sObject> sobjlist= SYS_Transformer.getSObjectsToUpsert(new List<String>{jsonBody},resource);
      system.debug('sobjlist+++++=='+sobjlist);
      
        return sobjlist;
    
    }
    public override SYS_IntegrationLog__c generateLogForChildRecords(String parentLogId,String resource,String recordsJson,String integrationSetting) {
          
        List<SYS_IntegrationLog__c> parentLog = 
        Database.query('SELECT '+SYS_Helper.getAllFieldsFor('SYS_IntegrationLog__c')+', Parent__r.WhatId__c, Parent__r.SYS_Operation_Type__c,Parent__r.Resource__c FROM SYS_IntegrationLog__c WHERE Id in (' + '\'' + parentLogId + '\')');
          system.debug('parentLog++++=='+parentLog);
        SYS_IntegrationLog__c log = SYS_Helper.getLogsToInsert(recordsJson);
         //storing parent resource invariable
          string  parentResource   = parentLog[0].Resource__c;
         
        log.ObjectSettingId__c = parentLog[0].ObjectSettingId__c;
        system.debug('log.ObjectSettingId__c'+log.ObjectSettingId__c);
        system.debug('log.ObjectSettingId__c'+ parentLog[0].Resource__c);
        String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
        if(algo!=NULL && algo!='')
            log.Request_Digest__c = generateHash(recordsJson,algo);

        SYS_debug.log('MS SYS_DataCache.log in generate child log:'+SYS_DataCache.log.Id);
        log.Parent__c = parentLogId;
        
        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = 'UPSERT';

        /**
         * If Flat key to identify resource for child records is defined on Integration Setting, consider that
         * Else take the root key as Resource that is passed on while processing parent record
         */
        String flat_key_for_child = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Flat_Key_for_Resource_Child__c;
        if(flat_key_for_child != NULL && flat_key_for_child!='')
            log.Flat_Key_for_Resource__c = flat_key_for_child;
        else{
           
            log.Resource__c = resourceChildMap.get(parentResource);
            system.debug('Resource__c'+resourceChildMap.get(parentResource));
            log.Flat_Key_for_Resource__c = '';
        
        }
        log.Integration_Setting__c = integrationSetting;
        log.Status__c = 'NEW';
        /**
         * Applies when the child records require parenting after creation
         */
        log.Requires_process_on_complete__c = true;
        log.On_Complete_Handler__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c;
        /** */

        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c;

        return log;
    }
  
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