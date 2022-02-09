public class SYS_Constants {
	public static Integer TEXT_AREA_MAX_SIZE { 
        get {
            return 131072;
        }
    }
    
    public static Integer MAX_DATA_FIELDS {
        get{
            return 10;
        }
    }
<<<<<<< HEAD
    /*
    public static FINAL String OUTBOUND = 'OUTBOUND';
    public static FINAL String INBOUND = 'OUTBOUND';
    public static FINAL String SYSMERGE = 'MERGE';*/
        
    public static FINAL String RESOURCE = 'entityName/entityId?minorversion=59';
    public static String INT_TYPE = 'Quickbooks'; //Quickbooks  Middleware_hl7 IMS_SIU JIRA
    public static String OBJ_TYPE = 'AccountQB';
    public static String PRICEBOOK = 'Standard Price Book'; // Standard , Standard Price Book
    public static FINAL Map<String, String>  metaDataMap = new Map<String, String>{'Account' => 'Customer', 'SBQQ__Quote__c' => 'Invoice', 'Product2' => 'Item', 'pymt__PaymentX__c' => 'Payment', 'Order'=> 'Invoice2','Custom_Parent__c'=>'Custom_Parent__c'}; 
    public static FINAL Map<String, String> mapEntityPath = new Map<String, String>{'Customer' => 'customer?minorversion=55', 'Invoice' => 'invoice1','Invoice2' => 'invoice2' , 'Item' => 'item', 'Payment'=>'payment','Custom_Parent__c'=>'Custom_Parent__c'};
    public static Map<String, String> entityNameToObjapiName = new Map<String, String>{'Customer' => 'Account', 'Invoice' => 'SBQQ__Quote__c', 'Item' => 'Product2', 'Payment'=>'pymt__PaymentX__c','Custom_Parent__c'=>'Custom_Parent__c'}; 
    public static Map<String, String> parentChild = new Map<String, String>{'SBQQ__Quote__c' => 'SBQQ__QuoteLine__c'}; 
    public static string productName = 'GENERIC PRODUCT'; 
=======
>>>>>>> 79e2bd10cca80a1918338f3482359441195f051b
    
    
}