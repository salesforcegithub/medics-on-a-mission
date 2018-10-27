@isTest
private class MemberChanges_Test {

  static testMethod void getAccount() {
    Account testAccount = new Account(
      Name = 'testAccount',
      Member_First_Name__c = 'bob', 
      Member_Middle_Name__c = 'timmy', 
      Member_Last_Name__c = 'smith', 
      Phone = '916-555-2134', 
      Email__c = 'b@me.com', 
      Date_of_Birth__c = Date.newinstance(2012,2,16), 
      Gender__c = 'M', 
      DoD_User_ID__c = '0001',
      Type = 'Member', 
      BillingStreet = '123 street', 
      BillingCity = 'west view', 
      BillingState = 'co', 
      BillingPostalCode = '67543', 
      BillingCountry = 'us'
    );
    insert testAccount;
    // Contact testContact = new Contact(LastName = 'smith', AccountId = testAccount.Id);
    Contact testContact = [Select Id, AccountId from Contact where AccountId = :testAccount.Id];
    // insert testContact;
    Note testNote = new Note(Title = 'mock id', ParentId = testAccount.Id);
    insert testNote;
    Test.startTest();
    // null record id
    Account returnAccount = MemberChanges_CC.getMemberAccountData(null);
    system.assert(returnAccount == null);
    // return same account
    returnAccount = MemberChanges_CC.getMemberAccountData(testAccount.Id);
    system.assert(returnAccount != null);
    system.assert(returnAccount.Id == testAccount.Id);
    // return account related to contact
    returnAccount = MemberChanges_CC.getMemberAccountData(testContact.Id);
    system.assert(returnAccount != null);
    system.assert(returnAccount.Id == testContact.AccountId);
    // return null
    returnAccount = MemberChanges_CC.getMemberAccountData(testNote.Id);
    system.assert(returnAccount == null);
    Test.stopTest();      
  }
  static testMethod void updateAccount() {
    Account testAccount = new Account(
      Name = 'testAccount',
      Member_First_Name__c = 'bob', 
      Member_Middle_Name__c = 'timmy', 
      Member_Last_Name__c = 'smith', 
      Phone = '916-555-2134', 
      Email__c = 'b@me.com', 
      Date_of_Birth__c = Date.newinstance(2012,2,16), 
      Gender__c = 'M', 
      DoD_User_ID__c = '0001',
      Type = 'Member', 
      BillingStreet = '123 street', 
      BillingCity = 'west view', 
      BillingState = 'co', 
      BillingPostalCode = '67543', 
      BillingCountry = 'us'
    );
    insert testAccount;
    Account testBadAccount = new Account();
    Test.startTest();
    // null errors
    map<String,Object> returnMap = MemberChanges_CC.updateMemberAccount(null);
    system.assert(returnMap.containsKey('errors'));
    system.assert('current account error'.equals(returnMap.get('errors')));
    // return errors
    returnMap = MemberChanges_CC.updateMemberAccount(testBadAccount);
    system.assert(returnMap.containsKey('errors'));
    system.assert('old account error'.equals(returnMap.get('errors')));

    // return missing dod user id
    testAccount.DoD_User_ID__c = '';
    returnMap = MemberChanges_CC.updateMemberAccount(testAccount);
    system.assert(returnMap.containsKey('errors'));
    system.assert('missing dod user id'.equals(returnMap.get('errors')));
    
    // return missing employeeNumber
    DoDApiStagingHelper.MOCK_USER = new User();
    testAccount.DoD_User_ID__c = '0001';
    returnMap = MemberChanges_CC.updateMemberAccount(testAccount);
    system.assert(returnMap.containsKey('errors'));
    system.assert('missing agent id on user record'.equals(returnMap.get('errors')));
    
    // return no changes
    DoDApiStagingHelper.MOCK_USER = new User(EmployeeNumber = '001');
    returnMap = MemberChanges_CC.updateMemberAccount(testAccount);
    system.assert(returnMap.containsKey('errors'));
    system.assert('no field changes'.equals(returnMap.get('errors')));
    
    // return no changes
    Test.setMock(HttpCalloutMock.class, new DoDApiMock());
    DoDApiStagingHelper.CSRF_TOKEN = 'csrf token';
    DoDApiStagingHelper.BEARER_TOKEN = 'bear token';

    testAccount.Member_First_Name__c = 'bobby';
    testAccount.Member_Last_Name__c = 'doe';
    testAccount.BillingStreet = '123 street\r\nappt 4';
    testAccount.BillingPostalCode = '76541';
    returnMap = MemberChanges_CC.updateMemberAccount(testAccount);
    system.debug('*** returnMap ' + returnMap);
    system.assert(returnMap.containsKey('success'));
    DoD_API_Staging__c stagingRecord = (DoD_API_Staging__c)returnMap.get('stagingrecord');
    system.assert(DoDApiStagingHelper.COMPLETE_STATUS.equals(stagingRecord.Status__c));

    Test.stopTest();      
  }
  static testMethod void updateAccountPending() {
    Account testAccount = new Account(
      Name = 'testAccount',
      Member_First_Name__c = 'bob', 
      Member_Middle_Name__c = 'timmy', 
      Member_Last_Name__c = 'smith', 
      Phone = '916-555-2134', 
      Email__c = 'b@me.com', 
      Date_of_Birth__c = Date.newinstance(2012,2,16), 
      Gender__c = 'M', 
      DoD_User_ID__c = '0001',
      Type = 'Member', 
      BillingStreet = '123 street', 
      BillingCity = 'west view', 
      BillingState = 'co', 
      BillingPostalCode = '67543', 
      BillingCountry = 'us'
    );
    insert testAccount;
    
    Test.startTest();
    
    DoDApiStagingHelper.MOCK_USER = new User(EmployeeNumber = '001');
    Test.setMock(HttpCalloutMock.class, new DoDApiMock(404));
    DoDApiStagingHelper.CSRF_TOKEN = 'csrf token';
    DoDApiStagingHelper.BEARER_TOKEN = 'bear token';

    testAccount.Member_First_Name__c = 'bobby';
    testAccount.Member_Last_Name__c = 'doe';
    testAccount.BillingStreet = '123 street';
    testAccount.BillingPostalCode = '76541';
    map<String,Object> returnMap = MemberChanges_CC.updateMemberAccount(testAccount);
    system.debug('*** returnMap ' + returnMap);
    system.assert(returnMap.containsKey('pending'));
    DoD_API_Staging__c stagingRecord = (DoD_API_Staging__c)returnMap.get('stagingrecord');
    system.assert(DoDApiStagingHelper.PENDING_STATUS.equals(stagingRecord.Status__c));

    Test.stopTest();      
  }
  static testMethod void updateAccountErrors() {
    Account testAccount = new Account(
      Name = 'testAccount',
      Member_First_Name__c = 'bob', 
      Member_Middle_Name__c = 'timmy', 
      Member_Last_Name__c = 'smith', 
      Phone = '916-555-2134', 
      Email__c = 'b@me.com', 
      Date_of_Birth__c = Date.newinstance(2012,2,16), 
      Gender__c = 'M', 
      DoD_User_ID__c = '0001',
      Type = 'Member', 
      BillingStreet = '123 street', 
      BillingCity = 'west view', 
      BillingState = 'co', 
      BillingPostalCode = '67543', 
      BillingCountry = 'us'
    );
    insert testAccount;
    
    Test.startTest();
    
    DoDApiStagingHelper.MOCK_USER = new User(EmployeeNumber = '001');
    Test.setMock(HttpCalloutMock.class, new DoDApiMock(400));
    DoDApiStagingHelper.CSRF_TOKEN = 'csrf token';
    DoDApiStagingHelper.BEARER_TOKEN = 'bear token';

    testAccount.Member_First_Name__c = 'bobby';
    testAccount.Member_Last_Name__c = 'doe';
    testAccount.BillingStreet = '123 street';
    testAccount.BillingPostalCode = '76541';
    map<String,Object> returnMap = MemberChanges_CC.updateMemberAccount(testAccount);
    system.debug('*** returnMap ' + returnMap);
    system.assert(returnMap.containsKey('errors'));

    Test.stopTest();      
  }
  static testMethod void updateAccountExistingPending() {
    Account testAccount = new Account(
      Name = 'testAccount',
      Member_First_Name__c = 'bob', 
      Member_Middle_Name__c = 'timmy', 
      Member_Last_Name__c = 'smith', 
      Phone = '916-555-2134', 
      Email__c = 'b@me.com', 
      Date_of_Birth__c = Date.newinstance(2012,2,16), 
      Gender__c = 'M', 
      DoD_User_ID__c = '0001',
      Type = 'Member', 
      BillingStreet = '123 street', 
      BillingCity = 'west view', 
      BillingState = 'co', 
      BillingPostalCode = '67543', 
      BillingCountry = 'us'
    );
    insert testAccount;
    insert new DoD_API_Staging__c(
      Status__c = DoDApiStagingHelper.PENDING_STATUS,
      Record_Id__c = testAccount.Id
    );
    Test.startTest();
    
    DoDApiStagingHelper.MOCK_USER = new User(EmployeeNumber = '001');
    Test.setMock(HttpCalloutMock.class, new DoDApiMock(400));
    DoDApiStagingHelper.CSRF_TOKEN = 'csrf token';
    DoDApiStagingHelper.BEARER_TOKEN = 'bear token';

    testAccount.Member_First_Name__c = 'bobby';
    testAccount.Member_Last_Name__c = 'doe';
    testAccount.BillingStreet = '123 street';
    testAccount.BillingPostalCode = '76541';
    map<String,Object> returnMap = MemberChanges_CC.updateMemberAccount(testAccount);
    system.debug('*** returnMap ' + returnMap);
    system.assert(returnMap.containsKey('pending'));
    DoD_API_Staging__c stagingRecord = (DoD_API_Staging__c)returnMap.get('stagingrecord');
    system.assert(DoDApiStagingHelper.PENDING_STATUS.equals(stagingRecord.Status__c));

    Test.stopTest();      
  }




