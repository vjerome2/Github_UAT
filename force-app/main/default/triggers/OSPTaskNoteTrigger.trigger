trigger OSPTaskNoteTrigger on Order (before update){

    // List<Order> oldOrders = [SELECT Id, Fiber_Design_Complete_FDE__c, Splice_Documents_Received__c , OSP_Engineer__c, OSP_Engineer__r.Name, Site_Survey_Scheduled__c, Site_Survey_Complete__c, OSP_DEsign_Received__c, OSP_Design_Revised__c, DOT_Permit_needed__c, Leased_Conduit_Permit_Needed__c, Railroad_Permit_Needed__c, Underground_Permit_Needed__c, Aerial_Perrmit_Needed__c, Contractor__c, Contractor__r.Name, Construction_Status__c, As_Built_Uploaded_OSP__c, As_Built_Not_Needed_OSP__c, OSP_DEsign_Imported__c, As_Built_Imported_GIS__c, Splice_Documents_Imported__c, As_Built_Rejection__c
    //                          FROM Order
    //                          WHERE Id IN:Trigger.oldMap.keySet()];

    for (Order oldOrder : Trigger.old){
    // for (Order oldOrder : oldOrders){
        Order newOrder = Trigger.newMap.get(oldOrder.Id);
        if (Disabled_Triggers__c.getValues('OSPTaskNoteTrigger') == null || Disabled_Triggers__c.getValues('OSPTaskNoteTrigger').Disabled__c == false){

            //*OSPTaskNOtes
            if (oldOrder != null){
                String lastComment = OspTaskNote.createOSPTaskNote(newOrder, oldOrder);
                if (Test.isRunningTest() || lastComment != NULL){
                    newOrder.Last_Order_Comment__c = lastComment;
                    newOrder.Last_Order_Comment_Date__c = System.today();
                }
            }
        }
    }
}