public class SYS_HttpBuilder {

   /* public static HttpRequest getHttpRequest() {
        HttpRequest req = new HttpRequest();
        List<IntegrationSetting__mdt> integrationSetting = SYS_DataCache.integrationSetting;
        String baseEndpoint = integrationSetting[0].BaseAPIEndPoint__c;
        if(integrationSetting.size() != 0){
            List<HttpHeaders__mdt> httpHeader = [SELECT Id, MasterLabel, Label, IntegrationType__c, Value__c 
                                                 FROM HttpHeaders__mdt 
                                                 WHERE IntegrationType__c =: integrationSetting[0].id];
            req.setMethod(integrationSetting[0].UpdateMethod__c);
            for(HttpHeaders__mdt head:httpHeader){
                SYS_debug.log('header is = '+head);
                req.setHeader(String.valueOf(head.MasterLabel), String.valueOf(head.Value__c));
            }
        }
        return req;
    }*/

    public static HttpRequest getHttpRequestGET() {
        HttpRequest req = new HttpRequest();
        List<IntegrationSetting__mdt> integrationSetting = SYS_DataCache.integrationSetting;
        String baseEndpoint = integrationSetting[0].BaseAPIEndPoint__c;
        if(integrationSetting.size() != 0){
            List<HttpHeaders__mdt> httpHeader = [SELECT Id, MasterLabel, Label, IntegrationType__c, Value__c 
                                                 FROM HttpHeaders__mdt 
                                                 WHERE IntegrationType__c =: integrationSetting[0].id];
            req.setMethod('GET');
            for(HttpHeaders__mdt head:httpHeader){
                SYS_debug.log('header is = '+head);
                req.setHeader(String.valueOf(head.MasterLabel), String.valueOf(head.Value__c));
            }
        }
        return req;
    }

    public static String getResourceUrlFromObjectApi(String objApi){
        String resourceUrl = SYS_DataCache.integrationSetting[0].BaseAPIEndPoint__c;
        if(objApi != null || objApi != ''){
            List<ObjectSetting__mdt> objSetting = [SELECT Id, ResourcePath__c, masterlabel, ObjectApiName__c
                                                   FROM ObjectSetting__mdt WHERE ObjectApiName__c = : objApi 
                                                   and IntegrationType__r.DeveloperName = : SYS_DataCache.integrationSetting[0].developername];
            SYS_debug.log('resource url='+objSetting[0].ResourcePath__c);
            if(objSetting.size() != 0){
                resourceUrl += objSetting[0].ResourcePath__c;
            }
        }
        SYS_debug.log('resource url='+resourceUrl);
        return resourceUrl;
    }

    public static String getResourceReadUrl(String entityName, String entityId) {
        String resourceUrl = SYS_DataCache.integrationSetting[0].BaseAPIEndPoint__c;
        if(entityName != null || entityName != '') {
            String url = SYS_Constants.RESOURCE.replace('entityName' , entityName.toLowerCase()).replace('entityId' , entityId);
            resourceUrl += url;
        }
        SYS_debug.log('resource url---'+resourceUrl);
        return resourceUrl;
    }
}