public with sharing class SYS_QueueableForInboundChild implements Queueable {
    public List<String> childRecList;
    public String key;
    
    public SYS_QueueableForInboundChild(List<String> childRecList,String key,String objName){
        this.childRecList = childRecList;
        this.key = key;
    }
    
    public void execute(QueueableContext context){
        //Set isChild to true so that the primaryobject could be set to root of related records instead of parent
        //SYS_Transformer.isChild = true;
        SYS_IntegrationLog__c log = SYS_ApplicationService.getLogsToInsert(childRecList[0]);
        
        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = 'UPSERT';
        log.Flat_Key_for_Resource__c = '';
        log.SYS_IntegrationSettings__c = 'SFsource';
        log.Status__c = 'NEW';
        log.External_Id_Field_API_Name__c = 'SYS_Child_Key__c';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = 'SYS_ApplicationService';

        insert log;

        //new SYS_ApplicationService().doInbound(log);
    }
}


