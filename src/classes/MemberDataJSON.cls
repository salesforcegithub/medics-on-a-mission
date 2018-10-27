public with sharing class MemberDataJSON 
{

	public Integer id;	//1
	public boolean blacklisted;
	public List<cls_custodians> custodians;
	public String employer;	
	public cls_insurance insurance;
	public boolean is_custodial;
	public String last_login;	//2018-04-09T17:00:13.537908Z
	public String last_location;
	public String phone_number;	//555-867-5309
	public cls_user user;
	public cls_address address;

	public class cls_custodians 
	{
		public Integer id;	//1
		public String first_name;	//Sam
		public String last_name;	//Lowry
	}

	public class cls_insurance 
	{
		public boolean active;
		public String group_id;	//Group ID#1
		public String insurance_member_id;	//Insurance member ID#1
		public String payer;	//Employer Payer
	}

	public class cls_user 
	{
		public Integer id;
		public String email;
		public String first_name;	//Sam
		public String last_name;	//Lowry
		public String middle_name;	//
		public String prefix;	//
		public String suffix;	//
		public List<String> spoken_languages;
	}

	
	public class cls_address
	{
		public String street; // "street": "275 Battery St.",
		public String extended;	//  "extended": "Suite 650",
		public String locality;	// "locality": "San Francisco",
		public String state;	// "state": "CA",
		public String postal_code; // "postal_code": "94111",
		public String country;	// "country": "US"

	}
	

	public static MemberDataJSON parse(String json)
	{
		return (MemberDataJSON) System.JSON.deserialize(json, MemberDataJSON.class);
	}

}