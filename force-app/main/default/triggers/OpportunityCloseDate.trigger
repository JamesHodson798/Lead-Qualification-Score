trigger OpportunityCloseDate on Opportunity (before insert, before update) {
    
    // Get Account IDs from opportunties
    Set<Id> accountsId = new Set<Id>();
    for (Opportunity opp : Trigger.new){
        if(opp.AccountId != null){
            accountsId.add(opp.AccountId);
        }
    }
    
    // Query for converted leads associated to the accounts
    Map<Id, Lead> accountToLeadMap = new Map<Id, Lead>();
    for(Lead lead: [SELECT id, CreatedDate, ConvertedAccountId
                   	FROM Lead
                   	WHERE ConvertedAccountId IN :accountsId
                    AND IsConverted = true]){
                        accountToLeadMap.put(lead.ConvertedAccountId, lead);
                    }
	
    // Validate Opportunities
    for (Opportunity opp : Trigger.new){
        if (opp.AccountId != null && accountToLeadMap.containsKey(opp.AccountId)){
            Lead convertedLead = accountToLeadMap.get(opp.AccountId);
            if (opp.CloseDate < convertedLead.CreatedDate.addDays(7)){
                opp.addError('Opportunity Close Date is at least 7 days after the Lead CreatedDate.');
            }
        }
    }
}