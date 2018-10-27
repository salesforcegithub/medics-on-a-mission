@isTest
private class MedicalProviderAppointmentsJSON_Test 
{
	
	static testMethod void testParse() 
	{
		String json=		'{'+
		'    "count": 1,'+
		'    "next": null,'+
		'    "previous": null,'+
		'    "results": ['+
		'        {'+
		'            "id": 14974,'+
		'            "creation_time": "2018-06-20T01:48:05.545617Z",'+
		'            "duration": 29,'+
		'            "end_status": "Normal call end",'+
		'            "is_appointment": false,'+
		'            "member": 7397,'+
		'            "provider": {'+
		'                "provider_type": "medical",'+
		'                "user": {'+
		'                    "id": 7637,'+
		'                    "email": "glangton+labs.doc@doctorondemand.com",'+
		'                    "first_name": "Timothy",'+
		'                    "last_name": "Schmidt",'+
		'                    "middle_name": "",'+
		'                    "prefix": "",'+
		'                    "suffix": "",'+
		'                    "spoken_languages": ['+
		'                        {'+
		'                            "language": "English"'+
		'                        },'+
		'                        {'+
		'                            "language": "Mandarin"'+
		'                        }'+
		'                    ]'+
		'                }'+
		'            },'+
		'            "scheduled_start_time": null,'+
		'            "start_time": "2018-06-20T01:48:22.452321Z"'+
		'        }'+
		'    ]'+
		'}';
		MedicalProviderAppointmentsJSON obj = MedicalProviderAppointmentsJSON.parse(json);
		System.assert(obj != null);
	}
	
}