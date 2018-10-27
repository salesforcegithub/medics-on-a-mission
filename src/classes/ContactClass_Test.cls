@isTest(seealldata=false)
private class ContactClass_Test 
{
	
	static Testmethod void test_member_insert() 
	{
		Integer rand = Math.round(Math.random()*1000000);
		String strRand = String.valueOf(rand);
		
		Contact con = new Contact();
		con.LastName = 'Test Last Name';
		con.DoD_Email__c = 'smith' + strRand + '@google.com';
    	con.FirstName = 'Joe';
    	con.Phone = '916-555-4315';
    	con.Birthdate = Date.valueOf('2012-01-03');
    	con.Gender__c='Male';
    	con.MailingStreet='123 north';
    	con.MailingCity='Orange';
    	con.MailingState='CA';
    	con.MailingPostalCode='913445';
    	con.MailingCountry='US';
    	con.Dod_User_ID__c = 'X' + strRand;
    	con.Type__c='Member';
    	con.User_Active__c = true;

		Test.startTest();
		insert con;

		Contact conForAssert = [SELECT Id, LastName FROM Contact LIMIT 1];

		SYSTEM.assertEquals(conForAssert.LastName, 'Test Last Name');

		Test.stopTest();

		
	}
	
	static Testmethod void test_provider_insert() 
	{
		Id ProviderAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
		List<Account> listProviderAccounts = new List<Account>();

		for(Integer i = 1; i <= 10; i++)
		{
			Account newProv = new Account();
			newProv.RecordtypeId = ProviderAccountRTId;
			newProv.HealthCloudGA__SourceSystem__c = 'Health1-00DK000000XJzSf';
			newProv.HealthCloudGA__EnrollmentType__c = 'NonDual';
			newProv.Type = 'Provider';

			if(i < 10)	newProv.Name = 'Provider Account 0' + i;
			else newProv.Name = 'Provider Account 10';

			listProviderAccounts.add( newProv );
		}

		insert listProviderAccounts;

		List<Contact> listProviderContacts = new List<Contact>();
		for(Integer j = 0; j < 300; j++)
		{
			Integer iRandom = 980000 + j;
			String strRandom = 'X' + String.valueOf(iRandom);

			Contact con = new Contact();
			con.DoD_Email__c = 'Test' + strRandom + '@testprovider.com';
			con.FirstName = 'Test' + strRandom;
			con.LastName = 'Test' + strRandom;
			con.Degrees__c = 'MD;Pharm';
			con.Spoken_Languages__c = 'English';
			con.States_Licensed_m__c = 'CA;LA';
			con.See_Under_18__c = true;
			con.See_Over_18__c = true;
			con.Specialties__c = 'Psychiatry;Meds/Peds';
			con.Allow_Self_Scheduling__c = true;
			con.Allow_After_Hours_Calls__c = true;
			con.Allow_Interpretation_Calls__c = true;
			con.Provider_Type__c = 'Doctor';
			con.Type__c = 'Provider';
			con.User_Active__c = true;
			con.Provider_Demo__c = true;


			con.DoD_User_Id__c = strRandom;

			if(!listProviderContacts.contains(con))	listProviderContacts.add( con );

		}
SYSTEM.DEBUG('+++++ listProviderContacts: ' + listProviderContacts.size());
SYSTEM.DEBUG('+++++ listProviderContacts: ' + listProviderContacts);

		Test.startTest();
		insert listProviderContacts;



		Test.stopTest();

		

		List<Contact> listContactsForAssert = new List<Contact>(
			[SELECT Id, FirstName, Type__c, RecordTypeId, RecordType.Name FROM Contact]);// WHERE Type__c = 'Provider']);

		SYSTEM.DEBUG('+++++ listContactsForAssert: ' + listContactsForAssert);
		SYSTEM.DEBUG('+++++ firstContact: ' + listContactsForAssert[0]);

		SYSTEM.assertEquals(listContactsForAssert.size(), 300);

		SYSTEM.assertEquals(listContactsForAssert[0].FirstName, 'TestX980000');

	}
}