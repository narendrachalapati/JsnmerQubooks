@RestResource(urlMapping = '/municorn/v1/*')
global class SYS_Webservice{

    @HttpPost
    global static void doPost(){

        RestRequest req = RestContext.request;
        String extension = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('\n\nExtension:'+extension);
        if(extension == '' || extension == NULL){
            extension = 'SYS_ApplicationService';
        }

        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(extension).newInstance();
        SYS_IntegrationLog__c log = appService.generateLogForWebhookReq('POST');

        try{
            insert log;
            RestContext.response.responseBody = Blob.valueOf(RestContext.request.requestBody.toString());
        } catch ( Exception e ) {
            System.debug('\n****** WS Log:'+log);
        }
        
    }

    
    @httpPut
    global static void doPut(){

        RestRequest req = RestContext.request;
        String extension = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('\n\nExtension:'+extension);
        if(extension == '' || extension == NULL){
            extension = 'SYS_ApplicationService';
        }

        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(extension).newInstance();
        SYS_IntegrationLog__c log = appService.generateLogForWebhookReq('PUT');

        try{
            insert log;
            RestContext.response.responseBody = Blob.valueOf(RestContext.request.requestBody.toString());
        } catch ( Exception e ) {
            System.debug('\n****** WS Log:'+log);
        }
    }

    
    @httpGet
    global static void doGet(){
        RestRequest req = RestContext.request;
        String extension = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('\n\nExtension:'+extension);
        if(extension == '' || extension == NULL){
            extension = 'SYS_ApplicationService';
        }

        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(extension).newInstance();
        SYS_IntegrationLog__c log = appService.generateLogForWebhookReq('GET');

        try{
            insert log;
            RestContext.response.responseBody = Blob.valueOf(RestContext.request.requestBody.toString());
        } catch ( Exception e ) {
            System.debug('\n****** WS Log:'+log);
        }
    }
    
    
    @HttpDelete
    global static void doDelete(){
        RestRequest req = RestContext.request;
        String extension = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('\n\nExtension:'+extension);
        if(extension == '' || extension == NULL){
            extension = 'SYS_ApplicationService';
        }

        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(extension).newInstance();
        SYS_IntegrationLog__c log = appService.generateLogForWebhookReq('DELETE');

        try{
            insert log;
            RestContext.response.responseBody = Blob.valueOf(RestContext.request.requestBody.toString());
        } catch ( Exception e ) {
            System.debug('\n****** WS Log:'+log);
        }
        
    }

    @HttpPatch
    global static void doPatch(){
        RestRequest req = RestContext.request;
        String extension = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('\n\nExtension:'+extension);
        if(extension == '' || extension == NULL){
            extension = 'SYS_ApplicationService';
        }

        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(extension).newInstance();
        SYS_IntegrationLog__c log = appService.generateLogForWebhookReq('PATCH');

        try{
            insert log;
            RestContext.response.responseBody = Blob.valueOf(RestContext.request.requestBody.toString());
        } catch ( Exception e ) {
            System.debug('\n****** WS Log:'+log);
        }
        
    }
    
}