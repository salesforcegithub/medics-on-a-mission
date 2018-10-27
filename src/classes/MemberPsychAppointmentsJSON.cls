public class MemberPsychAppointmentsJSON
{
	@AuraEnabled public Integer count;	//3
	@AuraEnabled public List<cls_results> results;
	
	public class cls_results 
	{
		@AuraEnabled public Integer cid;	//805
		@AuraEnabled public String creation_time;	//2018-02-28T22:42:26.813196Z
		@AuraEnabled public Integer duration;
		@AuraEnabled public String end_status;	//Provider missed appointment
		@AuraEnabled public boolean is_appointment;
		@AuraEnabled public cls_member member;	//3255
		@AuraEnabled public cls_provider provider;
		@AuraEnabled public String scheduled_start_time;	//2018-03-03T17:00:00Z
		@AuraEnabled public String start_time;
	}

	
	public class cls_provider 
	{
		@AuraEnabled public String provider_type;	//psychologist
		@AuraEnabled public cls_user user;
	}

	public class cls_member
	{
		@AuraEnabled public Integer id;
		@AuraEnabled public cls_user user;
	}

	public class cls_user 
	{
		@AuraEnabled public Integer id;	//2363
		@AuraEnabled public String email;	//carriebh@test.com
		@AuraEnabled public String first_name;	//Carrie
		@AuraEnabled public String last_name;	//Ologist
		@AuraEnabled public String middle_name;	//
		@AuraEnabled public String prefix;	//
		@AuraEnabled public String suffix;	//
		@AuraEnabled public cls_spoken_languages[] spoken_languages;
	}

	public class cls_spoken_languages 
	{
		@AuraEnabled public String language;
	}

	
	@AuraEnabled public static MemberPsychAppointmentsJSON parse(String json)
	{
		return (MemberPsychAppointmentsJSON) System.JSON.deserialize(json, MemberPsychAppointmentsJSON.class);
	}

	
}