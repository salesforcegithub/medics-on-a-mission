public with sharing class AccessTokenJSON 
{
	
	@AuraEnabled public String token_type;
	@AuraEnabled public String scope;
	@AuraEnabled public String access_token;
	@AuraEnabled public Integer expires_in;

	@AuraEnabled public static AccessTokenJSON parse(String json)
	{
		return (AccessTokenJSON) System.JSON.deserialize(json, AccessTokenJSON.class);
	}
}