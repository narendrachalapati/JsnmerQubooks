public class override_SYS_ApplicationService extends SYS_ApplicationService {
    public override_SYS_ApplicationService() {

    }

    public override HttpResponse doOutbound(SYS_IntegrationLog__c log){
        System.debug('\n In override_SYS_ApplicationService');
        return super.doOutbound(log);
    }

    public override HttpRequest buildOutboundHttpRequest(SYS_IntegrationLog__c log){
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
        List<Custom_Parent__c> rec = [SELECT SYS_Key__c FROM Custom_Parent__c WHERE Id = :log.WhatId__c LIMIT 1];
        req.setEndpoint(resourceUrl+'Id'+'/'+rec[0].SYS_Key__c);
        return req;
    }

}
