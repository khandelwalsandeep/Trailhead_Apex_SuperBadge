public with sharing class WarehouseCalloutService {
    
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    // complete this method to make the callout (using @future) to the
    // REST endpoint and update equipment on hand.
    @future(callout=true)
    public static void runWarehouseEquipmentSync(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        // Parse JSON response to get all the totalPrice field values.
        JSONParser parser = JSON.createParser(response.getBody());
  
        Map<String, SobjectField> fieldMap = new Map<String, SObjectField> {
            										'replacement' => Product2.Replacement_Part__c,
									                'cost' => Product2.Cost__c,
									                'lifespan' => Product2.Lifespan_Months__c,
									                'maintenanceperiod' => Product2.Maintenance_Cycle__c,
													'quantity' => Product2.Current_Inventory__c,
													'sku' => Product2.Warehouse_SKU__c,
													'name' => Product2.Name
                								};
                    
        Product2 tempProduct;
        List<Product2> productList = new List<Product2>();
        String fieldName;
        
        while(parser.nextToken() != null) {
            // Save field name, next round we'll get the value
            if(parser.getCurrentToken() == JsonToken.FIELD_NAME) {
                fieldName = parser.getText();
                continue;
            }
            // Special case-- if the field name isn't null, we know a value is here
            if(fieldName != null && fieldMap.containsKey(fieldName)) {
                if(fieldName == 'replacement')
                	tempProduct.put(fieldMap.get(fieldName), TRUE);
                else if(fieldName == 'cost' || fieldName == 'lifespan' || fieldName == 'maintenanceperiod' || fieldName == 'quantity')	
                	tempProduct.put(fieldMap.get(fieldName), parser.getIntegerValue());
               	else if(fieldName == 'sku' || fieldName == 'name')
               		tempProduct.put(fieldMap.get(fieldName), parser.getText());
                fieldName = null;
                continue;
            }
            // We check for a new object later, because it's a rarer event.
            if(parser.getCurrentToken() == JsonToken.START_OBJECT) {
                tempProduct = new Product2();
                continue;
            }
            // Once we know end of object, we can start a new record.
            if(parser.getCurrentToken() == JsonToken.END_OBJECT) {
                productList.add(tempProduct);
                tempProduct = null;
                continue;
            }
        }
        for(Product2 prod : productList){
        	system.debug('Product Details '+prod);
        }
        
        Schema.SObjectField externalField = Product2.Fields.Warehouse_SKU__c;
        
        //Database.UpsertResult[] cr = Database.upsert(productList﻿, externalField, false);﻿
        Database.UpsertResult[] cr = Database.upsert(productList, externalField, false);
    }
    
}