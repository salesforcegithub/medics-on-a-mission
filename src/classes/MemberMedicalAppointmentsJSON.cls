public class MemberMedicalAppointmentsJSON
{
	@AuraEnabled public Integer count;	//4
	@AuraEnabled public List<cls_results> results;
	

	public class cls_results 
	{
		@AuraEnabled public Integer id;	//14771
		@AuraEnabled public Integer cid;
		@AuraEnabled public String creation_time;	//2016-11-05T00:54:13.474387Z
		@AuraEnabled public Integer duration;	//5
		@AuraEnabled public String end_status;	//Normal call end
		@AuraEnabled public boolean is_appointment;
		@AuraEnabled public cls_member member;	//3255
		@AuraEnabled public cls_provider provider;
		@AuraEnabled public String scheduled_start_time;	//2016-11-05T01:15:00Z
		@AuraEnabled public String start_time;	//2016-11-05T01:16:35.418480Z
	}

	public class cls_provider 
	{
		@AuraEnabled public String provider_type;	//medical
		@AuraEnabled public cls_user user;
	}

	public class cls_member
	{
		@AuraEnabled public Integer id;
		@AuraEnabled public cls_user user;
	}
	
	public class cls_user 
	{
		@AuraEnabled public Integer id;	//5098
		@AuraEnabled public String email;	//kgriffin+doc@doctorondemand.com
		@AuraEnabled public String first_name;	//Kent
		@AuraEnabled public String last_name;	//Griffin
		@AuraEnabled public String middle_name;	//
		@AuraEnabled public String prefix;	//
		@AuraEnabled public String suffix;	//
		@AuraEnabled public cls_spoken_languages[] spoken_languages;
	}

	public class cls_spoken_languages 
	{
		@AuraEnabled public String language;	//English
	}

	@AuraEnabled
	public static MemberMedicalAppointmentsJSON parse(String json)
	{
		return (MemberMedicalAppointmentsJSON) System.JSON.deserialize(json, MemberMedicalAppointmentsJSON.class);
	}

}