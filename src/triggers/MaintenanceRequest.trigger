trigger MaintenanceRequest on Case (before update, after update) {
    // call MaintenanceRequestHelper.updateWorkOrders  
    if(Trigger.isAfter){
	    //MaintenanceRequestHelper m = new MaintenanceRequestHelper();
	    MaintenanceRequestHelper.updateWorkOrders(Trigger.New);
    }
}