@isTest
private class WarehouseSyncScheduleTest {

    static testMethod void myUnitTest() {
        
        String CRON_EXP = '0 0 1 ? * *';
        
        // Associate the callout with a mock response
        DateTime lastModified = DateTime.now();
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        WarehouseCalloutService.runWarehouseEquipmentSync();
        
        Map<Id,Product2> equipmentMap = new Map<Id,Product2>([SELECT Id, Name FROM Product2 WHERE LastModifiedDate >: lastModified]);
        List<Id> equipmentId = new List<Id>(equipmentMap.keySet());
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP, 
            new WarehouseSyncSchedule());         
        // Verify the scheduled job has not run yet.
        List<Task> lt = [SELECT Id 
            FROM Task 
            WHERE WhatId IN :equipmentId];
        System.assertEquals(0, lt.size(), 'Tasks exist before job has run');
        // Stopping the test will run the job synchronously
        Test.stopTest();
        
        // Now that the scheduled job has executed,
        // check that our tasks were created
        lt = [SELECT Id 
            FROM Task 
            WHERE WhatId IN :equipmentId];
        System.assertEquals(equipmentId.size(), 
            lt.size(), 
            'Tasks were not created');
        
        	
        
        
    }
}