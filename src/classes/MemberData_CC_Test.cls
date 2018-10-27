@isTest
private class MemberData_CC_Test 
{
	static TestMethod void test_parse_member_json() 
	{
		String json=		'{'+
		' "id": 1,'+
		'"blacklisted": false,'+
		'"custodians": ['+
		' {'+
		' "id": 1,'+
		'"first_name": "Sam",'+
		'"last_name": "Lowry"'+
		' }'+
		' ],'+
		' "employer": "Employer Payer Company",'+
		'"insurance": {'+
		' "active": true,'+
		'"group_id": "Group ID#1",'+
		'"insurance_member_id": "Insurance member ID#1",'+
		'"payer": "Employer Payer"'+
		' },'+
		' "is_custodial": true,'+
		'"last_login": "2018-04-09T17:00:13.537908Z",'+
		'"phone_number": "555-867-5309",'+
		'"user": {'+
		' "first_name": "Sam",'+
		'"last_name": "Lowry",'+
		'"middle_name": "",'+
		'"prefix": "",'+
		'"suffix": ""'+
		' }'+
		'}';

		Test.startTest();
		MemberDataJSON obj = MemberDataJSON.parse(json);
		Test.stopTest();
		System.assert(obj != null);
	}

	@isTest 
	static void test_positive_getMemberData() 
	{
		Contact con = [SELECT Id, LastName FROM Contact LIMIT 1];
		String strCSRFToken = 'ICbuGGaEBofnq3shi871ruLItx5zt5kB';
		String strAccessToken = 'CeW1TsyNdFOZSvZhz2KhlEeYkxf04T';

		StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = 'SampleMemberResponseJSON'];

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
    	Map<String,Object> testMap = MemberData_CC.getMemberData(con.Id, 'Contact');

    	Test.stopTest();
	}

	@isTest 
	static void test_negative_getMemberData() 
	{
		Contact con = [SELECT Id, LastName FROM Contact LIMIT 1];
		String strCSRFToken = 'ICbuGGaEBofnq3shi871ruLItx5zt5kB';
		String strAccessToken = 'CeW1TsyNdFOZSvZhz2KhlEeYkxf04T';

		StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = 'SampleMemberResponseJSON'];

		Integer code = 400;
        String status = 'Failure';
        String body = resource.Body.toString();

    	Map<String, String> mapResponseHeaders = new Map<String, String>();
    	mapResponseHeaders.put('Accept','application/json');
    	mapResponseHeaders.put('Cookie', 'csrftoken=' + strCSRFToken);
    	mapResponseHeaders.put('Authorization', strAccessToken);
    		

    	Test.setMock(HttpCalloutMock.class, 
			new MockHttpResponseGenerator(code, status, body, mapResponseHeaders));

    	Test.startTest();
    	Map<String,Object> testMap = MemberData_CC.getMemberData(con.Id, 'Contact');

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