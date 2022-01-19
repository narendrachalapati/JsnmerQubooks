public class override_SYS_ApplicationService extends SYS_ApplicationService {
    public override_SYS_ApplicationService() {

    }

    public override HttpResponse doOutbound(SYS_IntegrationLog__c log){
        System.debug('\n In override_SYS_ApplicationService');
        return super.doOutbound(log);
    }

}
