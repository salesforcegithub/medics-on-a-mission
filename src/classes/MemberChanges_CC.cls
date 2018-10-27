public class MemberChanges_CC {
  /* return the account record based on the provided record id.  A contact Id will return the associated account while an account id
    will return the specific account 
  */
  @AuraEnabled 
  public static Account getMemberAccountData(Id recordId) {
    Account requestedAccount;
    Id accountId;
    if(recordId == null){
      return null;
    }
    if (Contact.sObjectType ==  recordId.getsobjecttype()) {
      for (Contact currentContact : [select AccountId from Contact where Id= :recordId]) {
        accountId = currentContact.AccountId;
        break;
      }
    } else if (Account.sObjectType == recordId.getsobjecttype()) {
      accountId = recordId;
    }
    if (accountId == null) {
      return null;
    }

    for (Account currentAccount : [select Id, Member_First_Name__c, Member_Middle_Name__c, Member_Last_Name__c, Phone, Email__c, Date_of_Birth__c, Gender__c, DoD_User_ID__c, 
    BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account where Id = :accountId]) {
      requestedAccount = currentAccount;
      break;
    }
    if (requestedAccount == null) {
      return null;
    }
    // system.debug('Account : ' + requestedAccount);
    return requestedAccount;
  }
  /* update the account record and return success or errors. this is being handled by dod api
  */
  // @AuraEnabled 
  // public static map<String,Object> updateSFRecord(Account updateAccount) {
  //   try{
  //     if (updateAccount.BillingStreet != null && updateAccount.BillingStreet.contains('\r\n')){
        
  //       String tempString = updateAccount.BillingStreet.unescapeEcmaScript();
  //       // system.debug('replacememnt b - ' + tempString);
  //       // // updateAccount.BillingStreet = String.join(updateAccount.BillingStreet.split('\r\n'),'\\u0x0D\\u0x0A');
  //       // list<String> tempList = tempString.split('\\\\r\\\\n');
  //       // tempString = tempList[0] + '\r\n' + tempList[1];
  //       // tempString = tempString.replaceAll('(\\r|\\n)+', '&#124;');
  //       // tempString = tempString.normalizeSpace();
  //       // tempString = tempString.replaceAll('&#124;', '\"\r\n\"');
  //       updateAccount.BillingStreet = tempString;
  //       system.debug('replacememnt - ' + tempString);
  //     }
  //     Account tempAccount = new Account(
  //       Id = updateAccount.Id,
  //       BillingStreet = '8636 Stehline appt 1'
  //     );
  //     system.debug('replacememnt tempaccount - ' + tempAccount);
  //     // String accountSerialString = JSON.serialize(updateAccount);
  //     // system.debug('accountSerialString ' + accountSerialString);
  //     // updateAccount = (Account)JSON.deserialize(accountSerialString, Account.class);
  //     //update tempAccount;
  //     return new map<String,Object>{'success' => 'update successful'};
  //   } catch(exception e){
  //     return new map<String,Object>{'errors' => e.getmessage()};
  //   }
  // }
  /* pass the updated account record as well as the original account to the DoDApi to attempt an update to the dod DB
  */
  @AuraEnabled 
  public static map<String,Object> updateMemberAccount(Account updateAccount) { 
    if (updateAccount == null) {
      return new map<String,Object>{'errors' => 'current account error'};
    }
    list<Account> oldAccountList = [select Member_First_Name__c, Member_Middle_Name__c, Member_Last_Name__c, Phone, Email__c, Date_of_Birth__c, Gender__c, DoD_User_ID__c, 
    BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account where Id = :updateAccount.Id];
    if (oldAccountList.isEmpty()) {
      return new map<String,Object>{'errors' => 'old account error'};
    }
    Account oldAccount = oldAccountList[0];
    map<String,Object> returnMap = DoDApiStagingHelper.updatesMemberFields(updateAccount, oldAccount);
    return returnMap;

  }
   
}