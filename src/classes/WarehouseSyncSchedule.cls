public class WarehouseSyncSchedule implements Schedulable{
  // implement scheduled code here
  public void execute(SchedulableContext sc){
  	WarehouseCalloutService.runWarehouseEquipmentSync();
  }
}