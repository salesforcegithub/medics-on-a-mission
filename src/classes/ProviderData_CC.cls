public class ProviderData_CC 
{
  @AuraEnabled 
  public static map<String,Object> getProviderData(ID providerID)
  {
  	// David Berman, 15 August 2018
  	
    String strStatusCode = '';
    String strCSRFToken = Test.isRunningTest() == true ? 'ICbuGGaEBofnq3shi871ruLItx5zt5kB' : DoD_OAuth.getCSRFToken();
    String strBearerToken = Test.isRunningTest() == true ? 'CeW1TsyNdFOZSvZhz2KhlEeYkxf04T' : DoD_OAuth.getBearerToken(strCSRFToken);
    String strAccessToken = 'Bearer token ' + strBearerToken;
        

    Contact theContact;
    try{theContact = [SELECT Id, FirstName, LastName, DoD_User_ID__c, Provider_Type__c FROM Contact WHERE Id =: providerID LIMIT 1];}catch(Exception exContact){}

    ProviderDataJSON provDoc;

    String strEndpoint;
    try
    {
        String strMasterLabel = theContact.Provider_Type__c == 'doctor' ? 'Medical Doctor by User ID' : 'Behavioral Health Provider by User ID';
        strEndpoint = [SELECT Endpoint__c FROM DoD_Endpoint__mdt where MasterLabel =: strMasterLabel LIMIT 1].Endpoint__c;
    }catch(Exception exEndpoint){}

    httpRequest req = new httpRequest();
    req.setHeader('Accept','application/json');
    req.setHeader('Cookie', 'csrftoken=' + strCSRFToken);
    req.setHeader('Authorization', strAccessToken);
    req.setMethod('GET');
    strEndpoint = strEndpoint.replace('XXXX', theContact.DoD_User_ID__c) + '?agent_id=' + Agent.EmployeeNumber;
    
 SYSTEM.DEBUG('+++++ strEndpoint: ' + strEndpoint);
    req.setEndpoint(strEndpoint);
    
    httpResponse res;
    try
    {
        res = new http().send(req);
        strStatusCode = String.valueOf(res.getStatusCode());

        if(strStatusCode == '200')
        {
            String strResponseBody2 = res.getBody();
            provDoc = (ProviderDataJSON) System.JSON.deserialize(strResponseBody2, ProviderDataJSON.class);
        }
        
    }
    catch(Exception exprovDoc)
    {
        strStatusCode = String.valueOf(res.getStatusCode());
        SYSTEM.DEBUG('+++++ exMember error: ' + exprovDoc.getMessage());
    }


//SYSTEM.DEBUG('+++++ provDoc: ' + provDoc);

// *********************************************************************   
// ****** Parse JSON data **********************************************
// *********************************************************************
    
    String strUserID = '';
    if(strStatusCode != '200')      strUserID = 'Call-out error code: ' + strStatusCode;
    else
    {
        try{strUserID = String.valueOf(provdoc.user.id);}catch(Exception exProviderUserID){}
    }
    
    String strPKID = '';
    try{strPKID = String.valueOf(provdoc.id);}catch(Exception exPKID){}
    String strAllowAdhoc;
    try{strAllowAdhoc = Boolean.valueOf(provDoc.allow_adhoc) == true ? 'Yes' : 'No/Unknown';}catch(Exception exAllowAdhoc){}
    
    String strAllowSelfSchedule;
    try{strAllowSelfSchedule = Boolean.valueOf(provDoc.allow_self_scheduling) == true ? 'Yes' : 'No/Unknown';}catch(Exception exAllowSelfSched){}
    
    String strAllowProviderSpecificAppointments;
    if(theContact.Provider_Type__c == 'doctor') try{strAllowProviderSpecificAppointments = Boolean.valueOf(provDoc.doctor.allow_provider_specific_appointments) == true ? 'Yes' : 'No/Unkown';}catch(Exception exAllowProvSpecApt){}
    if(theContact.Provider_Type__c != 'doctor') strAllowProviderSpecificAppointments = 'N/A';
    
    String strDegrees = '';
    try{strDegrees = provDoc.degrees;}catch(Exception exDegrees){}
    
    String strSeeOver18;
    try{strSeeOver18 = Boolean.valueOf(provDoc.see_over_18) == true ? 'Yes' : 'No/Unknown';}catch(Exception exSeeOver18){}
    
    String strSeeUnder18;
    try{strSeeUnder18 = Boolean.valueOf(provDoc.see_under_18) == true ? 'Yes' : 'No/Unknown';}catch(Exception exSeeUnder18){}
    
    String strIsPracticeOnly;
    if(theContact.Provider_Type__c == 'doctor') try{strIsPracticeOnly = Boolean.valueOf(provDoc.doctor.is_practice_only) == true ? 'Yes' : 'No/Unknown';}catch(Exception exPractOnly){}
    if(theContact.Provider_Type__c != 'doctor') strIsPracticeOnly = 'N/A';
    
    List<ProviderDataJSON.cls_us_states> listClassUSStates;
    String strUSStates = '';
    try
    {
        listClassUSStates = provDoc.us_states;
        for(ProviderDataJSON.cls_us_states uss : listClassUSStates)
        {
            strUSStates += uss.state + '; ';
        }

        strUSStates = strUSStates.substringBeforeLast(';');
    }
    catch(Exception exUSStates){}

    String strUserEmail;
    try{strUserEmail = provDoc.user.email;}catch(Exception exUserEmail){}

    String strUserFirstName;
    try{strUserFirstName = provdoc.user.first_name;}catch(Exception exUserFirstName){}
    String strProviderID;

    ProviderDataJSON.cls_user usr;
    String strSpokenLanguages = '';
    try
    {
        usr = provDoc.user;
        List<ProviderDataJSON.cls_spoken_languages> listSpokenLanguages = usr.spoken_languages;

        for(ProviderDataJSON.cls_spoken_languages lingo : listSpokenLanguages)
        {
            strSpokenLanguages += lingo.language + '; ';
        }

        strSpokenLanguages = strSpokenLanguages.substringBeforeLast(';');
    }
    catch(Exception exSpokenLanguages){strSpokenLanguages=exSpokenLanguages.getMessage();}

    ProviderDataJSON.cls_doctor doctor;
    String strSpecialties = '';
    try
    {
        doctor = provdoc.doctor;
        List<ProviderDataJSON.cls_specialties> listSpecialties = doctor.specialties;

        for(ProviderDataJSON.cls_specialties spex : listSpecialties)
        {
            strSpecialties += spex.specialty + '; ';
        }

        strSpecialties = strSpecialties.substringBeforeLast(';');
    }
    catch(Exception exDoctor){}

    Map<String, Object> mapProviderData = new Map<String, Object>();
    mapProviderData.put('pk',strPKID);
    mapProviderData.put('User_ID',strUserID);
    try{mapProviderData.put('doctor_group', provdoc.doctor.doctor_group);}catch(Exception exdoc){}
    try{mapProviderData.put('doctor_group', provdoc.psychologist.psychologist_group);}catch(Exception expsycho){}
    try{mapProviderData.put('doctor_group', provdoc.psychiatrist.psychiatrist_group);}catch(Exception exdocpsychi){}
    //else mapProviderData.put('doctor_group', provdoc.psychologist.psychologist_group);
    mapProviderData.put('provider_type',theContact.Provider_Type__c);
    mapProviderData.put('is_practice_only',strIsPracticeOnly);
    mapProviderData.put('allow_adhoc',strAllowAdhoc);
    mapProviderData.put('allow_provider_specific_appointments', strAllowProviderSpecificAppointments);
    mapProviderData.put('allow_self_scheduling',strAllowSelfSchedule);
    mapProviderData.put('degrees',strDegrees);
    mapProviderData.put('see_over_18',strSeeOver18);
    mapProviderData.put('see_under_18', strSeeUnder18);
    mapProviderData.put('us_states',strUSStates);
    mapProviderData.put('email', strUserEmail);
    mapProviderData.put('spoken_languages', strSpokenLanguages);
    mapProviderData.put('specialties', strSpecialties);

    return mapProviderData;


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
    StaticResource sr = [SELECT Id,NamespacePrefix,SystemModstamp FROM StaticResource WHERE Name = 'SampleProviderResponseJSON' LIMIT 1];
    String prefix = sr.NamespacePrefix;
    if( String.isEmpty(prefix) ) {prefix = '';} else {prefix += '__';}
    String srPath = '/resource/' + sr.SystemModstamp.getTime() + '/' + prefix + 'SampleProviderResponseJSON'; 
    PageReference pg = new PageReference( srPath );
    String body = pg.getContent().toString();
    */
  /*try
    {
        listClassDegrees = provDoc.degrees;
        for(ProviderDoctor.cls_degrees deg : listClassDegrees)
        {
            strDegrees += deg.degree + '; ';
        }
 
        strDegrees = strDegrees.substringBeforeLast(';');

    }catch(Exception exDegrees){}
    */



}