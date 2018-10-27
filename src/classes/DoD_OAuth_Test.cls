@isTest
private class DoD_OAuth_Test 
{
	
	static Testmethod void test_getCSRFToken() 
	{
		
        Integer code = 200;
        String status = 'Success';
        String body = '<form method="post" action="" enctype="multipart/form-data">' + 
    		'<input type="hidden" name="csrfmiddlewaretoken" value="ICbuGGaEBofnq3shi871ruLItx5zt5kB" />'+
    		'<table></table></form>';

        Map<String, String> mapResponseHeaders = new Map<String, String>();
        mapResponseHeaders.put('Accept','application/json');

		Test.setMock(HttpCalloutMock.class, 
			new MockHttpResponseGenerator(code, status, body, mapResponseHeaders));

		Test.startTest();
		String strCSRFToken = DoD_OAuth.getCSRFToken();

		System.assertEquals(strCSRFToken, 'ICbuGGaEBofnq3shi871ruLItx5zt5kB');

        Test.stopTest();
	}


	static Testmethod void test_getBearerToken()
	{
		String strCSRFToken = 'ICbuGGaEBofnq3shi871ruLItx5zt5kB';

		Integer code = 200;
        String status = 'Success';
        String body = '{"access_token": "CeW1TsyNdFOZSvZhz2KhlEeYkxf04T",'+
    					'"expires_in": 86400,'+
    					'"token_type": "Bearer",'+
    					'"scope": "member_support"}';
    	Map<String, String> mapResponseHeaders = new Map<String, String>();
    	mapResponseHeaders.put('Accept','application/json');
    	mapResponseHeaders.put('X-CSRFToken', strCSRFToken);
    	mapResponseHeaders.put('Cookie', 'csrftoken=' + strCSRFToken);
    	mapResponseHeaders.put('Cache-Control', 'no-cache, no-store, must-revalidate');
    	mapResponseHeaders.put('Expires', '0');
    	mapResponseHeaders.put('Pragma', 'no-cache');
    	mapResponseHeaders.put('Referer', 'Test Referer');

    	Test.setMock(HttpCalloutMock.class, 
			new MockHttpResponseGenerator(code, status, body, mapResponseHeaders));

    	// set up custom setting record
    	DoDClient__c dc = new DoDClient__c();
    	dc.Name = 'DoD Client Details';
    	dc.Client_ID__c = 'clientid';
    	dc.Client_Secret__c = 'clientsecret';
    	dc.Grant_Type__c = 'client_credentials';
    	dc.Scope__c = 'member_support';
    	dc.Referer__c = 'referer';
    	insert dc;

    	Test.startTest();
    	String strBearerToken = Dod_OAuth.getBearerToken(strCSRFToken);
    	Test.stopTest();

    	System.assertEquals(strBearerToken, 'CeW1TsyNdFOZSvZhz2KhlEeYkxf04T');

    	
	}
	
	
}