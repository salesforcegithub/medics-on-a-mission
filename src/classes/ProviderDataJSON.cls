public with sharing class ProviderDataJSON
{
	@AuraEnabled public Integer id;	//139
	@AuraEnabled public boolean allow_adhoc;
	@AuraEnabled public boolean allow_self_scheduling;
	@AuraEnabled public String degrees;
	@AuraEnabled public boolean see_over_18;
	@AuraEnabled public boolean see_under_18;
	@AuraEnabled public List<cls_us_states> us_states;
	@AuraEnabled public cls_user user;
	@AuraEnabled public cls_doctor doctor;
	@AuraEnabled public cls_psychologist psychologist;
	@AuraEnabled public cls_psychiatrist psychiatrist;
	
	
	public class cls_us_states 
	{
		@AuraEnabled public String state;	//CA
	}

	public class cls_user 
	{
		@AuraEnabled public Integer id;	//7614
		@AuraEnabled public String email;	//amorgan+mdemo@doctorondemand.com
		@AuraEnabled public String first_name;	//RogerDEMO
		@AuraEnabled public String last_name;	//Iliff
		@AuraEnabled public String middle_name;	//
		@AuraEnabled public String prefix;	//
		@AuraEnabled public String suffix;	//
		@AuraEnabled public List<cls_spoken_languages> spoken_languages;
	}

	public class cls_spoken_languages 
	{
		@AuraEnabled public String language;	//English
	}

	public class cls_doctor 
	{
		@AuraEnabled public String doctor_group;
		@AuraEnabled public boolean allow_after_hours_calls;
		@AuraEnabled public boolean allow_provider_specific_appointments;
		@AuraEnabled public boolean is_practice_only;
		@AuraEnabled public List<cls_specialties> specialties;
	}

	public class cls_psychologist
	{
		@AuraEnabled public String psychologist_group;
	}

	public class cls_psychiatrist
	{
		@AuraEnabled public String psychiatrist_group;
	}


	public class cls_specialties 
	{
		@AuraEnabled public String specialty;	//Allergy and Immunology
	}

	@AuraEnabled public static ProviderDataJSON parse(String json)
	{
		return (ProviderDataJSON) System.JSON.deserialize(json, ProviderDataJSON.class);
	}


	
}