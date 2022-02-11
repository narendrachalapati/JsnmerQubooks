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
        //todo
        logResp.Custom_Field_Value__c = 'false';
       // log.Requires_process_on_complete__c = true;

        return log;
    }
   //we overriding this method removing the root key because to maintain the custom metadata same for the outbound and inbound
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
    //when we removed the root key it not returing the restresorce that path so it not identifying the sobject so thats why 
    //we overriden the get resource method for identifying the ecaxt resource path 

  /**
     * This hook is called from doInbound to identify resource from incoming JSON
     * Arguement: SYS Log record and JSON Body
     * Default is return the root if it exists or the value of falt key mentioned in Flat_Key_for_Resource__c field on log record
     * Override if custom implementation is required for identifying the resoruce for inbound request
     */
    public override String getResourceFromJSON(SYS_IntegrationLog__c log,String jsonBody){
        SYS_IntegrationLog__c logResp = SYS_DataCache.log;
        jsonBody =  logResp.data0__c != null ? logResp.data0__c : '' +
        logResp.data1__c != null ? logResp.data1__c : '' +
        logResp.data2__c != null ? logResp.data2__c : '' +
        logResp.data3__c != null ? logResp.data3__c : '' +
        logResp.data4__c != null ? logResp.data4__c : '' +
        logResp.data5__c != null ? logResp.data5__c : '' +
        logResp.data6__c != null ? logResp.data6__c : '' +
        logResp.data7__c != null ? logResp.data7__c : '' +
        logResp.data8__c != null ? logResp.data8__c : '' +
        logResp.data9__c != null ? logResp.data9__c : '' ;
        String resource = '';
        if(log.Resource__c!=NULL){
            return log.Resource__c;
        }

        if(log.Flat_Key_for_Resource__c == NULL || log.Flat_Key_for_Resource__c == ''){
            //Root element identifies Resource
            Object responseType = JSON.deserializeUntyped(jsonBody);
            if(responseType instanceof Map<String,Object>){
                resource = new List<String>(((Map<String, Object>)responseType).keySet())[0];
            }
        }
        else{
            //Key mentioned in Flat_Key_for_Resource__c identifies Resource
            Map<String, Object> flatKeyMap = getFlatKeys(jsonBody);
            System.debug('-- MS flatKeyMap in getResourceFromJSON:'+flatKeyMap);
            resource = (String)flatKeyMap.get(log.Flat_Key_for_Resource__c);
        }

        return resource;
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