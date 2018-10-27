@isTest
private class DoDApiStagingTest {

  static testMethod void DoDApiQueueScheduler() {
    DoDApiQueueScheduler.JOB_NAME = 'Test Job';
    Test.startTest();
    DoDApiQueueScheduler.ScheduleMe();
    Test.stopTest();
    ApexClass apiQueueClass = [select Id, Name from ApexClass where Name = 'DoDApiQueueScheduler'];
    list<AsyncApexJob> apexJob = [select Id, JobType, ApexClassId, Status from AsyncApexJob where ApexClassId = :apiQueueClass.Id];
    // test that jobs have been scheduled
    system.assert(!apexJob.isEmpty());
  }
  static testMethod void DoDApiQueue() {
    
    Test.startTest();        
    System.enqueueJob(new DoDApiQueue());
    Test.stopTest();
    list<System_Log__c> logList = [select id from System_Log__c];
    system.assert(!logList.isEmpty());
  }
  static testMethod void DoDApiQueueWithStagingRecords() {
    
    DoD_API_Staging__c testStaging = (DoD_API_Staging__c)JSON.deserialize(
      '{"Status__c" : "' + DoDApiStagingHelper.PENDING_STATUS + '",' +
      ' "CreatedBy" : {"EmployeeNumber" : "1234"}, ' + 
      ' "DoD_User_ID__c" : "0001", ' + 
      ' "Record_Id__c" : "001K000001TgsmDIAR", ' + 
      ' "Changes__c" : "[{\\"field_name\\":\\"FirstName\\",\\"old_value\\":\\"BoB\\",\\"new_value\\":\\"Bobby\\"}]" ' + 
      ' }',DoD_API_Staging__c.class
    );

    DoDApiStagingHelper.CSRF_TOKEN = 'csrf token';
    DoDApiStagingHelper.BEARER_TOKEN = 'bear token';
    Test.setMock(HttpCalloutMock.class, new DoDApiMock()); 

    
    Test.startTest();
    DoDApiQueue apiQueue = new DoDApiQueue(null, new list<DoD_API_Staging__c>{testStaging}, null, null, null);    
    System.enqueueJob(apiQueue);
    Test.stopTest();
    list<System_Log__c> logList = [select id from System_Log__c];
    system.assert(!logList.isEmpty());
  }
  static testMethod void DoDApiQueueWithStagingRecords400() {
    
    DoD_API_Staging__c testStaging = (DoD_API_Staging__c)JSON.deserialize(
      '{"Status__c" : "' + DoDApiStagingHelper.PENDING_STATUS + '",' +
      ' "CreatedBy" : {"EmployeeNumber" : "1234"}, ' + 
      ' "DoD_User_ID__c" : "0001", ' + 
      ' "Record_Id__c" : "001K000001TgsmDIAR", ' + 
      ' "Changes__c" : "[{\\"field_name\\":\\"FirstName\\",\\"old_value\\":\\"BoB\\",\\"new_value\\":\\"Bobby\\"}]" ' + 
      ' }',DoD_API_Staging__c.class
    );

    DoDApiStagingHelper.CSRF_TOKEN = 'csrf token';
    DoDApiStagingHelper.BEARER_TOKEN = 'bear token';
    Test.setMock(HttpCalloutMock.class, new DoDApiMock(400)); 

    
    Test.startTest();
    DoDApiQueue apiQueue = new DoDApiQueue(null, new list<DoD_API_Staging__c>{testStaging}, null, null, null);    
    System.enqueueJob(apiQueue);
    Test.stopTest();
    list<System_Log__c> logList = [select id from System_Log__c];
    system.assert(!logList.isEmpty());
  }


  @testSetup static void setupTestData() { }
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