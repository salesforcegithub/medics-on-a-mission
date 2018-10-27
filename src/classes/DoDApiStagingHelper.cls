public class DoDApiStagingHelper {
  public static final string PENDING_STATUS = 'Pending';
  public static final string COMPLETE_STATUS = 'Complete';
  @testVisible private static String CSRF_TOKEN; // to allow testing mock
  @testVisible private static String BEARER_TOKEN; // to allow testing mock
  @testVisible private static User MOCK_USER; // to allow testing mock
  /* returns list of pending staging records ordered by createddate (oldest first).   
  */
  public static list<DoD_API_Staging__c> getPendingDoDRecords(Integer recLimit, set<Id> exclusionRecords){
    return [select Changes__c, Record_Id__c, DoD_User_ID__c, Status__c, createdby.EmployeeNumber, createdbyid from DoD_API_Staging__c where Status__c = :PENDING_STATUS AND Record_Id__c not in : exclusionRecords order by createddate asc limit :recLimit];
  }
  /* Count the number of pending staging records associated with the provided record id
  ** 
  */
  public static Integer getPendingDoDRecordCount(Id recordId){
    List<AggregateResult> result = [select count(Id) recCnt from DoD_API_Staging__c where Status__c = :PENDING_STATUS AND Record_Id__c = :recordId];
    return (Integer) result[0].get('recCnt');
  }
  /* Attempt to send the staging record to DoD Database.  If API returns a success then the staging record is set to complete status
  ** 
  */
  public static map<String,Object> processDoDAPIRecord(DoD_API_Staging__c apiRec){
    if(apiRec == null){
      return null;
    }
    StagingRecord stagingRecord = new StagingRecord(apiRec);
    if(stagingRecord == null){
      return new map<String,Object>{'errors' => 'unable to create stagingrecord'};
    }
    String agentId = apiRec.createdby.EmployeeNumber;
    if(agentId == null){
      return new map<String,Object>{'errors' => 'Missing agent Id for user ' + apiRec.createdbyid};
    }
    DoDMember updateMemberRecord = new DoDMember(stagingRecord);
    map<String,Object> returnMap = quickSendToApi(stagingRecord.dodUserId, agentId, updateMemberRecord);
    system.debug('returnMap ' + returnMap);
    if (returnMap.containsKey('success')) {
      // add to staging table as complete
      stagingRecord.setComplete();
      DoD_API_Staging__c currentStaging = stagingRecord.buildAPIStagingRecord();
      //update currentStaging;
      return new map<String,Object>{
        'success' => 'updates complete ' + currentStaging.Id,
        'record' => currentStaging
      };
    } else {
      return new map<String,Object>{'errors' => returnMap.containsKey('body') ? returnMap.get('body') : returnMap.get('errors')};
    }

  }
  /* Returns account with fields updated to match the tracked field changes on the staging record.
  ** // Handled by DoD Api update to account upon change
  */
  // public static Account getUpdatedAccount(DoD_API_Staging__c apiRec){
  //   if (apiRec == null) {
  //     return null;
  //   }
  //   StagingRecord stagingRecord = new StagingRecord(apiRec);
  //   if (stagingRecord == null) {
  //     return null;
  //   }
  //   Account currentAccount = createAccountRecord(stagingRecord);

  //   return currentAccount;
  // }
  /* Checks if there are changes to tracked DoD fields.  If there are changes and no currently pending updates for the record then 
  ** updates will be pushed to DoD api.  If there are pending chnages then the updates will be saved to a staging record for scheduled job to pick up and send.
  ** 
  */
  public static map<String,Object> updatesMemberFields(Account currentAccount, Account oldAccount) {
    String memberUserId = currentAccount != null ? currentAccount.DoD_User_ID__c : null;
    if (String.isBlank(memberUserId)) {
      return new map<String,Object>{'errors' => 'missing dod user id'};
    }
    User currentUser = (
      MOCK_USER != null ? MOCK_USER : 
      [select Id, EmployeeNumber from User where id = :UserInfo.getUserId()]
    );
    String agentId = currentUser.EmployeeNumber;
    if (String.isBlank(agentId)) {
      return new map<String,Object>{'errors' => 'missing agent id on user record'};
    }
    StagingRecord stagingRecord = createStagingRecord(currentAccount, oldAccount);
    if (stagingRecord == null) {
      return new map<String,Object>{'errors' => 'no field changes'};
    }
    DoDMember updateMemberRecord = new DoDMember(stagingRecord);
    // if there isnt pending records (for member?) and api is up then try to quick send
    Integer pendingCnt = getPendingDoDRecordCount(currentAccount.Id);
    map<String,Object> returnMap;
    
    if(pendingCnt == 0){
     returnMap = quickSendToApi(stagingRecord.dodUserId, agentId, updateMemberRecord);
    } else {
      returnMap = new map<String,Object>{'pending' => 'pending'};
    }
    system.debug('returnMap ' + returnMap);
    if (returnMap.containsKey('success')) {
      // add to staging table as complete
      stagingRecord.setComplete();
      DoD_API_Staging__c newStaging = stagingRecord.buildAPIStagingRecord();
      insert newStaging;
      DoD_API_Staging__c tempRec = [select Id, Name from DoD_API_Staging__c where Id = :newStaging.Id];
      return new map<String,Object>{
        'success' => 'updates complete ' + tempRec.Name + ', ID -' + newStaging.Id,
        'stagingrecord' => newStaging
      };
    } else if (returnMap.containsKey('errors') && 'API_DOWN'.equals(returnMap.get('errorsType'))) {
      // add changes to staging table to queue for push
      DoD_API_Staging__c newStaging = stagingRecord.buildAPIStagingRecord();
      insert newStaging;
      DoD_API_Staging__c tempRec = [select Id, Name from DoD_API_Staging__c where Id = :newStaging.Id];
      return new map<String,Object>{
        'pending' => 'updates incomplete, added to queue ' + tempRec.Name + ', ID -' + newStaging.Id,
        'stagingrecord' => newStaging};
    } else if (returnMap.containsKey('pending')) {
      // add changes to staging table to queue for push
      DoD_API_Staging__c newStaging = stagingRecord.buildAPIStagingRecord();
      insert newStaging;
      DoD_API_Staging__c tempRec = [select Id, Name from DoD_API_Staging__c where Id = :newStaging.Id];
      return new map<String,Object>{
        'pending' => 'changes pending for member, updates added to queue ' + tempRec.Name + ', ID -' + newStaging.Id,
        'stagingrecord' => newStaging
      };
    } else {
      return new map<String,Object>{'errors' => returnMap.containsKey('body') ? returnMap.get('body') : returnMap.get('errors')};
    }
    
  }
  // Handled by DoD Api update to account upon change
  // private static Account createAccountRecord(StagingRecord stagingRecord) {
  //   if (stagingRecord == null) {
  //     return null;
  //   }
  //   list<Changes> fieldChanges = stagingRecord.changeList;
  //   if (fieldChanges.isEmpty()) {
  //     return null;
  //   }
  //   String accountSerialString = '{';
  //   String pairString = '"{0}" : "{1}",';
  //   for (Changes thisChange : fieldChanges) {
  //     if('Date_of_Birth__c'.equals(thisChange.field_name) && thisChange.new_value != null){
  //       string fixFormat = thisChange.new_value.subString(0,10).escapeJava();
  //       accountSerialString += String.format(pairString, new list<String>{thisChange.field_name, fixFormat});
  //     } else {
  //       accountSerialString += String.format(pairString, new list<String>{thisChange.field_name, thisChange.new_value != null ? thisChange.new_value.escapeJava() : ''});
  //     }
      
  //   }
  //   accountSerialString += '"Id" : "' + stagingRecord.recordId + '"}';
  //   system.debug('accountSerialString ' + accountSerialString);
  //   return (Account)JSON.deserialize(accountSerialString, Account.class);
  // }
  
  
  private static StagingRecord createStagingRecord(Account currentAccount, Account oldAccount) {
    if(currentAccount == null || oldAccount == null){
      return null;
    }
    String dodUserId = currentAccount.DoD_User_ID__c;
    Id recordId = currentAccount.Id;
    // loop through fields we care about and if they have changed then create changes and then staging record
    list<Changes> fieldChanges = new list<Changes>();
    Boolean changedAddressField = false;
    set<String> addedField = new set<String>();
    for (String fieldName : DoDMember.getTrackedFields()) {
      String oldValue = JSON.serialize(oldAccount.get(fieldName));
      //system.debug('oldValue: ' + oldValue);
      String newValue = JSON.serialize(currentAccount.get(fieldName));
      //system.debug('newValue: ' + newValue);
      if ((oldValue == null && newValue != null) || (oldValue != null && newValue == null) || 
      ((oldValue != null && newValue != null) && (!oldValue.equals(newValue)))) {
        oldValue = String.valueOf(oldAccount.get(fieldName));
        newValue = String.valueOf(currentAccount.get(fieldName));
        fieldChanges.add(new Changes(fieldName, oldValue, newValue));
      }
    }

    if (!fieldChanges.isEmpty()) {
      return new StagingRecord(recordId, dodUserId, fieldChanges);
    }
    return null;
      
  }
  
  public class StagingRecord { 
    public Id recordId {get;private set;} 
    public Id myId {get;private set;} 
    public String dodUserId {get;private set;} 
    public String status {get;private set;} 
    public list<Changes> changeList {get;private set;} 
    public StagingRecord(Id recordId, String dodUserId, list<Changes> changeList){
      this.recordId = recordId;
      this.myId = null;
      this.dodUserId = dodUserId;
      this.changeList = changeList;
      this.status = PENDING_STATUS;
      
    }
    
    public StagingRecord (DoD_API_Staging__c stagingRecord) {
      this.recordId = stagingRecord.Record_Id__c;
      this.myId = stagingRecord.Id;
      this.dodUserId = stagingRecord.DoD_User_ID__c;
      try{
        this.changeList = (list<Changes>)JSON.deserialize(stagingRecord.Changes__c, list<Changes>.class);
      } catch (exception e){
        this.changeList = new list<Changes>();
      }
      this.status = stagingRecord.Status__c;
    }
    public void setComplete(){
      this.status = COMPLETE_STATUS;
    }
    public DoD_API_Staging__c buildAPIStagingRecord () {
      if (this.dodUserId == null || this.recordId == null || this.changeList == null || this.changeList.isEmpty()){
        return null;
      }
      return new DoD_API_Staging__c(
        Changes__c = JSON.serialize(this.changeList),
        Record_Id__c = this.recordId,
        Id = this.myId,
        DoD_User_ID__c = this.dodUserId,
        Status__c = this.status
      );
    }
  }
  public class Changes {
    public String field_name {get;private set;}
    public String old_value {get;private set;}
    public String new_value {get;private set;}
    public Changes (String fieldNameSF, String oldValue, String newValue) {
      this.field_name = fieldNameSF;
      this.old_value = oldValue;
      this.new_value = newValue;
    }
  }
  private static map<String,Object> quickSendToApi(String memberUserId, String agentId, DoDMember updateMemberRecord){
    String method = 'POST';
    String host = label.DoD_Host;
    String path = String.format(label.DoD_Member_Update_Path, new list<String>{memberUserId, agentId});
    String dodMemberString = JSON.serialize(updateMemberRecord, true);
    system.debug('body ' + dodMemberString);
    String strCRSFToken = CSRF_TOKEN != null ? CSRF_TOKEN : DoD_OAuth.getCSRFToken();
    map<String,String> headerMap = new map<String,String>{
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
      'Authorization' => 'Bearer token ' + (BEARER_TOKEN != null ? BEARER_TOKEN : DoD_OAuth.getBearerToken(strCRSFToken)),
      'Cookie' => 'csrftoken=' + strCRSFToken
    };
    map<String,Object> returnMap = apiCallout(method, host, path, headerMap, dodMemberString);
    system.debug('returnMap ' + returnMap);
    return returnMap;
  }
  private static map<String,Object> apiCallout(String method, String host, String path, map<String,String> headerMap, String bodyString){
    map<String,Object> returnMap;
    HttpRequest req = new HttpRequest();
    req.setEndpoint( host + path );
    req.setMethod(method);
    for(String headerName: headerMap.keySet()) {
      req.setHeader(headerName, headerMap.get(headerName));
    }
    if (String.isNotBlank(bodyString)) {
      req.setBody(bodyString);
    }
    try {
      Http http = new Http();
      HttpResponse response = http.send(req);
      if (response.getStatusCode() == 400 ) {
        // bad request
        system.debug('Status ' + response.getStatusCode());
        system.debug('errorBody ' + response.getBody());
        return new map<String,Object>{
          'errors' => 'Error: status code ' + response.getStatusCode() + ' : ' + response.getBody(),
          'body' => (map<String,Object>)JSON.deserializeUntyped(response.getBody())
        };
      } else if (response.getStatusCode() == 200 ) {
        // success
        system.debug('Status ' + response.getStatusCode() + ' : ' + response.getBody());
        return new map<String,Object>{
          'success' => 'success',
          'body' => (map<String,Object>)JSON.deserializeUntyped(response.getBody())
        };
      } else {
        // api down
        system.debug('Status ' + response.getStatusCode());
        system.debug('errorBody ' + response.getBody());
        return new map<String,String>{
          'errors' => 'Error: status code ' + response.getStatusCode() + ' : ' + response.getBody(),
          'errorsType'=> 'API_DOWN'
        };
      }
    } catch( System.Exception e) {
      system.debug('ERROR: '+ e);
      return new map<String,Object>{
        'errors' => 'Error: system exception ' + e,
        'errorsType'=> 'API_DOWN'
      };
    }
  } 
}