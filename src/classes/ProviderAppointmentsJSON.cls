public with sharing class ProviderAppointmentsJSON 
{
	@AuraEnabled public Integer count;	//1
	@AuraEnabled public cls_results[] results;
	
	public class cls_results 
	{
		@AuraEnabled public Integer id;	//14974
		@AuraEnabled public String creation_time;	//2018-06-20T01:48:05.545617Z
		@AuraEnabled public Integer duration;	//29
		@AuraEnabled public String end_status;	//Normal call end
		@AuraEnabled public boolean is_appointment;
		@AuraEnabled public cls_provider provider;
		@AuraEnabled public cls_member member;
		@AuraEnabled public String scheduled_start_time;
		@AuraEnabled public String start_time;	//2018-06-20T01:48:22.452321Z
	}

	public class cls_member 
	{
		@AuraEnabled public Integer id;	//7444
		@AuraEnabled public cls_user user;
	}

	public class cls_provider 
	{
		@AuraEnabled public String provider_type;	//medical
		@AuraEnabled public cls_user user;
	}

	public class cls_user 
	{
		@AuraEnabled public Integer id;	//7637
		@AuraEnabled public String email;	//glangton+labs.doc@doctorondemand.com
		@AuraEnabled public String first_name;	//Timothy
		@AuraEnabled public String last_name;	//Schmidt
		@AuraEnabled public String middle_name;	//
		@AuraEnabled public String prefix;	//
		@AuraEnabled public String suffix;	//
		@AuraEnabled public cls_spoken_languages[] spoken_languages;
	}

	public class cls_spoken_languages 
	{
		@AuraEnabled public String language;	//English
	}


	@AuraEnabled public static ProviderAppointmentsJSON parse(String json)
	{
		return (ProviderAppointmentsJSON) System.JSON.deserialize(json, ProviderAppointmentsJSON.class);
	}
}