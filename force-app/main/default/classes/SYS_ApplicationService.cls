global virtual class SYS_ApplicationService {
    global SYS_ApplicationService() {

    }

    /* ------------------------------------------------------------------------ */ 

    global virtual sObject processFieldMapping(FieldSetting__mdt mapping,sObject sObj,Object value, String sObjectApiName){

        SObjectType r = ((SObject)(Type.forName('Schema.'+sObjectApiName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
                
        String fieldType = d.fields
                            .getMap()
                            .get(mapping.FieldApiName__c)
                            .getDescribe()
                            .getType()+'';

        
        //TODO add other field types
        if(fieldType=='DATE'){
            try{
                sObj.put(mapping.FieldApiName__c, date.valueOf((String)value));
            }catch(Exception e){
                
            }
        } else if (fieldType == 'STRING') {
            sObj.put(mapping.FieldApiName__c, String.valueof(value));
        }
        else{
            sObj.put(mapping.FieldApiName__c, value);
        }

        System.debug('MS FINAL SOBJ:'+sObj);
        return sObj;
    }

    /* ------------------------------------------------------------------------ */ 

    global virtual SYS_IntegrationLog__c generateLogForWebhookReq() {
        String requestBody = RestContext.request.requestBody.toString();
        
        System.debug('\n****** WS requestBody:'+requestBody);
        SYS_IntegrationLog__c log = SYS_ApplicationService.getLogsToInsert(requestBody);
        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = 'INSERT';
        log.Flat_Key_for_Resource__c = 'attributes.type';
        log.SYS_IntegrationSettings__c = 'SFsource';
        log.Status__c = 'NEW';
        log.External_Id_Field_API_Name__c = 'SYS_Key__c';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = 'SYS_ApplicationService';

        return log;
    }
    

    /* ------------------------------------------------------------------------ */ 

    // For Outbound. Called from doInbound() in ApplicationService
    global virtual List<sObject> transformJsonToSObject(String jsonBody,String resource) {
        return SYS_Transformer.getSObjectsToUpsert(new List<String>{jsonBody},resource);
    }

    // For Outbound. Called from Invocable Handler
    global virtual Map<Id,String> transformSObjectToJson(List<sObject> newSObjectList) {
        return SYS_Transformer.getRequestJson(newSObjectList);
    }

    /* ------------------------------------------------------------------------ */ 

    global virtual String preprocessJSONForInbound(String jsonBody) {

        return jsonBody;
    }

    global virtual String preprocessJSONForOutbound(String jsonBody) {

        return jsonBody;
    }

    global virtual String getResourceFromJSON(SYS_IntegrationLog__c log,String jsonBody){

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

        jsonBody = preprocessJSONForInbound(jsonBody);
        List<sObject> sObjectsToDML = transformJsonToSObject(jsonBody, getResourceFromJSON(log,jsonBody));

        System.debug('\n\n ------------------------------- \n\n Application Service sObjects to DML:'+sObjectsToDML);

        String externalIdFieldAPIName = log.External_Id_Field_API_Name__c;
        Schema.SObjectField externalIdField = Schema.getGlobalDescribe().get(SYS_DataCache.sObjectApiName).getDescribe().fields.getMap().get(externalIdFieldAPIName);

        //TODO DML Based on log operation type
        Database.UpsertResult[] results = Database.upsert(sObjectsToDML,externalIdField, false);
               
        return results[0].isSuccess();
    }
    /* ------------------------------------------------------------------------ */

    global virtual HttpRequest buildOutboundHttpRequest(SYS_IntegrationLog__c log){
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
        HttpRequest req = buildOutboundHttpRequest(log);
        

        
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
        
        body = preprocessJSONForOutbound(body);
        req.setBody(body);
        System.debug('body:'+body);
         
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
        if(resp.getStatusCode() != 201 && resp.getStatusCode() != 200){
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
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.How_To_Process__c.isCreateable()) {
                logResp.How_To_Process__c = 'ignore_log';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
            }
            
        }
        else{

            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Status__c.isCreateable()) {
                logResp.Status__c = 'DONE';
            }
            
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
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.How_To_Process__c.isCreateable()) {
                logResp.How_To_Process__c = 'ignore_log';
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

    public static SYS_IntegrationLog__c getLogsToInsert(String requestBody) {
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

    public static List<String> getJSONChunckedValues(String body){
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

    public static void doDML(List<sObject> records,String dmlType,String additionalSetting) {
        
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
                Database.UpsertResult[] results;
                if(additionalSetting=='')
                    results = Database.upsert(records, false);
                //else
                    //results = Database.upsert(records, additionalSetting, false);
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
