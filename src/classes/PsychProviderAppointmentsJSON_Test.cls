@isTest
private class PsychProviderAppointmentsJSON_Test 
{
	
	
	static testMethod void testParse() 
	{
		String json=		'{'+
		'    "count": 32,'+
		'    "next": "https://demo.doctorondemand.com/api/v1/support/behavioral-health-doctors/2363/appointments/?limit=10&offset=10",'+
		'    "previous": null,'+
		'    "results": ['+
		'        {'+
		'            "id": 770,'+
		'            "creation_time": "2017-01-04T02:35:04.182949Z",'+
		'            "duration": null,'+
		'            "end_status": "Charged appointment cancellation",'+
		'            "is_appointment": true,'+
		'            "member": 6961,'+
		'            "provider": {'+
		'                "provider_type": "psychologist",'+
		'                "user": {'+
		'                    "id": 2363,'+
		'                    "email": "carriebh@test.com",'+
		'                    "first_name": "Carrie",'+
		'                    "last_name": "Ologist",'+
		'                    "middle_name": "",'+
		'                    "prefix": "",'+
		'                    "suffix": "",'+
		'                    "spoken_languages": []'+
		'                }'+
		'            },'+
		'            "scheduled_start_time": null,'+
		'            "start_time": null'+
		'        },'+
		'        {'+
		'            "id": 769,'+
		'            "creation_time": "2016-12-30T18:39:26.733035Z",'+
		'            "duration": null,'+
		'            "end_status": "Charged appointment cancellation",'+
		'            "is_appointment": true,'+
		'            "member": 6961,'+
		'            "provider": {'+
		'                "provider_type": "psychologist",'+
		'                "user": {'+
		'                    "id": 2363,'+
		'                    "email": "carriebh@test.com",'+
		'                    "first_name": "Carrie",'+
		'                    "last_name": "Ologist",'+
		'                    "middle_name": "",'+
		'                    "prefix": "",'+
		'                    "suffix": "",'+
		'                    "spoken_languages": []'+
		'                }'+
		'            },'+
		'            "scheduled_start_time": null,'+
		'            "start_time": null'+
		'        },'+
		'        {'+
		'            "id": 766,'+
		'            "creation_time": "2016-11-05T00:01:39.815367Z",'+
		'            "duration": null,'+
		'            "end_status": "Charged appointment cancellation",'+
		'            "is_appointment": true,'+
		'            "member": 2195,'+
		'            "provider": {'+
		'                "provider_type": "psychologist",'+
		'                "user": {'+
		'                    "id": 2363,'+
		'                    "email": "carriebh@test.com",'+
		'                    "first_name": "Carrie",'+
		'                    "last_name": "Ologist",'+
		'                    "middle_name": "",'+
		'                    "prefix": "",'+
		'                    "suffix": "",'+
		'                    "spoken_languages": []'+
		'                }'+
		'            },'+
		'            "scheduled_start_time": null,'+
		'            "start_time": null'+
		'        },'+
		'        {'+
		'            "id": 396,'+
		'            "creation_time": "2015-12-09T02:52:05.413912Z",'+
		'            "duration": null,'+
		'            "end_status": "Free appointment cancellation",'+
		'            "is_appointment": true,'+
		'            "member": 2962,'+
		'            "provider": {'+
		'                "provider_type": "psychologist",'+
		'                "user": {'+
		'                    "id": 2363,'+
		'                    "email": "carriebh@test.com",'+
		'                    "first_name": "Carrie",'+
		'                    "last_name": "Ologist",'+
		'                    "middle_name": "",'+
		'                    "prefix": "",'+
		'                    "suffix": "",'+
		'                    "spoken_languages": []'+
		'                }'+
		'            },'+
		'            "scheduled_start_time": null,'+
		'            "start_time": null'+
		'        },'+
		'        {'+
		'            "id": 801,'+
		'            "creation_time": "2018-02-15T22:31:20.923863Z",'+
		'            "duration": null,'+
		'            "end_status": "Server appointment cancellation",'+
		'            "is_appointment": true,'+
		'            "member": 7314,'+
		'            "provider": {'+
		'                "provider_type": "psychologist",'+
		'                "user": {'+
		'                    "id": 2363,'+
		'                    "email": "carriebh@test.com",'+
		'                    "first_name": "Carrie",'+
		'                    "last_name": "Ologist",'+
		'                    "middle_name": "",'+
		'                    "prefix": "",'+
		'                    "suffix": "",'+
		'                    "spoken_languages": []'+
		'                }'+
		'            },'+
		'            "scheduled_start_time": null,'+
		'            "start_time": null'+
		'        },'+
		'        {'+
		'            "id": 805,'+
		'            "creation_time": "2018-02-28T22:42:26.813196Z",'+
		'            "duration": null,'+
		'            "end_status": "Provider missed appointment",'+
		'            "is_appointment": true,'+
		'            "member": 3255,'+
		'            "provider": {'+
		'                "provider_type": "psychologist",'+
		'                "user": {'+
		'                    "id": 2363,'+
		'                    "email": "carriebh@test.com",'+
		'                    "first_name": "Carrie",'+
		'                    "last_name": "Ologist",'+
		'                    "middle_name": "",'+
		'                    "prefix": "",'+
		'                    "suffix": "",'+
		'                    "spoken_languages": []'+
		'                }'+
		'            },'+
		'            "scheduled_start_time": "2018-03-03T17:00:00Z",'+
		'            "start_time": null'+
		'        },'+
		'        {'+
		'            "id": 806,'+
		'            "creation_time": "2018-02-28T22:43:36.652134Z",'+
		'            "duration": null,'+
		'            "end_status": "Provider missed appointment",'+
		'            "is_appointment": true,'+
		'            "member": 3255,'+
		'            "provider": {'+
		'                "provider_type": "psychologist",'+
		'                "user": {'+
		'                    "id": 2363,'+
		'                    "email": "carriebh@test.com",'+
		'                    "first_name": "Carrie",'+
		'                    "last_name": "Ologist",'+
		'                    "middle_name": "",'+
		'                    "prefix": "",'+
		'                    "suffix": "",'+
		'                    "spoken_languages": []'+
		'                }'+
		'            },'+
		'            "scheduled_start_time": "2018-02-28T23:00:00Z",'+
		'            "start_time": null'+
		'        },'+
		'        {'+
		'            "id": 804,'+
		'            "creation_time": "2018-02-27T17:57:50.247670Z",'+
		'            "duration": 175,'+
		'            "end_status": "Normal call end",'+
		'            "is_appointment": true,'+
		'            "member": 3255,'+
		'            "provider": {'+
		'                "provider_type": "psychologist",'+
		'                "user": {'+
		'                    "id": 2363,'+
		'                    "email": "carriebh@test.com",'+
		'                    "first_name": "Carrie",'+
		'                    "last_name": "Ologist",'+
		'                    "middle_name": "",'+
		'                    "prefix": "",'+
		'                    "suffix": "",'+
		'                    "spoken_languages": []'+
		'                }'+
		'            },'+
		'            "scheduled_start_time": "2018-02-27T18:00:00Z",'+
		'            "start_time": "2018-02-27T17:59:04.793385Z"'+
		'        },'+
		'        {'+
		'            "id": 802,'+
		'            "creation_time": "2018-02-16T23:43:20.463903Z",'+
		'            "duration": null,'+
		'            "end_status": "Provider missed appointment",'+
		'            "is_appointment": true,'+
		'            "member": 7314,'+
		'            "provider": {'+
		'                "provider_type": "psychologist",'+
		'                "user": {'+
		'                    "id": 2363,'+
		'                    "email": "carriebh@test.com",'+
		'                    "first_name": "Carrie",'+
		'                    "last_name": "Ologist",'+
		'                    "middle_name": "",'+
		'                    "prefix": "",'+
		'                    "suffix": "",'+
		'                    "spoken_languages": []'+
		'                }'+
		'            },'+
		'            "scheduled_start_time": "2018-02-24T17:00:00Z",'+
		'            "start_time": null'+
		'        },'+
		'        {'+
		'            "id": 803,'+
		'            "creation_time": "2018-02-16T23:46:02.360256Z",'+
		'            "duration": null,'+
		'            "end_status": "Provider missed appointment",'+
		'            "is_appointment": true,'+
		'            "member": 3255,'+
		'            "provider": {'+
		'                "provider_type": "psychologist",'+
		'                "user": {'+
		'                    "id": 2363,'+
		'                    "email": "carriebh@test.com",'+
		'                    "first_name": "Carrie",'+
		'                    "last_name": "Ologist",'+
		'                    "middle_name": "",'+
		'                    "prefix": "",'+
		'                    "suffix": "",'+
		'                    "spoken_languages": []'+
		'                }'+
		'            },'+
		'            "scheduled_start_time": "2018-02-17T17:00:00Z",'+
		'            "start_time": null'+
		'        }'+
		'    ]'+
		'}';
		PsychProviderAppointmentsJSON obj = PsychProviderAppointmentsJSON.parse(json);
		System.assert(obj != null);
	}
	
	
}