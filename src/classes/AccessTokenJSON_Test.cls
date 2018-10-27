@isTest
private class AccessTokenJSON_Test 
{
	
	static Testmethod void test_method_one() 
	{
		String strJSON = ''+
			'{'+
			'	"token_type":"Bearer",'+
			'	"scope":"member_support",'+
			'	"access_token":"abc123",'+
			'	"expires_in":86400';

		Test.startTest();
		AccessTokenJSON obj = AccessTokenJSON.parse(strJSON);
		Test.stopTest();
	}
	
	
}