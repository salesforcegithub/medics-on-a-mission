public with sharing class AccountClass 
{
	public static void processBeforeInserts(List<Account> TriggerNewList) 
	{
		Id IndividualRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();  

		for (Account thisAccount : TriggerNewList) 
		{
			if ('Member'.equals(thisAccount.Type)) 
			{
				thisAccount.RecordtypeId = IndividualRTId;
			}
		}
    
	}
    
    public static void processBeforeUpdates(List<Account> TriggerNewList, List<Account> TriggerOldList) 
	{
		Id IndividualRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        
        // update the related Contact Member record when certain 'demographics' fields are changed
       
       Map<Id, Account> updatedMemberAccounts = new Map<Id, Account>();
       
       for (Integer i = 0; i < TriggerNewList.size(); i++) {
           if ( (TriggerOldList[i].Phone <> TriggerNewList[i].Phone)
                 || (TriggerOldList[i].Email__c <> TriggerNewList[i].Email__c)
               	 || (TriggerOldList[i].Member_First_Name__c <> TriggerNewList[i].Member_First_Name__c)
                 || (TriggerOldList[i].Member_Middle_Name__c <> TriggerNewList[i].Member_Middle_Name__c)
                 || (TriggerOldList[i].Member_Last_Name__c <> TriggerNewList[i].Member_Last_Name__c)
              	 || (TriggerOldList[i].BillingStreet <> TriggerNewList[i].BillingStreet)
                 || (TriggerOldList[i].BillingCity <> TriggerNewList[i].BillingCity)
                 || (TriggerOldList[i].BillingState <> TriggerNewList[i].BillingState)
                 || (TriggerOldList[i].BillingPostalCode <> TriggerNewList[i].BillingPostalCode)
                 || (TriggerOldList[i].BillingCountry <> TriggerNewList[i].BillingCountry)
               	 ) {
                     
                     updatedMemberAccounts.put(TriggerOldList[i].Id, TriggerNewList[i]);                   
               }
       }
       
       List<Contact> contactMembersToUpdate = new List<Contact>();
       
       for (Contact c : [SELECT Id, AccountId, Phone, DoD_Email__c,   
                         Member_First_Name__c, Member_Middle_Name__c, Member_Last_Name__c,
                         MailingStreet, MailingCity,
                         MailingState, MailingPostalCode, MailingCountry                         
                         FROM Contact
                         WHERE AccountId IN : updatedMemberAccounts.keySet()]) {
                             
            Account memberAccount = updatedMemberAccounts.get(c.AccountId);
            
            c.Phone 				= memberAccount.Phone;                 
            c.DoD_Email__c          = memberAccount.Email__c;
            c.Member_First_Name__c 	= memberAccount.Member_First_Name__c;                 
            c.Member_Middle_Name__c = memberAccount.Member_Middle_Name__c;
            c.Member_Last_Name__c 	= memberAccount.Member_Last_Name__c;
            c.MailingStreet       	= memberAccount.BillingStreet;
            c.MailingCity         	= memberAccount.BillingCity;
            c.MailingState        	= memberAccount.BillingState;
            c.MailingPostalCode   	= memberAccount.BillingPostalCode;
            c.MailingCountry      	= memberAccount.BillingCountry;
            
            contactMembersToUpdate.add(c);
       }
       
       update contactMembersToUpdate;	  
        
    }      
    
    
}