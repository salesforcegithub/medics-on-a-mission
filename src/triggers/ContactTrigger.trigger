trigger ContactTrigger on Contact (before insert) 
{
    
    if (Trigger.isBefore && Trigger.isInsert)
    {
    	ContactClass.processBeforeInserts(Trigger.new);
    }

}