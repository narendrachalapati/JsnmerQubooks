trigger SYS_IntegrationLogTrigger on SYS_IntegrationLog__c (after insert,after update) {

    SYS_IntegrationLogTriggerHandler.handleTrigger(Trigger.New, Trigger.operationType);

}