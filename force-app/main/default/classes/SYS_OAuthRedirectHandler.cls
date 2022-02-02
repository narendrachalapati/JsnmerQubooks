@RestResource(urlMapping='/v1/callback/*')
global class SYS_OAuthRedirectHandler {
	@HttpGet
    global static void doGet(){
        
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.addHeader('Access-Control-Allow-Origin', '*');
        String code= RestContext.request.params.get('code');
        String state = RestContext.request.params.get('state');
        
        System.debug('Code:'+code);
        
        List<SYS_OAuthConfig__c> configs = [SELECT 
                                                Id, 
                                                Name, 
                                                Access_Token__c, 
                                                Authorize_Endpoint__c, 
                                                Client_Secret__c, 
                                                Grant_Type__c, 
                                                Redirect_URL__c, 
                                                Refresh_Token__c, 
                                                Token_Endpoint__c, 
                                                Client_Id__c, 
                                                Additional_URL_Parameters__c 
                                            FROM SYS_OAuthConfig__c 
                                           	WHERE Id =:state];
        
        // Instantiate a new http object
        Http h = new Http();
    
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://drchrono.com/o/token/');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        String clientId = 'FoXln3srOE5nZHkaCOlSO06VXo8eiyD4O6aSo06T';
        String clientSecret = '7BmiMhPsPz8zmk0WieBVmbpYJM5YDbaDnk8WhpvidI0td4XIK6gNupGbRt5W5eQLEeATzTEPGQl1ZH0PvfR5vZjQAc4VZjufOC2EdDdfuICqH34tYznmkqChIJCiPPb4';
        String redirect_uri = 'https://municor-base-org-developer-edition.na163.force.com/services/apexrest/v1/callback';
        String payload = 'client_id='+EncodingUtil.urlEncode(clientId,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(clientSecret,'UTF-8')+'&code='+EncodingUtil.urlEncode(code,'UTF-8')+'&state='+EncodingUtil.urlEncode('abc123','UTF-8')+'&grant_type=authorization_code'+'&redirect_uri='+EncodingUtil.urlEncode(redirect_uri ,'UTF-8');
        
        req.setBody(payload);
        System.debug('----- Token Request Body:'+req.getBody());
        
    
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        
        //String jsonstr = '{"data":{"access_token": "L2Z_oY4fayEhG2OV6LD306H5KMNmEH1q3KY9N3nAwW3xK_3kcupcsFl1djHKVUjwe9ytuADHPHMwJ0w0SsOQUfLfHbo4DjmJFNhptZpMs6FEWOzVoAq--xp_sYeMCXa_"}}';
        JSONParser parser = JSON.createParser(res.getBody());
        String access_token=''; 
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'access_token')) {
                
                parser.nextToken();
                access_token= parser.getText();
            }
        }
        
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint('https://drchrono.com/api/patients');
        req2.setMethod('GET');
        req2.setHeader('Content-Type', 'application/json');
        req2.setHeader('Authorization', 'Bearer '+access_token);
        HttpResponse res2 = h.send(req2);
        
        //--RestContext.response.addHeader('Content-type', 'text/html; charset=utf-8');
        RestContext.response.responseBody = Blob.valueOf('{"data":'+res2.getBody()+'}');
        //--RestContext.response.responseBody = Blob.valueOf('<html><head></head><body><h1>Hello World!</h1><hr/><p>WE DID IT!!</p></body></html>');
        
        /*
        PageReference newFloodOnlyUrl = new PageReference('https://healthcare-demo.crm8.dynamics.com//WebResources/new_EpicHTML');
        newFloodOnlyUrl.setRedirect(true);
        return newFloodOnlyUrl ;
        */
        
        
    }
}