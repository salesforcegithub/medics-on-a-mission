trigger AccountTrigger on Account (before insert, before update) 
{
  
  if (Trigger.isInsert && Trigger.isBefore) 
  {
    AccountClass.processBeforeInserts(Trigger.new);
  }
    
    if (Trigger.isUpdate && Trigger.isBefore) 
  {
    AccountClass.processBeforeUpdates(Trigger.new, Trigger.old);
  }

}