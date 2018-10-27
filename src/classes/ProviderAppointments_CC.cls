public with sharing class ProviderAppointments_CC 
{
	@AuraEnabled
	public static wrapperClass initMethod(ID recordID)
    {
        wrapperClass returnwrapperClass = new wrapperClass();        
        returnwrapperClass.lstAppointments = new List<appointment>();

		Contact theProvider;
		Case theCase;
		try{theProvider = [SELECT Id, FirstName, LastName, DoD_User_ID__c, Provider_Type__c FROM Contact WHERE Id =: recordID LIMIT 1];}catch(Exception exProvider){}
SYSTEM.DEBUG('+++++ theProvider: ' + theProvider);
		
		String strEndpoint;

		try
		{
			String strMasterLabel = theProvider.Provider_Type__c == 'Medical' ? 'Medical Provider Appointments' : 'Behavioral Health Provider Appointments';
			strEndpoint = [SELECT Endpoint__c FROM DoD_Endpoint__mdt where MasterLabel =: strMasterLabel LIMIT 1].Endpoint__c;
		}
		catch(Exception exEndpoint){}
SYSTEM.DEBUG('+++++ strEndpoint: ' + strEndpoint);

	    strEndpoint = strEndpoint.replace('XXXX', theProvider.Dod_User_ID__c);
	    
	    String pastAppointments = strEndpoint  + '?limit=10&agent_id='+Agent.EmployeeNumber;
	    String futureAppointments = strEndpoint + '?scheduled=true&limit=5&agent_id='+Agent.EmployeeNumber;

	    ProviderAppointmentsJSON thePastAppointments = getAppointmentsFromJSON(pastAppointments);
		ProviderAppointmentsJSON theFutureAppointments = getAppointmentsFromJSON(futureAppointments);

		returnwrapperClass.lstAppointments = assembleAppointments(returnwrapperClass.lstAppointments, theFutureAppointments);
		returnwrapperClass.lstAppointments = assembleAppointments(returnwrapperClass.lstAppointments, thePastAppointments);
	   
		
  SYSTEM.DEBUG('++++++ returnwrapperClass.lstAppointments: ' + returnwrapperClass.lstAppointments);
        returnwrapperClass.appointmentCount = returnwrapperClass.lstAppointments.size(); 
        returnwrapperClass.headerMsg = 'Appointments';
        
       return returnwrapperClass;    
    }

    public static List<appointment> assembleAppointments(List<appointment> results, ProviderAppointmentsJSON inputResults)
    {
    	for(ProviderAppointmentsJSON.cls_results prov_apt : inputResults.results)
		{
//	SYSTEM.DEBUG('+++++ mma; ' + mma.cid + ' / ' + mma.member);
		    appointment apt = new appointment();
		    apt.cid = prov_apt.id;
		    apt.creation_time = String.valueOf(DateTime.ValueofGmt(prov_apt.creation_time.replace('T', ' ').replace('Z','')));
		    apt.duration = prov_apt.duration;
		    apt.end_status = prov_apt.end_status;
		    apt.is_appointment = Boolean.valueOf(prov_apt.is_appointment);
		    apt.member_id = prov_apt.member.id;
		    apt.member_name = prov_apt.member.user.first_name + ' ' + prov_apt.member.user.last_name;
		    try{apt.scheduled_start_time = String.valueOf(DateTime.ValueofGmt(prov_apt.scheduled_start_time.replace('T', ' ')));}catch(Exception exSST){}
		    try{apt.start_time = String.valueOf(DateTime.ValueofGmt(prov_apt.start_time.replace('T', ' ')));}catch(Exception exST){}
		    apt.provider_name = prov_apt.provider.user.first_name + ' ' + prov_apt.provider.user.last_name;
		    
		    String tempSpokenLanguages = '';
		    if(prov_apt.provider.user.spoken_languages.size()>0)
		    {
		    	for(ProviderAppointmentsJSON.cls_spoken_languages soLingo : prov_apt.provider.user.spoken_languages)
		    		tempSpokenLanguages += soLingo.Language + '; ';
		    }

		    tempSpokenLanguages = tempSpokenLanguages.substringBeforeLast(';');
		    apt.spoken_languages = tempSpokenLanguages;
		    

		    results.add(apt);
		}

    	return results;
    }


    public static ProviderAppointmentsJSON getAppointmentsFromJSON(String strEndpoint)
    {
    	ProviderAppointmentsJSON theAppointments;

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
				theAppointments = (ProviderAppointmentsJSON) System.JSON.deserialize(strResponseBody, ProviderAppointmentsJSON.class);
		    }
		    
		}
		catch(Exception exProvider)
		{
			strStatusCode = String.valueOf(res.getStatusCode());
			SYSTEM.DEBUG('+++++ exProvider error: ' + exProvider.getMessage());
		}

    	return theAppointments;
    }


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
		@AuraEnabled public String member_name;
		//public cls_provider provider;
		@AuraEnabled public String scheduled_start_time;	//2016-11-05T01:15:00Z
		@AuraEnabled public String start_time;
		@AuraEnabled public String provider_name;
		@AuraEnabled public String provider_phone;
		@AuraEnabled public String spoken_languages;
		@AuraEnabled public String future_past;
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

	     // For now use static resource JSON file
	  	/*
	  	StaticResource sr = [SELECT Id,NamespacePrefix,SystemModstamp FROM StaticResource WHERE Name = 'SampleMemberMedicalAppointmentsJSON' LIMIT 1];
	    String prefix = sr.NamespacePrefix;
	    if( String.isEmpty(prefix) ) {prefix = '';} else {prefix += '__';}
	    String srPath = '/resource/' + sr.SystemModstamp.getTime() + '/' + prefix + 'SampleMemberMedicalAppointmentsJSON'; 
	    PageReference pg = new PageReference( srPath );
	    String body = pg.getContent().toString();
		*/

	    //ProviderAppointmentsJSON MMAJ = (ProviderAppointmentsJSON) System.JSON.deserialize(body, ProviderAppointmentsJSON.class);
		
}