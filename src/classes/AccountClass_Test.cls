@isTest
private class AccountClass_Test 
{
	
	static Testmethod void test_member_account_insert() 
	{
		Account acc = new Account();
		acc.Name = 'Test Member Account 01';
		acc.Type = 'Member';

		Test.startTest();
		insert acc;
		Test.stopTest();
	}
	
	static Testmethod void test_member_account_update() 
	{
        Account testMemberAccount = new Account();
        
		testMemberAccount.Name 					= 'Test Member Account 02';
        testMemberAccount.Type 					= 'Member';
        testMemberAccount.Custodials__c 		= 'Marina Oswald';
  		testMemberAccount.Custodians__c 		= 'June Lee; Audrey Marina Rachel';
		testMemberAccount.Phone 				= '2145557777';
		testMemberAccount.Email__c 				= 'lho@marx4life.test';
		testMemberAccount.Member_First_Name__c 	= 'Lee';
		testMemberAccount.Member_Middle_Name__c = 'Harvey';
		testMemberAccount.Member_Last_Name__c  	= 'Oswald';
		testMemberAccount.BillingStreet 		= '411 Elm St';
		testMemberAccount.BillingCity 			= 'Dallas';
		testMemberAccount.BillingState 			= 'TX';
		testMemberAccount.BillingPostalCode 	= '75202';
		testMemberAccount.BillingCountry 		= 'USA';
        
        insert testMemberAccount;
        
        Contact testMemberContact = new Contact();  
		
        testMemberContact.AccountId = testMemberAccount.Id;
        testMemberContact.FirstName = 'Lee';
        testMemberContact.LastName 	= 'Oswald';
        
        insert testMemberContact;
        
        Test.startTest();
        
        List<Account> memberAccount = [SELECT Id, Phone, Email__c, Member_First_Name__c,
                                       Member_Middle_Name__c, Member_Last_Name__c, 
                                       BillingStreet, BillingCity, BillingState, 
                                       BillingPostalCode, BillingCountry
                                       FROM Account
                                       WHERE Id = : testMemberAccount.Id
                                       LIMIT 1];
        
        for (Account a : memberAccount) {
            
            a.Phone 				= '2145557777';
            a.Member_First_Name__c 	= 'John';
            a.Member_Middle_Name__c = 'Wilkes';
            a.Member_Last_Name__c  	= 'Booth';
            a.BillingStreet 		= '511 10th St NW';
            a.BillingCity 			= 'Washington';
            a.BillingState 			= 'DC';
            a.BillingPostalCode 	= '20004';
            a.BillingCountry 		= 'USA';
            
        }       
        
        update memberAccount;      
		
        Test.stopTest();
        
        /* for (Contact c : [SELECT Id, AccountId, Phone, DoD_Email__c, 
                     Member_First_Name__c, Member_Middle_Name__c, Member_Last_Name__c, 
                     MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
                     FROM Contact
                     WHERE AccountId = : memberAccount.Id
                     LIMIT 1]) {
                              
                              System.assertEquals(c.Phone, 					memberAccount.Phone);                              
                         	  System.assertEquals(c.Member_First_Name__c, 	memberAccount.Member_First_Name__c);
                         	  System.assertEquals(c.Member_Middle_Name__c, 	memberAccount.Member_Middle_Name__c);
                         	  System.assertEquals(c.Member_Last_Name__c, 	memberAccount.Member_Last_Name__c);
                         	  System.assertEquals(c.MailingStreet, 			memberAccount.BillingStreet);
                         	  System.assertEquals(c.MailingCity, 			memberAccount.BillingCity);
                         	  System.assertEquals(c.MailingState, 			memberAccount.BillingState);
                         	  System.assertEquals(c.MailingPostalCode, 		memberAccount.BillingPostalCode);
                              System.assertEquals(c.MailingCountry, 		memberAccount.BillingCountry);
                         
					} */
                              
                    
                              
    }
        
	
}