public class DoDMember extends DoDCore {
  public MemberUser user {get;private set;}
  public MemberAddress address {get;private set;}
  
  public String phone_number {
    get {return (String) get('phone_number');}
    set { put('phone_number', value);}
  }
  // returns the account object fields which are updatable to DoD Db
  public static set<String> getTrackedFields(){
    return memberTrackedFieldMap.keySet();
  }
  /* maping of account object fields to DoD DB fields for member 
    object inside the member object are indicated by a [obj_name];[field_name] 
  */
  private static map<String,String> memberTrackedFieldMap = new map<String,String>{
    'Email__c' => 'user;email',
    'Date_of_Birth__c' => 'user;dob',
    'Gender__c' => 'user;gender',
    'Member_First_Name__c' => 'user;first_name',
    'Member_Middle_Name__c' => 'user;middle_name',
    'Member_Last_Name__c' => 'user;last_name',
    'Phone' => 'phone_number',
    'BillingStreet' => 'address;street',
    'BillingCity' => 'address;locality',
    'BillingState' => 'address;state',
    'BillingPostalCode' => 'address;postal_code',
    'BillingCountry' => 'address;country'
  };
  // construct DoDMember object based on the stagingRecord
  public DoDMember(DoDApiStagingHelper.StagingRecord stagedRecord){
    for (DoDApiStagingHelper.Changes thisChange : stagedRecord.changeList) {
      if (!memberTrackedFieldMap.containsKey(thisChange.field_name)) {
        continue;
      }
      String dodMapping = memberTrackedFieldMap.get(thisChange.field_name);
      list<String> fieldList = dodMapping.split(';');
      
      if (fieldList.size() == 1) {
        this.put(fieldList[0], thisChange.new_value);
      } else if ('user'.equals(fieldList[0])) { 
        // fields belongs on the user object
        this.user = this.user != null ? this.user : new MemberUser();
        if('dob'.equals(fieldList[1])){
          // special formating expected for dob field
          Datetime dt = Datetime.valueOf(thisChange.new_value);
          this.user.put(fieldList[1], dt.format('YYYY-MM-dd'));
        } else {
          this.user.put(fieldList[1], thisChange.new_value);
        }
        
      } else if ('address'.equals(fieldList[0])) { 
        // fields belongs on the address object
        this.address = this.address != null ? this.address : new MemberAddress();
        if(!'street'.equals(fieldList[1])){
          this.address.put(fieldList[1], thisChange.new_value);
        } else {
          // street is stored as a single field in sf but two seperate fields in dod.  split sf field to extract second+ lines 
          if (!thisChange.new_value.contains('\r\n') && !thisChange.new_value.contains('\n')) {
            this.address.put('street', thisChange.new_value);
          } else if (thisChange.new_value.contains('\r\n')) {
            list<String> splitList = thisChange.new_value.split('\r\n');
            this.address.put('street', splitList.remove(0));
            this.address.put('extended', string.join(splitList,','));
          } else {
            list<String> splitList = thisChange.new_value.split('\n');
            this.address.put('street', splitList.remove(0));
            this.address.put('extended', string.join(splitList,','));
          }
        }
      }
    }
    // system.debug('SelfPrint: ' + this);
  }

  public class MemberUser extends DoDCore{
    public String first_name {
      get {return (String) get('first_name');}
      set { put('first_name', value);}
    }
    public String middle_name {
      get {return (String) get('middle_name');}
      set { put('middle_name', value);}
    }
    public String last_name {
      get {return (String) get('last_name');}
      set { put('last_name', value);}
    }
    public String email {
      get {return (String) get('email');}
      set { put('email', value);}
    }
    public String dob {
      get {return (String) get('dob');}
      set { put('dob', value);}
    }
    public String gender {
      get {return (String) get('gender');}
      set { put('gender', value);}
    }
  }
  public class MemberAddress extends DoDCore{ 
    public String street {
      get {return (String) get('street');}
      set { put('street', value);}
    }
    public String extended {
      get {return (String) get('extended');}
      set { put('extended', value);}
    }
    public String locality {
      get {return (String) get('locality');}
      set { put('locality', value);}
    }
    public String state {
      get {return (String) get('state');}
      set { put('state', value);}
    }
    public String postal_code {
      get {return (String) get('postal_code');}
      set { put('postal_code', value);}
    }
    public String country {
      get {return (String) get('country');}
      set { put('country', value);}
    }
  }

}