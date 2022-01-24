@RestResource(urlMapping = '/municorn/v1/*')
global class SYS_Webservice{

    
    @HttpPost
    global static void postRequest(){

        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.getExtension).newInstance();
        if(appService.doWebhookSignatureCheck()){
            appService.doPost();
        }  
        else {
            appService.setErrorHttpResponse();
        }
    }

    
    @HttpPut
    global static void putRequest(){
        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.getExtension).newInstance();
        if(appService.doWebhookSignatureCheck()){
            appService.doPut();
        }  
        else {
            appService.setErrorHttpResponse();
        }
        
    }

    
    @HttpGet
    global static void getRequest(){

        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.getExtension).newInstance();
        if(appService.doWebhookSignatureCheck()){
            appService.doGet();
        }  
        else {
            appService.setErrorHttpResponse();
        }
    }
    
    
    @HttpDelete
    global static void deleteRequest(){
        
        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.getExtension).newInstance();
        if(appService.doWebhookSignatureCheck()){
            appService.doDelete();
        }  
        else {
            appService.setErrorHttpResponse();
        }
        
    }

    @HttpPatch
    global static void patchRequest(){
        
        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.getExtension).newInstance();
        if(appService.doWebhookSignatureCheck()){
            appService.doPatch();
        }  
        else {
            appService.setErrorHttpResponse();
        }
        
    }
    
}