@RestResource(urlMapping = '/municorn/v1/*')
global class SYS_WebService{

    @HttpPost
    global static void doPost(){

        String requestBody = RestContext.request.requestBody.toString();
        System.debug('\n****** WS requestBody:'+requestBody);
        SYS_IntegrationLog__c log = SYS_ApplicationService.getLogsToInsert(requestBody);
        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = 'INSERT';
        log.Flat_Key_for_Resource__c = 'attributes.type';
        log.SYS_IntegrationSettings__c = 'SFsource';
        log.Status__c = 'NEW';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = 'SYS_ApplicationService';
        System.debug('\n****** WS requestBody:'+requestBody);

        try{
            insert log;
            RestContext.response.responseBody = Blob.valueOf(requestBody);
        } catch ( Exception e ) {
            System.debug('\n****** WS Log:'+log);
        }
        
    }

    
    @httpPut
    global static void doPut(){
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
        System.debug('\n****** WS requestBody:'+requestBody);

        try{
            insert log;
            RestContext.response.responseBody = Blob.valueOf(requestBody);
        } catch ( Exception e ) {
            System.debug('\n****** WS Log:'+log);
        }
    }

    /*
    @httpGet
    global static void doGet(){
        
    }
    
    @HttpDelete
    global static void doDelete(){
        
    }

    @HttpPatch
    global static void doPatch(){
        
    }
    */
    


}