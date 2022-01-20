global virtual class SYS_ApplicationService {
    global SYS_ApplicationService() {

    }

    
    /* ------------------------------------------------------------------------ */ 

    global virtual Boolean doInbound(SYS_IntegrationLog__c log) {
        String jsonBody = '';
        
        jsonBody =  log.data0__c != null ? log.data0__c : '' +
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
       

        return null;
    }
    /* ------------------------------------------------------------------------ */

    global virtual HttpRequest buildOutboundHttpRequest(){
        HttpRequest req = new HttpRequest();
        IntegrationSetting__mdt integrationSetting = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE);
        String baseEndpoint = integrationSetting.BaseAPIEndPoint__c;

        List<HttpHeaders__mdt> httpHeader = SYS_DataCache.headerSetting;
        req.setMethod(integrationSetting.UpdateMethod__c);
        for(HttpHeaders__mdt head:httpHeader){
            SYS_debug.log('header is = '+head.MasterLabel + ''+head.Value__c);
            req.setHeader(String.valueOf(head.MasterLabel), String.valueOf(head.Value__c));
                
        }
        String resourceUrl = integrationSetting.BaseAPIEndPoint__c+SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ResourcePath__c;
        req.setEndpoint(resourceUrl);
        return req;
    }

    /* ------------------------------------------------------------------------ */

    global virtual HttpResponse doOutbound(SYS_IntegrationLog__c log){

        Http http = new Http();
        HttpRequest req = buildOutboundHttpRequest();
        

        
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
        
        
        req.setBody(body);
        system.debug('body'+body);
         
        HttpResponse response = http.send(req);
        return response;
        
    }

    /* ------------------------------------------------------------------------ */

    global virtual SYS_IntegrationLog__c generatelogForInboundResult(Boolean result,SYS_IntegrationLog__c log){

        SYS_IntegrationLog__c logResp = new SYS_IntegrationLog__c();

        if(!result){
            
            String errorMessage = 'The following error has occurred.';
            /*
            String errorMessage = 'The following error has occurred.';
            for(Database.Error err : result.getErrors()) {
                errorMessage += err.getStatusCode() + ': ' + err.getMessage();
                SYS_debug.log('Fields affected are: ' + err.getFields());
            }
            errorMessage += 'Fields affected are: ' + err.getFields();
            */

            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Status__c.isCreateable()) {
                logResp.Status__c = 'FAIL';
            }

            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Message__c.isCreateable()) {
                logResp.Message__c = errorMessage;
            }
            
            logResp.Id = log.Id;
            
        }
        else{
            
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Status__c.isCreateable()) {
                logResp.Status__c = 'DONE';
            }

            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Message__c.isCreateable()) {
                logResp.Message__c = 'Record created successfully';
            }
            
            logResp.Id = log.Id;
        }

        return logResp;
    }

    /* ------------------------------------------------------------------------ */

    global virtual SYS_IntegrationLog__c generatelogForOutboundResult(HttpResponse resp,SYS_IntegrationLog__c log){

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

    public static void doDML(List<sObject> records,String dmlType,Schema.SObjectField additionalSetting) {
        
        switch on dmlType.toUpperCase() {
            when 'INSERT'{
                Database.SaveResult[] results = Database.insert(records, false);
                for(Database.SaveResult result : results){
                    if(result.isSuccess()){
                        // Email etc.
                    } else {
                        for(Database.Error err : result.getErrors()) {
                            SYS_debug.log('The following error has occurred.');                    
                            SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
                            SYS_debug.log('Fields affected are: ' + err.getFields());
                        }
                    }
                }
            }
            when 'UPSERT'{  
                Database.UpsertResult[] results = Database.upsert(records,additionalSetting, false);
                for(Database.UpsertResult result : results){
                    if(result.isSuccess()){
                        // Email etc.
                    } else {
                        for(Database.Error err : result.getErrors()) {
                            SYS_debug.log('The following error has occurred.');                    
                            SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
                            SYS_debug.log('Fields affected are: ' + err.getFields());
                        }
                    }
                }
            }
            when 'UPDATE'{
                Database.SaveResult[] results = Database.update(records, false);
                for(Database.SaveResult result : results){
                    if(result.isSuccess()){
                        // Email etc.
                    } else {
                        for(Database.Error err : result.getErrors()) {
                            SYS_debug.log('The following error has occurred.');                    
                            SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
                            SYS_debug.log('Fields affected are: ' + err.getFields());
                        }
                    }
                }
            }
            when 'DELETE'{
                Database.DeleteResult[] results = Database.delete(records, false);
                for(Database.DeleteResult result : results){
                    if(result.isSuccess()){
                        // Email etc.
                    } else {
                        for(Database.Error err : result.getErrors()) {
                            SYS_debug.log('The following error has occurred.');                    
                            SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
                            SYS_debug.log('Fields affected are: ' + err.getFields());
                        }
                    }
                } 
            }
            when else {
                // Invalid DML Type. Log Exception
            }
            
        }

    }
    /* ------------------------------------------------------------------------ */

    /************************** C O N C R E T E    M E T H O D S    E N D *****************************/

    
}
