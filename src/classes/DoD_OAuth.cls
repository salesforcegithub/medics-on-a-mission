public class DoD_OAuth
{

	public static String getCSRFToken()
	{
		String strCSRFToken = '';
		
		String strEndpoint = [SELECT Endpoint__c FROM DoD_Endpoint__mdt where MasterLabel = 'Authorization Get CSRF Token' LIMIT 1].Endpoint__c;

		httpRequest req = new httpRequest();
	    req.setHeader('Accept','application/json');
	    
	    req.setMethod('GET');
	    req.setEndpoint(strEndpoint);
		
		httpResponse res;
		res = new http().send(req);
		String strStatusCode = String.valueOf(res.getStatusCode());
		if(strStatusCode == '200')
		{
			String strResponseBody = res.getBody();
			Dom.Document inDoc = new Dom.Document();
			inDoc.load(strResponseBody);
			Dom.XmlNode root = inDoc.getRootElement();
			Dom.XmlNode inputTag = root.getChildElement('input', null);
			strCSRFToken = inputTag.getAttributeValue('value', null);
		}
		return strCSRFToken;
	}

	public static String getBearerToken(String strCSRFToken)
	{
		String strBearerToken = '';
		
		// call-out to get new token
		String strEndpoint = [SELECT Endpoint__c FROM DoD_Endpoint__mdt where MasterLabel = 'Authorization Get Bearer Token' LIMIT 1].Endpoint__c;

		DoDClient__c csDoDClient = DoDClient__c.getValues('DoD Client Details');
		String strJSONBody = '{' +
			'"CLIENT_ID":"' + csDoDClient.Client_ID__c + '",' +
			'"CLIENT_SECRET":"' + csDoDClient.Client_Secret__c + '",' +
			'"GRANT_TYPE":"' + csDoDClient.Grant_Type__c + '",' +
			'"SCOPE": ["' + csDoDClient.Scope__c + '"]' + 
			'}';
		
		httpRequest req = new httpRequest();
	    req.setHeader('Accept','application/json');
	    req.setHeader('X-CSRFToken', strCSRFToken);
	    req.setHeader('Cookie', 'csrftoken=' + strCSRFToken);
	    req.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
	    req.setHeader('Expires', '0');
	    req.setHeader('Pragma', 'no-cache');
	    //req.setHeader('Cache-Control','public,max-age=0');
	    req.setHeader('Referer', csDoDClient.Referer__c); 
	    req.setMethod('POST');
	    req.setBody(strJSONBody);
	    req.setEndpoint(strEndpoint);

SYSTEM.DEBUG('+++++ strEndpoint: ' + strEndpoint);
SYSTEM.DEBUG('+++++ req: ' + req);
SYSTEM.DEBUG('+++++ strCSRFToken: ' + strCSRFToken);

	    httpResponse res;
	    String strStatusCode;
	    AccessTokenJSON BearerToken; 
	    try
	    {
	    	res = new http().send(req);

		    strStatusCode = String.valueOf(res.getStatusCode());

		    if(strStatusCode == '200')
		    {
		    	String strResponseBody = res.getBody();

				BearerToken = (AccessTokenJSON) System.JSON.deserialize(strResponseBody, AccessTokenJSON.class);

				strBearerToken = BearerToken.access_token;

		    }
		    
		}
		catch(Exception exBearerToken)
		{
			strStatusCode = String.valueOf(res.getStatusCode());
			SYSTEM.DEBUG('+++++ exBearerToken error: ' + exBearerToken.getMessage() + ' on ' + exBearerToken.getLineNumber());
		}
		
		return strBearerToken;
	}

}