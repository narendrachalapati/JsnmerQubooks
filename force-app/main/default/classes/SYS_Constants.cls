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
    
    public static Map<String, String> escCharMap = new Map<String, String>();
    public static String QB_WEBSERVICE = '/quickbooks/v1/*';
    public static String RESOURCE_PATH = 'blank';
    public static String ROOT_KEY = 'ADT';

    public static String incorrect_object_error = 'Oops!! Incorrect object value.';
    public static String record_doesnot_exist_error = 'Record doesnot existes in Salesforce.';
    public static String some_error_occured = 'Oops!! Some error occured.';
    public static String record_deleted_msg = 'Record has been deleted successfully!';
    
}