public with sharing class SYS_JWTAuth_ApplicationService extends SYS_ApplicationService {

    public String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }

    public override String preprocessJSONForOutbound(SYS_IntegrationLog__c log, String jsonBody){
        System.debug('Hello Howdy:'+jsonBody);
        List<SYS_OAuthConfig__c> authConfigList = 
            Database.query('SELECT '+SYS_Helper.getAllFieldsFor('SYS_OAuthConfig__c') +' FROM SYS_OAuthConfig__c WHERE Id = \'' + log.WhatId__c + '\'');

        String jwt = '';
    
        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', authConfigList[0].alog__c);
        header.writeStringField('typ', 'JWT');
        header.writeEndObject();
        
        String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));

        jwt = encodedHeader + '.' + base64URLencode(Blob.valueOf(jsonBody));
        Blob key = EncodingUtil.base64Decode(authConfigList[0].Private_Key__c);
        Blob signature = Crypto.sign('rsa-sha256', Blob.valueOf(jwt), key);
        jwt += '.' + base64URLencode(signature); 

        jsonBody = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion='+jwt;

        log.data1__c = jsonBody;
        //upsert log;

        return jsonBody;
    }
    
    @AuraEnabled
    public static void invokeTokenFlow(Id oauthConfigId){
        try {
            List<SYS_OAuthConfig__c> authConfigList = 
            Database.query('SELECT '+SYS_Helper.getAllFieldsFor('SYS_OAuthConfig__c') +' FROM SYS_OAuthConfig__c WHERE Id = \'' + oauthConfigId + '\'');


            SYS_DataCache.INT_TYPE = 'SYS_Auth_Integration_Setting';
            SYS_DataCache.OBJ_TYPE = 'SYS_Auth_JWT_Object_Setting';
            SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ApexHandler__c).newInstance();
            Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(authConfigList);
            
            List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();
            
            if(jsonListForOutbound.values().size() > 0){
                for(Id jsonRecordId:jsonListForOutbound.keyset()){ 
                    String finalJsonForOutbound;

                    finalJsonForOutbound = appService.sanitizeJSONForOutbound(jsonListForOutbound.get(jsonRecordId));

                    SYS_IntegrationLog__c  newSysLog = SYS_Helper.getLogsToInsert(finalJsonForOutbound);
                    newSysLog.Status__c = 'DONE';
                    newSysLog.Type__c = 'OUTBOUND';
                    newSysLog.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
                    newSysLog.SYS_Operation_Type__c = 'INSERT';
                    newSysLog.whatid__c = jsonRecordId;
                    newSysLog.How_to_process__c = 'use_object_setting';
                    newSysLog.ObjectSettingId__c = SYS_DataCache.OBJ_TYPE;

                    insertSysLog.add(newSysLog);
                }

                if(insertSysLog.size()>0 && SYS_DataCache.enableCheck.get(SYS_DataCache.INT_TYPE.toUpperCase())){
                    new SYS_IntegrationLogOutboundImmediate(insertSysLog).execute();
                    insert insertSysLog;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*

      JWT jwt = new JWT(SYS_DataCache.JWT_ALGO);

        jwt.validFor = 600;
        jwt.iss = SYS_DataCache.JWT_ISS;
        jwt.sub = SYS_DataCache.JWT_SUB;
        jwt.aud = SYS_DataCache.JWT_AUD;
        Map<String,String> claims = new  Map<String,String>();
        claims.put('target_audience', SYS_DataCache.JWT_TARGET_AUD);
        jwt.claims = claims;
        String access_token = JWTBearerFlow.getAccessToken(SYS_DataCache.JWT_TOKEN_URL , jwt);
		

    public class JWTBearerFlow { 

        public static String getAccessToken(String tokenEndpoint, JWT jwt) {
        
            String access_token = null;
            String body = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + jwt.issue();
            HttpRequest req = new HttpRequest();                            
            req.setMethod('POST');
            req.setEndpoint(tokenEndpoint);
            req.setHeader('Content-type', 'application/x-www-form-urlencoded');
            req.setBody(body);
            Http http = new Http();               
            HTTPResponse res = http.send(req);
            
            if ( res.getStatusCode() == 200 ) {
                System.debug(res.getBody());
                System.JSONParser parser = System.JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id_token')) {
                        parser.nextToken();
                        access_token = parser.getText();
                        break;
                    }
                }
            }
            return access_token;
            
        }

    }
    */
}
