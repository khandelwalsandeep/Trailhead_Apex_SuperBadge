public class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<Case> newCaseRecords){
        
        Case clonedCaseRecord;
        List<Case> newMaintenanceRequestList = new List<Case>();
        Set<ID> closedMaintenanceIDs = new Set<ID>();
        
        //look for the case records when the type is 'Repair' OR 'Routine Maintenance' and the Case is 'Closed'.
        //Create a new Maintenance Request with type = 'Routine Maintenance'.
        for(Case c : [SELECT ID, Type, Status, Date_Reported__c, Vehicle__c, Subject, Date_Due__c, Equipment__r.Maintenance_Cycle__c
        			  FROM Case
        			  WHERE Id IN: newCaseRecords AND (Type = 'Repair' OR Type = 'Routine Maintenance') AND Status = 'Closed']){
        	//if((c.Type == 'Repair' || c.Type == 'Routine Maintenance') && c.Status == 'Closed'){
        		clonedCaseRecord = c.Clone();
        		clonedCaseRecord.Type = 'Routine Maintenance';
        		clonedCaseRecord.Status = 'New';
        		clonedCaseRecord.Date_Reported__c = Date.TODAY();
        		system.debug('Maintenance Subject '+c.Subject);
        		if(c.Subject == NULL)
        			clonedCaseRecord.Subject = 'Routine Mainenance';
        		clonedCaseRecord.Date_Due__c = Date.TODAY() + (Integer)c.Equipment__r.Maintenance_Cycle__c;
        		newMaintenanceRequestList.add(clonedCaseRecord);
        		closedMaintenanceIDs.add(c.Id);
        	//}
        }
        
        insert newMaintenanceRequestList;
        
    }        
    
}