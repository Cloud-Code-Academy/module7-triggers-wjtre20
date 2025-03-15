trigger OpportunityTrigger on Opportunity (before update, before delete) {
    switch on Trigger.operationType{
        when BEFORE_UPDATE{
            Set<Id> accountIds = new Set<Id>();
            Map<Id, Id> accountIdToContactId = new Map<Id, Id>();

            for(Opportunity opportunityRecord : Trigger.new){
                accountIds.add(opportunityRecord.AccountId);
            }
            for(Account accountRecord : [SELECT Id, (SELECT Id FROM Contacts WHERE Title = 'CEO' LIMIT 1) FROM Account WHERE Id IN :accountIds]){
                accountIdToContactId.put(accountRecord.Id, accountRecord.Contacts[0].Id);
            }
            for(Opportunity opportunityRecord : Trigger.new){
                if(opportunityRecord.Amount <= 5000){
                    opportunityRecord.addError('Opportunity amount must be greater than 5000');
                }
                opportunityRecord.Primary_Contact__c = accountIdToContactId.get(opportunityRecord.AccountId);
            }

        }
        when BEFORE_DELETE{
            Set<Id> accountIds = new Set<Id>();
            Map<Id, String> accountIdToIndustry = new Map<Id, String>();

            for(Opportunity opportunityRecord : Trigger.old){
                accountIds.add(opportunityRecord.AccountId);
            }
            for(Account accountRecord : [SELECT Id, Industry FROM Account WHERE Id IN :accountIds]){
                accountIdToIndustry.put(accountRecord.Id, accountRecord.Industry);
            }
            for(Opportunity opportunityRecord : Trigger.old){
                if(accountIdToIndustry.get(opportunityRecord.AccountId) == 'Banking' && opportunityRecord.StageName == 'Closed Won'){
                    opportunityRecord.addError('Cannot delete closed opportunity for a banking account that is won');
                }
            }
        }
    }
}