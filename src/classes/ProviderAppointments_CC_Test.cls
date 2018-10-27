@isTest
private class ProviderAppointments_CC_Test 
{
	
	@isTest
	static void test_ProviderAppointmentsJSON()
	{
		StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = 'SampleProviderAppointmentsJSON'];
		String body = resource.Body.toString();

		Test.startTest();
		ProviderAppointmentsJSON pa;
		pa = (ProviderAppointmentsJSON) System.JSON.deserialize(body, ProviderAppointmentsJSON.class);

		ProviderAppointmentsJSON.parse(body);
		
		Test.stopTest();
	}


	@isTest
	static void test_ProviderAppointments()
	{
		Contact provider = [SELECT Id, LastName FROM Contact LIMIT 1];
		String strCSRFToken = 'ICbuGGaEBofnq3shi871ruLItx5zt5kB';
		String strAccessToken = 'CeW1TsyNdFOZSvZhz2KhlEeYkxf04T';

		StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = 'SampleProviderAppointmentsJSON'];

		Integer code = 200;
        String status = 'Success';
        String body = resource.Body.toString();

        Map<String, String> mapResponseHeaders = new Map<String, String>();
    	mapResponseHeaders.put('Accept','application/json');
    	mapResponseHeaders.put('Cookie', 'csrftoken=' + strCSRFToken);
    	mapResponseHeaders.put('Authorization', strAccessToken);
    		

    	Test.setMock(HttpCalloutMock.class, 
			new MockHttpResponseGenerator(code, status, body, mapResponseHeaders));

    	Test.startTest();

    	ProviderAppointments_CC.wrapperClass wc = ProviderAppointments_CC.initMethod(provider.Id);
    	SYSTEM.assert(wc.headerMsg == 'Appointments');
    	Test.stopTest();
	}





	@testSetup static void setupData()
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

	
		String strRandom = 'X980000';

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
		insert con;

	}
	
}