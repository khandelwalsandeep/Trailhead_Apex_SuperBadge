@isTest
private class MaintenanceRequestHelperTest {
	@isTest(SeeAllData=true)
    static void positiveTest() {
        
        //Insert Vehicle
        Vehicle__c newVeh = new Vehicle__c(Name='New Vehicle');
        insert newVeh;
        //insert case
        Case c = new Case(Type='Repair', Status='New', Origin='Web', Equipment__c = [SELECT ID, Maintenance_Cycle__c FROM Product2 WHERE Id = '01t7F000000DQanQAG'].Id,
        			      Vehicle__c = newVeh.Id);
        insert c;
        
        //close case with type = 'Repair'
        c.Status = 'Closed';
        update c;
        
        //check whether new case is created with all the automated fields populated 
        Case newCase = [SELECT Id, Type, Status, Origin, Date_Reported__c, Subject, createdDate, Equipment__c, Date_Due__c, Vehicle__c FROM Case ORDER BY createdDate DESC LIMIT 1];
        system.debug('Case ID '+newCase.Id+' Case Type '+newCase.Type+' Case Status '+newCase.Status + 'Case created date '+newCase.createdDate+' Due Date '+newCase.Date_Due__c);
        system.assertEquals('Routine Maintenance', newCase.Type);
        system.assertEquals('New', newCase.Status);
        system.assertEquals(Date.TODAY(), newCase.Date_Reported__c);
        system.assertEquals('Routine Mainenance', newCase.Subject);
        system.assertEquals(c.Vehicle__c, newCase.Vehicle__c);
        system.assertEquals(c.Equipment__c, newCase.Equipment__c);
        system.assertEquals(Date.today() + 5, newCase.Date_Due__c);
        
    }
    
    @isTest(SeeAllData=true)
    static void negativeTest() {
        //Insert Vehicle
        Vehicle__c newVeh = new Vehicle__c(Name='New Vehicle');
        insert newVeh;
        //insert case
        Case c = new Case(Type='Repair', Status='New', Origin='Web', Equipment__c = [SELECT ID, Maintenance_Cycle__c FROM Product2 WHERE Id = '01t7F000000DQanQAG'].Id,
        			      Vehicle__c = newVeh.Id);
        insert c;
        
        //close case with type = 'Repair'
        c.Status = 'Working';
        update c;
        
        Case oldCase = [SELECT ID, LastModifiedDate FROM Case WHERE Id =: c.Id];
        system.debug('Last modified date of previous case '+oldCase.LastModifiedDate);
        
        for(Case newCase : [SELECT Id, Type, Status, Origin, Date_Reported__c, Subject, createdDate, Equipment__c, Date_Due__c, Vehicle__c FROM Case WHERE createdDate >: oldCase.LastModifiedDate LIMIT 1]){
        	system.assertEquals(NULL, newCase);
        }
       
    }
    
    @isTest(SeeAllData=true)
    static void bulkTest() {
        //Insert Vehicle
        Vehicle__c newVeh = new Vehicle__c(Name='New Vehicle');
        insert newVeh;
        //insert case
        Product2 EquipmentId = [SELECT ID, Maintenance_Cycle__c FROM Product2 WHERE Id =: '01t7F000000DQanQAG'];
        List<Case> caseList = new List<Case>();
        List<Case> caseListUpdate = new List<Case>();
        
        for(Integer i=1 ; i<=300 ; i++){
        	caseList.add(new Case(Type='Repair', Status='New', Origin='Web', Equipment__c = EquipmentId.Id, Vehicle__c = newVeh.Id));
        }
        insert caseList;
        
        DateTime currentDate = Datetime.now();
        
        for(Case caseRec : [SELECT Id, Status FROM Case WHERE ID IN: caseList]){
        	caseRec.Status = 'Closed';
        	caseListUpdate.add(caseRec);
        }
        Test.startTest();
        update caseListUpdate;
        Test.stopTest();
        
        for(Case caseRec : [SELECT Id, Type, Status, Origin, Date_Reported__c, Subject, createdDate, Equipment__c, Date_Due__c, Vehicle__c 
        					FROM Case 
        					WHERE createdDate >: currentDate]){
        					
        					 system.assertEquals('Routine Maintenance', caseRec.Type);	
        				     system.assertEquals('New', caseRec.Status);
					         system.assertEquals(Date.TODAY(), caseRec.Date_Reported__c);
					         system.assertEquals('Routine Mainenance', caseRec.Subject);
					         system.assertEquals(newVeh.Id, caseRec.Vehicle__c);
					         system.assertEquals(EquipmentId.Id, caseRec.Equipment__c);
        					}
        
        
        
        
        
    }
}