public class SYS_RelationshipMapper { 
	//Runs in before trigger context to get the parent values and fix lookups/MD
    public List<sObject> mapRelationships() {
        return mapRelationships(Trigger.new);
    }
    
    public static List<sObject> mapRelationships(List<sObject> objs) {
        if(objs == null || objs.size() == 0) {
            return null;
        }

        SObjectType objectType = objs[0].getSObjectType();
        SYS_debug.log('type=='+objs[0].getSObjectType());
        //now fetch the object and field settings
        Map<Id, String> jsonMap = new Map<Id, String>();
        List<RelationshipSetting__mdt> mappings = [Select Id, ChildObjectNew__c, ChildFieldNew__c, ChildRelationshipFieldNew__c, ChildField__c, ChildField__r.QualifiedApiName , 
                                                    ParentObject__c, ParentObject__r.QualifiedApiName , ChildObject__r.QualifiedApiName, ChildRelationshipField__r.QualifiedApiName
                                                    from RelationshipSetting__mdt where ChildObjectNew__c = :objectType.getDescribe().getName()];
        
            mappings = [Select Id, ChildObjectNew__c, ChildFieldNew__c, ChildRelationshipFieldNew__c, ChildField__c, ChildField__r.QualifiedApiName , 
                                                    ParentObject__c, ParentObject__r.QualifiedApiName , ChildObject__r.QualifiedApiName, ChildRelationshipField__r.QualifiedApiName
                                                    from RelationshipSetting__mdt where ChildObjectNew__c = : objectType.getDescribe().getName()]; 
        
        Map<String, String> parentMap = new Map<String, String>();
        Map<String, String> parentFieldMap = new Map<String, String>();
        Map<String, Map<String, String>> parentFieldKeyIdMap = new Map<String, Map<String, String>>();
        for(RelationshipSetting__mdt mapping : mappings) {
            parentMap.put(mapping.ParentObject__r.QualifiedApiName, mapping.ChildFieldNew__c); 
            parentFieldMap.put(mapping.ParentObject__r.QualifiedApiName, mapping.ChildRelationshipFieldNew__c);
            parentFieldKeyIdMap.put(mapping.ParentObject__r.QualifiedApiName, new Map<String, String>());
        }
        SYS_debug.log('mapping=='+mappings);
        SYS_debug.log('mapping parentMap=='+parentMap);
        SYS_debug.log('mapping parentFieldMap=='+parentFieldMap);
        SYS_debug.log('mapping parentFieldKeyIdMap=='+parentFieldKeyIdMap);

        for(sObject obj : objs) {
            for(String parentObject : parentFieldKeyIdMap.keySet()) {
                parentFieldKeyIdMap.get(parentObject).put((String)obj.get(parentMap.get(parentObject)), null);
            }
        }
        
        for(String parentObject : parentFieldKeyIdMap.keySet()) {
            //TODO - external If field for IMS id not SYS key...
            List<String> key = new List<String>(parentFieldKeyIdMap.get(parentObject).keySet());
            SYS_debug.log('Key=='+key);
            String query = 'Select Id, Quickbooks_Id__c from ' + parentObject + ' where Quickbooks_Id__c in : key';/* + parentFieldKeyIdMap.get(parentObject).keySet().toString().replace('{','(').replace('}',')');*/
            SYS_debug.log('Query=='+ query);
            List<sObject> parentObjs = Database.query(query); 
            for(sObject obj : parentObjs) {
                    String extId = String.valueof(obj.get('Quickbooks_Id__c'));
                    parentFieldKeyIdMap.get(parentObject).put(extId, (String)obj.get('Id'));
            }
        }
        for(String parentObject : parentFieldKeyIdMap.keySet()) {
        	for(sObject obj : objs) {
            	obj.put(parentFieldMap.get(parentObject), parentFieldKeyIdMap.get((String)parentObject).get((String)obj.get((String)parentMap.get(parentObject))));
                SYS_debug.log('obj val--'+parentFieldMap.get(parentObject) + ' ** '+ parentFieldKeyIdMap.get((String)parentObject).get((String)obj.get((String)parentMap.get(parentObject))));
            }
        }
        return objs;
    }

    
    
}