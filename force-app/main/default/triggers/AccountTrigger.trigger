trigger AccountTrigger on Account (before insert, after insert) {
    switch on Trigger.operationType{
        when BEFORE_INSERT{
            for(Account accountRecord : Trigger.new){
                if(accountRecord.Type == null){
                    accountRecord.Type = 'Prospect';
                }
                if(!String.isEmpty(accountRecord.ShippingStreet)){
                    accountRecord.BillingStreet = accountRecord.ShippingStreet;
                }
                if(!String.isEmpty(accountRecord.ShippingCity)){
                    accountRecord.BillingCity = accountRecord.ShippingCity;
                }
                if(!String.isEmpty(accountRecord.ShippingState)){
                    accountRecord.BillingState = accountRecord.ShippingState;
                }
                if(!String.isEmpty(accountRecord.ShippingPostalCode)){
                    accountRecord.BillingPostalCode = accountRecord.ShippingPostalCode;
                }
                if(!String.isEmpty(accountRecord.ShippingCountry)){
                    accountRecord.BillingCountry = accountRecord.ShippingCountry;
                }
                if(!String.isEmpty(accountRecord.Phone) && !String.isEmpty(accountRecord.Website) && !String.isEmpty(accountRecord.Fax)){
                    accountRecord.Rating = 'Hot';
                }
            }

        }
        when AFTER_INSERT{
            List<Contact> newContacts = new List<Contact>();
            for(Account accountRecord : Trigger.new){
                newContacts.add(new Contact(
                        AccountId = accountRecord.Id,
                        LastName = 'DefaultContact',
                        Email = 'default@email.com'
                    )
                );
            }
            insert newContacts;
        }
    }

}