@isTest
private class MemberPsychAppointments_CC_Test 
{
	
	@isTest
	static void test_MemberPsychAppointmentsJSON()
	{
		StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = 'SampleMemberPsychAppointmentsJSON'];
		String body = resource.Body.toString();

		Test.startTest();
		MemberPsychAppointmentsJSON mma;
		mma = (MemberPsychAppointmentsJSON) System.JSON.deserialize(body, MemberPsychAppointmentsJSON.class);

		MemberPsychAppointmentsJSON.parse(body);
		
		Test.stopTest();
	}


	@isTest
	static void test_MemberPsychAppointments()
	{
		Contact con = [SELECT Id, LastName FROM Contact LIMIT 1];
		String strCSRFToken = 'ICbuGGaEBofnq3shi871ruLItx5zt5kB';
		String strAccessToken = 'CeW1TsyNdFOZSvZhz2KhlEeYkxf04T';

		StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = 'SampleMemberPsychAppointmentsJSON'];

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

    	MemberPsychAppointments_CC.wrapperClass wc = MemberPsychAppointments_CC.initMethod(con.Id);
    	SYSTEM.assert(wc.headerMsg == 'Member Behavioral Health Appointments');
    	Test.stopTest();
	}





	@testSetup 
	static void setup()
	{
		Account testAccount = new Account(
			Name = 'testAccount',
			Member_First_Name__c = 'bob', 
			Member_Middle_Name__c = 'timmy', 
			Member_Last_Name__c = 'smith', 
			Phone = '916-555-2134', 
			Email__c = 'b@me.com', 
			Date_of_Birth__c = Date.newinstance(2012,2,16), 
			Gender__c = 'M', 
			DoD_User_ID__c = '0001',
			Type = 'Member', 
			BillingStreet = '123 street', 
			BillingCity = 'west view', 
			BillingState = 'co', 
			BillingPostalCode = '67543', 
			BillingCountry = 'us'
			);
		insert testAccount;
		
		// This will also create a Contact record!
	}
	
}