@isTest
private class WarehouseCalloutServiceTest {
  // implement your mock callout test here
  	@isTest static void testWarehouseCallout(){
  	
        // Associate the callout with a mock response
        DateTime lastModified = DateTime.now();
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        WarehouseCalloutService.runWarehouseEquipmentSync();
        
        for(Product2 equipments : [SELECT Id, Replacement_Part__c FROM Product2 WHERE LastModifiedDate >: lastModified]){
        	system.assertEquals(TRUE, equipments.Replacement_Part__c);
        }
        
     }
}