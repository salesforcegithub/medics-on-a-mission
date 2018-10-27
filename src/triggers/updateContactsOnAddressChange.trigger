trigger updateContactsOnAddressChange on Account
                                         (before update) {

    // The map allows us to keep track of the accounts that have  
    
    // new addresses  
    
    Map<Id, Account> acctsWithNewAddresses = new Map<Id, Account>();

    // Trigger.new is a list of the Accounts that will be updated  
    
    // This loop iterates over the list, and adds any that have new  
    
    // addresses to the acctsWithNewAddresses map.  
    
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        if (   (Trigger.old[i].ShippingCity != Trigger.new[i].
                                                 ShippingCity)
            || (Trigger.old[i].ShippingCountry != Trigger.new[i].
                                                 ShippingCountry)
            || (Trigger.old[i].ShippingPostalCode != Trigger.new[i].
                                                 ShippingPostalCode)
            || (Trigger.old[i].ShippingState != Trigger.new[i].
                                                 ShippingState)
            || (Trigger.old[i].ShippingStreet != Trigger.new[i].
                                                ShippingStreet))  {
            acctsWithNewAddresses.put(Trigger.old[i].id,
                                      Trigger.new[i]);
        }
    }

    List<Contact> updatedContacts = new List<Contact>();

    //Here we can see two syntatic features of Apex:  
    
    //  1) iterating over an embedded SOQL query  
    
    //  2) binding an array directly to a SOQL query with 'in'  
    

    for (Contact c : [SELECT id, accountId, MailingCity,
                             MailingCountry, MailingPostalCode,
                             MailingState, MailingStreet
                      FROM contact
                      WHERE accountId 
                            in :acctsWithNewAddresses.keySet()]) {
        Account parentAccount = acctsWithNewAddresses.get(c.accountId);
        c.MailingCity = parentAccount.ShippingCity;
        c.MailingCountry = parentAccount.ShippingCountry;
        c.MailingPostalCode = parentAccount.ShippingPostalCode;
        c.MailingState = parentAccount.ShippingState;
        c.MailingStreet = parentAccount.ShippingStreet;

        // Rather than insert the contacts individually, add the  
    
        // contacts to a list and bulk insert it. This makes the  
    
        // trigger run faster and allows us to avoid hitting the  
    
        // governor limit on DML statements  
    
        updatedContacts.add(c);
    }
    update updatedContacts;
}