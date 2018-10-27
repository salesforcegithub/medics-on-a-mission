public with sharing class ContactClass 
{
	public static void processBeforeInserts(List<Contact> TriggerNewList) 
	{
		Id IndividualRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();        
        Id ProviderRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Provider').getRecordTypeId();

        List<Contact> listMemberContacts = new List<Contact>();
        List<Contact> listProviderContacts = new List<Contact>();

        Integer i = 0;
        Map<Integer, String> mapProviderDoDUserID = new Map<Integer, String>();
        Map<Integer, String> mapProviderDoDEmail = new Map<Integer, String>();
        
        for(Contact c : TriggerNewList)
        {
        	//if(c.Type__c == 'Member')
        	//	listMemberContacts.add(c);

        	if(c.Type__c == 'Provider')
        	{
        		listProviderContacts.add(c);
        		mapProviderDoDUserID.put(i, c.DoD_User_Id__c);
        		mapProviderDoDEmail.put(i, c.DoD_Email__c);

        		i += 1;
        	}
        	else listMemberContacts.add(c);
        }

        if(listMemberContacts.size() > 0)
        	processMembersBeforeInsert(listMemberContacts);

        if(listProviderContacts.size() > 0)
        	processProvidersBeforeInsert(listProviderContacts, mapProviderDoDUserID, mapProviderDoDEmail);
        
	}


	public static void processMembersBeforeInsert(List<Contact> listMembers)
	{
		List<Id> acctIds = new List<Id>();        
        
        Id IndividualRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();    
        
        for (Contact c : listMembers) 
        	acctIds.add(c.AccountId); 
        
        Map<Id, Account> mbrAccts = new Map<Id, Account>(
			[SELECT Id, Dod_User_ID__c, Custodials__c, Custodians__c,  Phone, Email__c, Member_First_Name__c, Member_Middle_Name__c, Member_Last_Name__c,
				BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
			FROM Account 
			WHERE Id IN: acctIds]);
        SYSTEM.DEBUG('+++++ proccessMember: ' + listMembers[0]);
        for (Contact c : listMembers) 
        {
            
            if(mbrAccts.containsKey(c.AccountId))
            {
	            Account memberAccount = mbrAccts.get(c.AccountId);
	            
	            c.Type__c 				= 'Member';
                c.RecordTypeId 			= IndividualRTId;
                c.DoD_User_ID__c    	= memberAccount.Dod_User_ID__c;        
                c.Custodials__c     	= memberAccount.Custodials__c;
                c.Custodians__c     	= memberAccount.Custodians__c;
                c.Phone             	= memberAccount.Phone;
                c.DoD_Email__c          = memberAccount.Email__c;
                c.Member_First_Name__c 	= memberAccount.Member_First_Name__c;
                c.Member_Middle_Name__c = memberAccount.Member_Middle_Name__c;
                c.Member_Last_Name__c 	= memberAccount.Member_Last_Name__c;
                c.MailingStreet     	= memberAccount.BillingStreet;
                c.MailingCity       	= memberAccount.BillingCity;
                c.MailingState      	= memberAccount.BillingState;
                c.MailingPostalCode 	= memberAccount.BillingPostalCode;
                c.MailingCountry    	= memberAccount.BillingCountry; 
        	}
        }
	}


	public static void processProvidersBeforeInsert(List<Contact> listProviders, Map<Integer, String> mapProviderDoDUserID, Map<Integer, String> mapProviderDoDEmail)
	{
		// RelationEdge, David Berman, 28 September 2018
		// There are 10 Provider Accounts; round-robin-assign all new contacts across
		// these 10 accounts

		List<Id> acctIds = new List<Id>();        
        
        for (Contact c : listProviders) 
        	acctIds.add(c.AccountId); 
        
  
		Id ProviderRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Provider').getRecordTypeId();    
 
		List<Id> listProviderIDs = getListOfSortedProviderIDs();

		List<Account> listOriginalProviderAccountsToDelete = new List<Account>();
		
		Integer iProviderNumber = 0;
		Integer iProviderMapIndex = 0;
		for(Contact c : listProviders)
		{

			c.DoD_User_Id__c = mapProviderDoDUserID.get(iProviderMapIndex);
			c.DoD_Email__c = mapProviderDoDEmail.get(iProviderMapIndex);

			listOriginalProviderAccountsToDelete.add(new Account(Id = c.AccountId));

			if(iProviderNumber == 10)	iProviderNumber = 0;

			c.AccountId 	= listProviderIDs[iProviderNumber];
			c.RecordTypeId 	= ProviderRTId;

			iProviderNumber += 1;
			iProviderMapIndex += 1;
		}

		try{delete listOriginalProviderAccountsToDelete;}catch(Exception ex){}
	}



	private static List<Id> getListOfSortedProviderIDs()
	{

		List<String> listProvidersSortedByCount = new List<String>();
		List<Id> listProviderIDs = new List<Id>();

		Map<Id, Account> mapProviderAccounts = new Map<Id, Account>(
			[select id, (Select id from Account.Contacts) from Account WHERE Name Like 'Provider Account%' ORDER BY Name]);

		for(Account acc : mapProviderAccounts.values())
		{
		    String strNumberOfContacts = String.valueOf(acc.Contacts.size());
		    Integer iLengthNumberOfContacts = strNumberOfContacts.length();
		    
		    strNumberOfContacts = iLengthNumberOfContacts == 1 ? '000000' + strNumberOfContacts : strNumberOfContacts;
		    strNumberOfContacts = iLengthNumberOfContacts == 2 ? '00000' + strNumberOfContacts : strNumberOfContacts;
		    strNumberOfContacts = iLengthNumberOfContacts == 3 ? '0000' + strNumberOfContacts : strNumberOfContacts;
		    strNumberOfContacts = iLengthNumberOfContacts == 4 ? '000' + strNumberOfContacts : strNumberOfContacts;
		    strNumberOfContacts = iLengthNumberOfContacts == 5 ? '00' + strNumberOfContacts : strNumberOfContacts;
		    strNumberOfContacts = iLengthNumberOfContacts == 6 ? '0' + strNumberOfContacts : strNumberOfContacts;
		    strNumberOfContacts = iLengthNumberOfContacts == 7 ? '' + strNumberOfContacts : strNumberOfContacts;

		    listProvidersSortedByCount.add( strNumberOfContacts + ':' + acc.Id );
		}

		listProvidersSortedByCount.sort();

		for(String strNumberAndAccountID : listProvidersSortedByCount)
			listProviderIDs.add( ID.valueOf( strNumberAndAccountID.substringAfter(':') ) );

		return listProviderIDs;
	}
}