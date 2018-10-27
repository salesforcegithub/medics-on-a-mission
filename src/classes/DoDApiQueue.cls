public class DoDApiQueue implements Queueable, Database.AllowsCallouts {
  @testVisible private integer recLimit = getRecCalloutLimit(); // limit of api call outs
  @testVisible private list<DoD_API_Staging__c> pendingRecords;
  @testVisible private list<DoD_API_Staging__c> updateStagingRec;
  @testVisible private set<Id> exclusionRecords;
  @testVisible private set<Id> successIds;
  @testVisible private set<Id> successAccountIds;
  @testVisible private list<String> errorLog;
  /*  
  **
  */
  public DoDApiQueue() {
    this(null,null,null, null, null);

  }
  /*  
  **
  */
  public DoDApiQueue(set<Id> inExclusionRecords, list<DoD_API_Staging__c> workingList, List<String> errors, set<Id> inSuccess, set<Id> inSuccessAccounts) {
    this.exclusionRecords = inExclusionRecords != null ? inExclusionRecords : new set<Id>();
    this.pendingRecords = workingList != null ? workingList : DoDApiStagingHelper.getPendingDoDRecords(recLimit, exclusionRecords);
    this.errorLog = errors != null ? errors : new list<String>();
    this.successIds = inSuccess != null ? inSuccess : new set<Id>();
    this.successAccountIds = inSuccessAccounts != null ? inSuccessAccounts : new set<Id>();
  }
  /*  
  **
  */
  public void execute(QueueableContext context) {   
    map<String,Object> responseMap;
    boolean isSuccessful = true;
    Id excludeId;
    String errorString;
    updateStagingRec = new list<DoD_API_Staging__c>();
    for (DoD_API_Staging__c currentStaging : pendingRecords) {
      responseMap = DoDApiStagingHelper.processDoDAPIRecord(currentStaging);
      if(responseMap != null && responseMap.containsKey('success')){
        currentStaging = (DoD_API_Staging__c) responseMap.get('record');
        this.successAccountIds.add(currentStaging.Record_Id__c);
        updateStagingRec.add(currentStaging);
        this.successIds.add(currentStaging.Id);
      } else {
        excludeId = currentStaging.Record_Id__c;
        if (responseMap.containsKey('errors')) {
          errorString = JSON.serialize(responseMap.get('errors'));
        } 
        isSuccessful = false;
        break;
      } 
    }
    //update updateAccounts;
    if (!Test.isRunningTest()) {
      update updateStagingRec;
    }
    if(!isSuccessful){
      // unable to complete
      this.exclusionRecords.add(excludeId);
      if(!String.isBlank(errorString)){
        errorLog.add(excludeId + ' ' + errorString);
      }
    }
    

    this.pendingRecords = DoDApiStagingHelper.getPendingDoDRecords(recLimit, exclusionRecords); 
    if (!pendingRecords.isEmpty() && !Test.isRunningTest()) {
      queueAgain();
    } else {
      // save the exclusion and any errors?
      map<String,Object> queueResults = new map<String,Object>{
        'jobId' => context.getJobId(),
        'exclusions' => this.exclusionRecords,
        'error log' => this.errorLog,
        'success staging Rec' => this.successIds,
        'success account' => this.successAccountIds
      };
      insert new System_Log__c(
        Result__c = JSON.serialize(queueResults),
        Success_Count__c = this.successIds.size(),
        Fail_Count__c = this.exclusionRecords.size()
      );
    }


  }

  /*  
  **
  */
  private static Integer getRecCalloutLimit(){
    return Limits.getLimitCallouts() - Limits.getCallouts();
  }
  /*  
  **
  */
  private void queueAgain(){
    DoDApiQueue thisQueue = new DoDApiQueue(this.exclusionRecords, this.pendingRecords, this.errorLog, this.successIds, this.successAccountIds);
    System.enqueueJob(thisQueue);
  }
}