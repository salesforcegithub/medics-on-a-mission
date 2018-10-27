global class MemberData_CC 
{
  @AuraEnabled 
  global static map<String,Object> getMemberData(ID recordID, String sourceObject)
  {  
    String strStatusCode = '';
    String strCSRFToken = Test.isRunningTest() == true ? 'ICbuGGaEBofnq3shi871ruLItx5zt5kB' : DoD_OAuth.getCSRFToken();

	Contact theContact;
	Case theCase;
	try{theContact = [SELECT Id, FirstName, LastName, DoD_User_ID__c FROM Contact WHERE Id =: recordID LIMIT 1];}catch(Exception exContact){}

	MemberDataJSON member;
	
	String strBearerToken = Test.isRunningTest() == true ? 'CeW1TsyNdFOZSvZhz2KhlEeYkxf04T' : DoD_OAuth.getBearerToken(strCSRFToken);
	String strAccessToken = 'Bearer token ' + strBearerToken;
	String strEndpoint;
SYSTEM.DEBUG('+++++ strAccessToken: ' + strAccessToken);

	try{strEndpoint = [SELECT Endpoint__c FROM DoD_Endpoint__mdt where MasterLabel = 'Individual Member' LIMIT 1].Endpoint__c;}catch(Exception exEndpoint){}

    httpRequest req = new httpRequest();
    req.setHeader('Accept','application/json');
    req.setHeader('Cookie', 'csrftoken=' + strCSRFToken);
    req.setHeader('Authorization', strAccessToken);
    req.setMethod('GET');
    strEndpoint = strEndpoint.replace('XXXX', theContact.Dod_User_ID__c) + '?agent_id='+ Agent.EmployeeNumber;
 SYSTEM.DEBUG('+++++ strEndpoint: ' + strEndpoint);
    req.setEndpoint(strEndpoint);
 SYSTEM.DEBUG('+++++ req: ' + req);   
    httpResponse res;
    try
    {
	    res = new http().send(req);
SYSTEM.DEBUG('+++++ res: ' + res);
	    strStatusCode = String.valueOf(res.getStatusCode());

	    if(strStatusCode == '200')
	    {
	    	String strResponseBody2 = res.getBody();
SYSTEM.DEBUG('+++++ strResponseBody2: ' + strResponseBody2);

			member = (MemberDataJSON) System.JSON.deserialize(strResponseBody2, MemberDataJSON.class);
	    }
	    
	}
	catch(Exception exMember)
	{
		strStatusCode = String.valueOf(res.getStatusCode());
		SYSTEM.DEBUG('+++++ exMember error: ' + exMember.getMessage());
	}
	
	// uncomment below when wanting to use the static resource
	//member = (MemberDataJSON) System.JSON.deserialize(strResponseBodyStatResrc, MemberDataJSON.class);

	SYSTEM.DEBUG('++++++ member: ' + member);

// *********************************************************************   
// ****** Parse JSON data **********************************************
// *********************************************************************
	String strBlacklisted;
	try
	{
		if(strStatusCode == '200')
			strBlacklisted = Boolean.valueOf(member.blacklisted) == true ? 'Yes'  : 'No/Unknown';
		else strBlacklisted = 'Call-out error code: ' + strStatusCode;
	}
	catch(Exception exBlacklisted){}
	
	String strPkID;
	try{strPkID = String.valueOf(member.id);}catch(Exception exPkID){}

	String strEmail;
	try{strEmail = member.user.email;}catch(Exception exEmail){}

	List<String> strLanguages;
	try{strLanguages = member.user.spoken_languages;}catch(Exception exLingos){}

	String strEmployer;
	try{strEmployer = member.employer;}catch(Exception exEmployer){}

	String strInsuranceActive;
	try{strInsuranceActive = Boolean.valueOf(member.insurance.active) == true ? 'Yes' : 'No/Unknown';}catch(Exception exInsuranceActive){}

	String strInsuranceGroupID;
	try{strInsuranceGroupID = member.insurance.group_id;}catch(Exception exInsuranceGroupID){}

	String strInsuranceMemberID;
	try{strInsuranceMemberID = member.insurance.insurance_member_id;}catch(Exception exInsuranceMemberID){}

	String strInsurancePayer;
	try{strInsurancePayer = member.insurance.payer;}catch(Exception exInsurancePayer){}

	String strIsCustodial;
	try{strIsCustodial = Boolean.valueOf(member.is_custodial) == true ? 'Yes' : 'No';}catch(Exception exIsCustodial){}

	String strLastLocation;
	try{strLastLocation = member.last_location;}catch(Exception exLastLocation){}
	
	String strLastLogin;
	try
	{
		//"2018-04-09T17:00:13.537908Z"
		strLastLogin = member.last_login;
		List<String> arDateTime = strLastLogin.split('T');
		String strTime = arDateTime[1].substring(0,5);
		String strDate = arDateTime[0];
		List<String> arDate = strDate.split('-');
		strDate = arDate[1] + '/' + arDate[2] + '/' + arDate[0];

		strLastLogin = strDate + ' ' + strTime;
	}catch(Exception exLastLogin){}

	String strPhoneNumber;
	try
	{
		strPhoneNumber = member.phone_number;
		List<String> arPhone = strPhoneNumber.split('-');
		strPhoneNumber = '(' + arPhone[0] + ') ' + arPhone[1]+ '-' + arPhone[2];
	}catch(Exception exPhoneNumber){}
	
	String strProviderID;
	try{strProviderID = String.valueOf(member.user.id);}catch(Exception exProvID){}

	String strUserFirstName;
	try{strUserFirstName = member.user.first_name;}catch(Exception exUserFirstName){}

	String strUserLastName;
	try{strUserLastName = member.user.last_name;}catch(Exception exUserLastName){}

	String strUserMiddleName;
	try{strUserMiddleName = member.user.middle_name;}catch(Exception exUserMiddleName){}

	String strUserPrefix;
	try{strUserPrefix = member.user.prefix;}catch(Exception exUserPrefix){}

	String strUserSuffix;
	try{strUserSuffix = member.user.suffix;}
	catch(Exception exUserSuffix)
	{
		if(strStatusCode != '200')		strUserSuffix = 'Call-out error code: ' + strStatusCode;
	}
	
    String strAddressStreet;
	try{strAddressStreet = member.address.street;}catch(Exception exAddressStreet){}

	String strAddressStreet2;
	try{strAddressStreet2 = member.address.extended;}catch(Exception exAddressStreet2){}
	
	String strCity;
	try{strCity = member.address.locality;}catch(Exception exAddressCity){}
	
	String strState;
	try{strState = member.address.state;}catch(Exception exAddressState){}
	
	String strPostalcode;
	try{strPostalcode = member.address.postal_code;}catch(Exception exAddressPostalcode){}
	
	String strCountry;
	try{strCountry = member.address.country;}catch(Exception exAddressCountry){}
	
	Map<String, Object> mapMemberData = new Map<String, Object>();
	mapMemberData.put('id', 				strPkID);
	mapMemberData.put('provider_id',		strProviderID);
	mapMemberData.put('blacklisted',		strBlacklisted);
	mapMemberData.put('first_name',			strUserFirstName);
	mapMemberData.put('middle_name',		strUserMiddleName);
    mapMemberData.put('last_name',			strUserLastName);
    mapMemberData.put('last_location',		strLastLocation);
    mapMemberData.put('email',				strEmail);
    mapMemberData.put('spoken_languages',	strLanguages);
    mapMemberData.put('employer_name',		strEmployer);
    mapMemberData.put('insurance_active', 	strInsuranceActive);
    mapMemberData.put('insurance_group_id', strInsuranceGroupID);
    mapMemberData.put('insurance_payer', 	strInsurancePayer);
    mapMemberData.put('insurance_member_id',strInsuranceMemberID);
    mapMemberData.put('is_custodial', 		strIsCustodial);
    mapMemberData.put('last_login', 		strLastLogin);
    mapMemberData.put('phone_number', 		strPhoneNumber);
    mapMemberData.put('user_first_name', 	strUserFirstName);
    mapMemberData.put('user_last_name' , 	strUserLastName);
    mapMemberData.put('user_middle_name' , 	strUserMiddleName);
    mapMemberData.put('user_prefix', 		strUserPrefix);
    mapMemberData.put('user_suffix' , 		strUserSuffix);
    mapMemberData.put('street' , 			strAddressStreet);
    mapMemberData.put('extended' , 			strAddressStreet2);
    mapMemberData.put('locality' , 			strCity);
    mapMemberData.put('state' , 			strState);
    mapMemberData.put('postal_code' , 		strPostalcode);
    mapMemberData.put('country' , 			strCountry);

    return mapMemberData;


  }

  @AuraEnabled
  global static User Agent
  {
  	get
  	{
  		if(Agent == null)
  		{
  			Agent = new User();
  			try{Agent = [SELECT Id, EmployeeNumber FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];}catch(Exception exAgentID){}
  		}
  		return Agent;
  	}
  	set;
  }

  // For now use static resource JSON file
  	/*
  	StaticResource sr = [SELECT Id,NamespacePrefix,SystemModstamp FROM StaticResource WHERE Name = 'SampleMemberResponseJSON' LIMIT 1];
	String prefix = sr.NamespacePrefix;
	if( String.isEmpty(prefix) ) {prefix = '';} else {prefix += '__';}
	String srPath = '/resource/' + sr.SystemModstamp.getTime() + '/' + prefix + 'SampleMemberResponseJSON'; 
	PageReference pg = new PageReference( srPath );
	String strResponseBodyStatResrc = pg.getContent().toString();
	*/
/*

SYSTEM.DEBUG('+++++ employer: ' + member.employer);
	SYSTEM.DEBUG('+++++ insurance.group_id: ' + member.insurance.group_id);
	SYSTEM.DEBUG('+++++ insurance.active: ' + member.insurance.active);
	SYSTEM.DEBUG('+++++ insurance.insurance_member_id: ' + member.insurance.insurance_member_id);
	SYSTEM.DEBUG('+++++ insurance.payer: ' + member.insurance.payer);

	SYSTEM.DEBUG('+++++ id/blacklisted: ' + member.id + ' :: ' + member.blacklisted);
	SYSTEM.DEBUG('+++++ custodians: ' + member.custodians[0].id + ' :: ' + member.custodians[0].first_name + ' ' + member.custodians[0].last_name);
	SYSTEM.DEBUG('+++++ is_custodial: ' + member.is_custodial);
	SYSTEM.DEBUG('+++++ last_login: ' + member.last_login);
	SYSTEM.DEBUG('+++++ phone_number: ' + member.phone_number);

	SYSTEM.DEBUG('+++++ user.first_name: ' + member.user.first_name);
	SYSTEM.DEBUG('+++++ user.last_name: ' + member.user.last_name);
	SYSTEM.DEBUG('+++++ user.middle_name: ' + member.user.middle_name);
	SYSTEM.DEBUG('+++++ user.prefix: ' + member.user.prefix);
	SYSTEM.DEBUG('+++++ user.suffix: ' + member.user.suffix);
{
 "id": 1,
"blacklisted": false,
"custodians": [
 {
 "id": 1,
"first_name": "Sam",
"last_name": "Lowry"
 }
 ],
 "employer": "Employer Payer Company",
"insurance": {
 "active": true,
"group_id": "Group ID#1",
"insurance_member_id": "Insurance member ID#1",
"payer": "Employer Payer"
 },
 "is_custodial": true,
"last_login": "2018-04-09T17:00:13.537908Z",
"phone_number": "555-867-5309",
"user": {
 "first_name": "Sam",
"last_name": "Lowry",
"middle_name": "",
"prefix": "",
"suffix": ""
 }
}
*/


/*
    try
    {
    	httpResponse resAuth = new http().send(reqAuth);

    	strStatusCode = String.valueOf(resAuth.getStatusCode());
	    if(strStatusCode == '200')
	    {

	    	String strResponseBodyAuth = resAuth.getBody();

	    	Map<String, Object> r = new Map<String, Object>();
        	r = (Map<String,Object>) JSON.deserializeUntyped(strResponseBodyAuth);        
        	strAccessToken = (String)r.get('access_token');
        
        SYSTEM.DEBUG('+++++ strAccessToken: ' + strAccessToken);
	    }
	    
    }
    catch(Exception exAuth){strStatusCode = String.valueOf(resAuth.getStatusCode());}
	*/

}