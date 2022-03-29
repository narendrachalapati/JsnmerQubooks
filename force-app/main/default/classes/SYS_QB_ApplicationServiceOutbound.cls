public class SYS_QB_ApplicationServiceOutbound extends SYS_ApplicationService {
  public SYS_QB_ApplicationServiceOutbound() {

  }
  //We are removing the root of the json to make sure that inbound and outbound mappings are same
  public override List<sObject> transformJsonToSObject(String jsonBody,String resource,SYS_IntegrationLog__c log) {
      
      Object responseType = JSON.deserializeUntyped(jsonBody);
      Object JSONwithoutrootkey ;
      if(responseType instanceof Map<String,Object>){
          JSONwithoutrootkey = (((Map<String, Object>)responseType).values())[0];
          system.debug('JSONForUpsert+++'+JSONwithoutrootkey);
          //((Map<String, Object>)responseType).get(JSONForUpsert);
          jsonBody = JSON.serialize(JSONwithoutrootkey);
            system.debug('jsonBody++++===='+jsonBody);
      }
    system.debug('jsonBody++++======'+jsonBody);

      return SYS_Transformer.getSObjectsToUpsert(new List<String>{jsonBody},resource,(log.Type__c=='INBOUND'));
      
  }

Public override Map<Id,String> transformSObjectToJson(List<sObject> newSObjectList) {
  
 system.debug('SYS_DataCache.OBJ_TYPE++++++++===='+SYS_DataCache.OBJ_TYPE);
  Map<String, String> mapPaymentIds = new Map<String, String>();
  Map<String, Decimal> mapPayment = new Map<String, Decimal>();
  Map<String, Object> discountMap = new Map<String, Object>();
  Map<String, String> lineJson = new Map<String, String>();
  
 //  List<Id> pymtIds = new List<Id>();
 string Refundlinejson = '{"SalesItemLineDetail":{"ItemRef":{"value":"10"}},"Amount":##,"DetailType":"SalesItemLineDetail"}';
   String recId ;
   string objectApiName; 
  if(newSObjectList.size() > 0){
    recId = newSObjectList[0].Id;
  objectApiName = ((Id)recId).getSobjectType() + '';
 
  }
  System.debug('objectApiName'+objectApiName);
   Map<Id, String> newjson = SYS_Transformer.getRequestJson(newSObjectList);
   if(objectApiName == 'pymt__PaymentX__c') {
    for(pymt__PaymentX__c item : [SELECT Id, CPQ_Quote__r.Quickbooks_Id__c, Quote__r.Quickbooks_Id__c, pymt__Amount__c FROM pymt__PaymentX__c WHERE Id in :newjson.keyset()]) {
        mapPaymentIds.put(item.Id, item.CPQ_Quote__r.Quickbooks_Id__c != null ? item.CPQ_Quote__r.Quickbooks_Id__c : item.Quote__r.Quickbooks_Id__c); 
        mapPayment.put(item.Id, math.abs(item.pymt__Amount__c));
    }
}
if(newjson.values().size() > 0){
  for(Id iter:newjson.keyset()){ 
      String addrChange;
      
      addrChange = newjson.get(iter).replace('\n',' ');
      //TODO - QB specific change for bundle product  
      System.debug('json==='+addrChange);
      if(objectApiName == 'SBQQ__Quote__c' || objectApiName == 'Quote') {
          Decimal totalDiscount = ((Decimal)discountMap.get(iter));
          Object discount = new discountWrapper(totalDiscount);
          Object convert = JSON.deserializeUntyped(addrChange);
          if(convert instanceof Map<String, Object> && ((Map<String, Object>)convert).get('Line') != null) {
              Object line = ((Map<String, Object>)convert).get('Line');
              if(line instanceof List<Object>) {
                  List<Object> updatedLine = new List<Object>();
                  for(Object ln : ((List<Object>)line)) {
                      if(ln instanceof Map<String, Object> && ((Boolean)((Map<String, Object>)ln).get('Bundle')) == false ) {
                          ((Map<String, Object>)ln).remove('Bundle');
                      }
                      else if(ln instanceof Map<String, Object> && ((Boolean)((Map<String, Object>)ln).get('Bundle')) == true ) {
                          continue;
                      } 
                      updatedLine.add(ln);
                  }
                  //updatedLine.add(discount);
                  ((Map<String, Object>)convert).put('Line', updatedLine); 
                  addrChange = JSON.serialize(convert); 
              }
          }
      } else if (objectApiName == 'Product2') {
          productWrapper prod = (productWrapper)JSON.deserialize(addrChange, productWrapper.class);
          Object prodObj = JSON.deserializeUntyped(addrChange);
          if('Inventory'.equalsIgnoreCase(prod.Type)) {
              ((Map<String, Object>)prodObj).put('TrackQtyOnHand', true);
              addrChange = JSON.serialize(prodObj);
          }
      } else if (objectApiName == 'pymt__PaymentX__c' && SYS_DataCache.OBJ_TYPE == 'Payment_QB') {
          Object payment = JSON.deserializeUntyped(addrChange);
          Decimal paidVal = 0.00;
          if(payment instanceof Map<String, Object> && mapPaymentIds.get(iter) != null) {
              paidVal = (Decimal)((Map<String, Object>)payment).get('TotalAmt');
              cls_LinkedTxn txn = new cls_LinkedTxn(); 
              txn.TxnId = mapPaymentIds.get(iter);
              txn.TxnType = 'Invoice';
              cls_Line line = new cls_Line();
              line.Amount = paidVal;
              line.LinkedTxn = new List<cls_LinkedTxn>{txn};
              ((Map<String, Object>)payment).put('Line', ((Object)new List<cls_Line>{line}));
              addrChange = JSON.serialize(payment);
          }
      } else if (objectApiName == 'pymt__PaymentX__c' && SYS_DataCache.OBJ_TYPE == 'Refund_Receipt_QB') {
        system.debug('Refunds');
        lineJson.put(((String)recId), ((String)Refundlinejson));
          Object payment = JSON.deserializeUntyped(addrChange);
          Decimal amount = mapPayment.get(iter);
          String dateToday = String.valueOf(Date.today());
          if(payment instanceof Map<String, Object> && lineJson.get(iter) != null) { 
              String body = lineJson.get(iter).replace('###',dateToday);
              body = body.replace('##', String.valueOf(amount));
              Object lineItem = JSON.deserializeUntyped(body);
              ((Map<String, Object>)payment).put('Line', ((Object)new List<Object>{lineItem}));
              addrChange = JSON.serialize(payment);
          }
      }
      newjson.put(iter,addrChange);
    }
  }

  
  
  return newjson;
}

public class discountWrapper {
  public discountWrapper(Decimal amt) {
      this.Amount = amt;
  }
  public Decimal Amount;
  public String DetailType = 'DiscountLineDetail';
  public cls_DiscountLineDetail DiscountLineDetail = new cls_DiscountLineDetail();
}
class cls_DiscountLineDetail {
public boolean PercentBased = false;
}

public class productWrapper {
  public String Type;
}
class cls_Line {
public Decimal Amount;	//200
public cls_LinkedTxn[] LinkedTxn;
}
class cls_LinkedTxn {
public String TxnId;	//458
public String TxnType;	//Invoice
}
}