  @testSetup static void setupTestData() {
    Profile pf = [Select Id from profile where Name = 'Standard User']; 
    String orgId = UserInfo.getOrganizationId(); 
    String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
    Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
    String uniqueName = orgId + dateString + randomId; 
    User bt = new User(
      firstname = 'Bob', 
      lastName = 'Test', 
      email = uniqueName + '.' + orgId + '@example.com', 
      Username = uniqueName + '.' + orgId + '@example.com', 
      EmailEncodingKey = 'ISO-8859-1', 
      Alias = uniqueName.substring(18, 23), 
      TimeZoneSidKey = 'America/Los_Angeles', 
      LocaleSidKey = 'en_US', 
      LanguageLocaleKey = 'en_US', 
      ProfileId = pf.Id,
      isActive = true
    ); 
    insert bt;
        // Test.setMock(HttpCalloutMock.class, new DoDApiMock()); 
        // DoDApiQueue apiQueue = new DoDApiQueue(null, new list<DoD_API_Staging__c>{testStaging}, null, null, null);    
    // System.enqueueJob(apiQueue);
  }
  public class DoDApiMock implements HttpCalloutMock {
    private Integer response;
    public DoDApiMock() {
      this.response = 200;
    }
    public DoDApiMock(Integer respCode) {
      this.response = respCode;
    }
    public HTTPResponse respond(HTTPRequest req) {
    // Optionally, only send a mock response for a specific endpoint
        // and method.
        // System.assertEquals('http://example.com/example/test', req.getEndpoint());
        // System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{}');
        // res.setBody('{"example":"test","access_token": "' + OAUTH_TOKEN
        // + '","refresh_token": "'+ REFRESH_TOKEN + '","first_name": "' + FIRST_NAME
        // + '","id": ' + LOGIN_ID + ',"email": "' + EMAIL_ADDRESS + 
        //  '"}');
        res.setStatusCode(this.response);
        return res;
    }

  }
}