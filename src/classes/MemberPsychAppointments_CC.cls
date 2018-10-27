public class MemberPsychAppointments_CC 
{
	@AuraEnabled
	public static wrapperClass initMethod(ID recordID)
    {
    	wrapperClass returnwrapperClass = new wrapperClass();        
        returnwrapperClass.lstAppointments = new List<appointment>();

		Contact thePatient;
		Case theCase;
		try{thePatient = [SELECT Id, FirstName, LastName, DoD_User_ID__c, Provider_Type__c FROM Contact WHERE Id =: recordID LIMIT 1];}catch(Exception exPatient){}
SYSTEM.DEBUG('+++++ theProvider: ' + thePatient);
		
		MemberPsychAppointmentsJSON theAppointments;
	    String strEndpoint;
		try{strEndpoint = [SELECT Endpoint__c FROM DoD_Endpoint__mdt where MasterLabel = 'Member Behavioral Health Appointments' LIMIT 1].Endpoint__c;}catch(Exception exEndpoint){}

	    strEndpoint = strEndpoint.replace('XXXX', thePatient.Dod_User_ID__c);
	    
	    String pastAppointments = strEndpoint  + '?limit=10&agent_id='+Agent.EmployeeNumber;
	    String futureAppointments = strEndpoint + '?scheduled=true&limit=5&agent_id='+Agent.EmployeeNumber;

	    MemberPsychAppointmentsJSON thePastAppointments = getAppointmentsFromJSON(pastAppointments);
	    MemberPsychAppointmentsJSON theFutureAppointments = getAppointmentsFromJSON(futureAppointments);

	    returnwrapperClass.lstAppointments = assembleAppointments(returnwrapperClass.lstAppointments, theFutureAppointments);
		returnwrapperClass.lstAppointments = assembleAppointments(returnwrapperClass.lstAppointments, thePastAppointments);
		
   SYSTEM.DEBUG('++++++ returnwrapperClass.lstAppointments: ' + returnwrapperClass.lstAppointments);
        returnwrapperClass.appointmentCount = returnwrapperClass.lstAppointments.size(); 
        returnwrapperClass.headerMsg = 'Member Behavioral Health Appointments';
        
        return returnwrapperClass;    
    }


    public static List<appointment> assembleAppointments(List<appointment> results, MemberPsychAppointmentsJSON inputResults)
    {
    	for(MemberPsychAppointmentsJSON.cls_results mma : inputResults.results)
		{
//	SYSTEM.DEBUG('+++++ mma; ' + mma.cid + ' / ' + mma.member);
		    appointment apt = new appointment();
		    
		    apt.cid = mma.cid;
		    apt.creation_time = mma.creation_time;
		    try{apt.duration = mma.duration != null ? mma.duration : null;}catch(Exception exDuration){}
		    apt.end_status = mma.end_status;
		    apt.is_appointment = Boolean.valueOf(mma.is_appointment);
		    try{apt.scheduled_start_time = String.valueOf(DateTime.ValueofGmt(mma.scheduled_start_time.replace('T', ' ')));}catch(Exception exSST){}
		    try{apt.start_time = String.valueOf(DateTime.ValueofGmt(mma.start_time.replace('T', ' ')));}catch(Exception exST){}
		    try{apt.provider_type = mma.provider.provider_type;}catch(Exception exProvType){}
		    try{apt.provider_name = mma.provider.user.first_name + ' ' + mma.provider.user.last_name;}catch(Exception exProvName){}
			
			String tempSpokenLanguages = '';
		    try
		    {
		    	if(mma.provider.user.spoken_languages.size()>0)
			    {
			    	for(MemberPsychAppointmentsJSON.cls_spoken_languages soLingo : mma.provider.user.spoken_languages)
			    		tempSpokenLanguages += soLingo.Language + '; ';
			    }
		    }catch(Exception exProvLanguages){}

		    tempSpokenLanguages = tempSpokenLanguages.substringBeforeLast(';');
		    apt.spoken_languages = tempSpokenLanguages;
		    results.add(apt);
		}

    	return results;
    }

    public static MemberPsychAppointmentsJSON getAppointmentsFromJSON(String strEndpoint)
    {
    	MemberPsychAppointmentsJSON theAppointments;

    	String strCSRFToken = Test.isRunningTest() == true ? 'ICbuGGaEBofnq3shi871ruLItx5zt5kB' : DoD_OAuth.getCSRFToken();
		String strBearerToken = Test.isRunningTest() == true ? 'CeW1TsyNdFOZSvZhz2KhlEeYkxf04T' : DoD_OAuth.getBearerToken(strCSRFToken);
		String strAccessToken = 'Bearer token ' + strBearerToken;

    	httpRequest req = new httpRequest();
	    req.setHeader('Accept','application/json');
    	req.setHeader('Cookie', 'csrftoken=' + strCSRFToken);
    	req.setHeader('Authorization', strAccessToken);
	    req.setMethod('GET');

	    httpResponse res;
	    String strStatusCode;
	    try
	    {
	    	req.setEndpoint(strEndpoint);
		    res = new http().send(req);
		    strStatusCode = String.valueOf(res.getStatusCode());

		    if(strStatusCode == '200')
		    {
		    	String strResponseBody = res.getBody();
				theAppointments = (MemberPsychAppointmentsJSON) System.JSON.deserialize(strResponseBody, MemberPsychAppointmentsJSON.class);
		    }
		    
		}
		catch(Exception exMember)
		{
			strStatusCode = String.valueOf(res.getStatusCode());
			SYSTEM.DEBUG('+++++ exMember error: ' + exMember.getMessage());
		}

    	return theAppointments;
    }

	// wrapper or Inner class with @AuraEnabled {get;set;} properties*    
    public class wrapperClass
    {
        @AuraEnabled public List<appointment> lstAppointments{get;set;}
        @AuraEnabled public Integer appointmentCount{get;set;}
        @AuraEnabled public String headerMsg {get;set;}
    }


	public class appointment 
	{
		@AuraEnabled public Integer cid;	//14771
		@AuraEnabled public String creation_time;	//2016-11-05T00:54:13.474387Z
		@AuraEnabled public Integer duration;	//5
		@AuraEnabled public String end_status;	//Normal call end
		@AuraEnabled public boolean is_appointment;
		@AuraEnabled public Integer member_id;	//3255
		//public cls_provider provider;
		@AuraEnabled public String scheduled_start_time;	//2016-11-05T01:15:00Z
		@AuraEnabled public String start_time;
		@AuraEnabled public String provider_type;
		@AuraEnabled public String provider_name;
		@AuraEnabled public String spoken_languages;
	}

	@AuraEnabled
	public static User Agent
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

	/*
	// For now use static resource JSON file
	  	StaticResource sr = [SELECT Id,NamespacePrefix,SystemModstamp FROM StaticResource WHERE Name = 'SampleMemberPsychAppointmentsJSON' LIMIT 1];
	    String prefix = sr.NamespacePrefix;
	    if( String.isEmpty(prefix) ) {prefix = '';} else {prefix += '__';}
	    String srPath = '/resource/' + sr.SystemModstamp.getTime() + '/' + prefix + 'SampleMemberPsychAppointmentsJSON'; 
	    PageReference pg = new PageReference( srPath );
	    String body = pg.getContent().toString();
	*/

    
  	
}