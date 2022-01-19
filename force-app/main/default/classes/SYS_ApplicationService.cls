global virtual class SYS_ApplicationService {
    global SYS_ApplicationService() {

    }

    /* ------------------------------------------------------------------------ */ 

    global virtual void doInbound(List<SYS_IntegrationLog__c> newList) {
        String jsonBody = '';
        for(SYS_IntegrationLog__c log : newList) {
            jsonBody = log.data0__c != null ? log.data0__c : '' +
                            log.data1__c != null ? log.data1__c : '' +
                            log.data2__c != null ? log.data2__c : '' +
                            log.data3__c != null ? log.data3__c : '' +
                            log.data4__c != null ? log.data4__c : '' +
                            log.data5__c != null ? log.data5__c : '' +
                            log.data6__c != null ? log.data6__c : '' +
                            log.data7__c != null ? log.data7__c : '' +
                            log.data8__c != null ? log.data8__c : '' +
                            log.data9__c != null ? log.data9__c : '' ; 
            
                //--M SYS_integrationLogHandler.transformGETResponseAndUpsertQB( jsonBody , log.WhatId__c); 
        }
    }
    /* ------------------------------------------------------------------------ */

    /* ------------------------------------------------------------------------ */

    global virtual HttpResponse doOutbound(SYS_IntegrationLog__c log){

        Http http = new Http();
        HttpRequest req = new HttpRequest();

        IntegrationSetting__mdt integrationSetting = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE);
        String baseEndpoint = integrationSetting.BaseAPIEndPoint__c;

        List<HttpHeaders__mdt> httpHeader = SYS_DataCache.headerSetting;
        req.setMethod(integrationSetting.UpdateMethod__c);
        for(HttpHeaders__mdt head:httpHeader){
            SYS_debug.log('header is = '+head.MasterLabel + ''+head.Value__c);
            req.setHeader(String.valueOf(head.MasterLabel), String.valueOf(head.Value__c));
                
        } 
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
        
        String resourceUrl = integrationSetting.BaseAPIEndPoint__c+SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ResourcePath__c;
        req.setEndpoint(resourceUrl);
        req.setBody(body);
        system.debug('body'+body);
         
        HttpResponse response = http.send(req);
        return response;
        
    }
    /* ------------------------------------------------------------------------ */

    global virtual SYS_IntegrationLog__c logOutboundResult(HttpResponse resp,SYS_IntegrationLog__c log){

        SYS_IntegrationLog__c logResp = getLogsToInsert(resp.getBody());
        if(resp.getStatusCode() != 201){
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
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
            }
            
        }
        else{
            
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
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_Operation_Type__c = 'RESPONSE';
            }
        }

        return logResp;
    }

    /* ------------------------------------------------------------------------ */

    global virtual String sanitizeJSONForOutbound(String jsonRecord){

        String finalJSON = jsonRecord.replace('\n',' ');
        return finalJSON;
    }

    /* ------------------------------------------------------------------------ */
    //[DEPRECATED]
    public virtual void router(List<SYS_IntegrationLog__c> newLogList){
        List<Id> newLogsFirst = new List<Id>();
        List<Id> newLogsSecond = new List<Id>();
        List<Id> newInboundFirst = new List<Id>(); 
        List<Id> newInboundSecond = new List<Id>();
        List<SYS_IntegrationLog__c> newInboundResponse = new List<SYS_IntegrationLog__c>(); 
        List<SYS_IntegrationLog__c> updateToken = new List<SYS_IntegrationLog__c>(); 

        SYS_debug.log('map=='+JSON.serialize(SYS_DataCache.objectSettingMap));
        Map<String, List<Id>> mapStringToId = new Map<String, List<Id>>();
        Integer count = 0;
        for(SYS_IntegrationLog__c log:newLogList){
            //TODO - Add constant values in class
            SYS_debug.log('inside forloop' + log.Type__c +' -- '+log.SYS_Operation_Type__c+' -- '+ log.SYS_Operation_Type__c);
            if(log.Type__c == 'OUTBOUND'){
                if(count > 99){
                    newLogsSecond.add(log.id);
                }
                else{
                    newLogsFirst.add(log.id);
                }   
            } else if(log.Type__c == 'INBOUND' && log.SYS_Operation_Type__c == 'CDC') {
                if(count > 99){
                    newInboundSecond.add(log.id);
                }
                else{
                    newInboundFirst.add(log.id); 
                } 
            } else if(log.Type__c == 'INBOUND' && log.SYS_Operation_Type__c == 'RESPONSE' && log.Status__c == 'NEW'  ) {
                SYS_debug.log('inside response@@');
                newInboundResponse.add(log);
            } 
            count += 1;
        }
        
        SYS_debug.log('response got size=='+ newInboundResponse.size() );
       
        if(newInboundResponse.size() > 0) {
            processInboundResponse(newInboundResponse);
        }
        
        if(newLogList.size() <= 100) {
             SYS_debug.log('inside first=='); 
            if(newLogsFirst.size() > 0)
               System.enqueueJob(new SYS_IntegrationLogOutboundQueueable(newLogsFirst)); 
        
        } else if(newLogList.size() > 100){
            if(newLogsFirst.size() > 0)
                System.enqueueJob(new SYS_IntegrationLogOutboundQueueable(newLogsFirst));
            if(newLogsSecond.size() > 0)
                System.enqueueJob(new SYS_IntegrationLogOutboundQueueable(newLogsSecond));
  
         }
    }
    
    
    /************************** C O N C R E T E    M E T H O D S    S T A R T **************************/


    /* ------------------------------------------------------------------------ */
    public SYS_IntegrationLog__c getLogsToInsert(String requestBody) {
        SYS_IntegrationLog__c integrationLog = new SYS_IntegrationLog__c();
        List<String> data = getJSONChunckedValues(requestBody);
        integer i = 0;
        for(String json:data){
            integrationLog.put('data'+i+'__c',json);
            i++;
        }
        return integrationLog;
    }


    /* ------------------------------------------------------------------------ */

    public List<String> getJSONChunckedValues(String body){
        List<String> data = new List<String>{'','','','','','','','','',''};
        
        if (body.length() <= SYS_Constants.TEXT_AREA_MAX_SIZE){
			data[0] = body;
        } else {
            SYS_debug.log('json needs chunking');
            Integer di = 0;
            String jsonSubStrng;
            Integer endIndex = SYS_Constants.TEXT_AREA_MAX_SIZE;
            String outboundJSON = body;
            do {
                jsonSubStrng = outboundJSON.substring(0,endIndex);
                outboundJSON = outboundJSON.substring(endIndex);
                SYS_debug.log('substr= '+outboundJSON+' index='+endIndex+' '+jsonSubStrng);
                endIndex = (outboundJSON.length() < SYS_Constants.TEXT_AREA_MAX_SIZE) ? outboundJSON.length() : SYS_Constants.TEXT_AREA_MAX_SIZE;
                data[di] = jsonSubStrng;
                di++;
                if(di == SYS_Constants.MAX_DATA_FIELDS - 1 && body.length() > SYS_Constants.TEXT_AREA_MAX_SIZE){
                    SYS_debug.log('JSON too large. Truncated');
                    break;
                }
            } while (outboundJSON.length() > 0);
        }
        return data;
    }
    /* ------------------------------------------------------------------------ */


    /************************** C O N C R E T E    M E T H O D S    E N D *****************************/

    
}
