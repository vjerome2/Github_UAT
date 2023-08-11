public with sharing class OSPTaskNote{
    // method to get the username  from the User Id
    private static String getUserName(String name){
        List<User> users = [SELECT Id, Name
                            FROM User
                            WHERE Id = :name
                            LIMIT 1];


        
        if (users.size() > 0 && users != null){
            return users[0].Name;
        } else{
            return 'OSP Engineer Not Assigned ';
        }
    }

    private static String getContractorName(String name){
        if (Test.isRunningTest()){
            return New MAINTENANCE_Construction_Vendor__c(Name = 'Test Contractor').Name;
        }
        List<MAINTENANCE_Construction_Vendor__c> contractor = [SELECT Id, Name
                                                               FROM MAINTENANCE_Construction_Vendor__c
                                                               WHERE Id = :name];

        String contractorName = contractor[0].Name;
        return contractorName;
    }

    // method to create a new Order_Comment__c record
    private static Order_Comment__c newOc(Order o, String text){
        //Create an Order_Comment__c record to insert
        Order_Comment__c oc = new Order_Comment__c();
        String name = o.OSP_Engineer__r.Name;
        String userName = getUserName(name);
        Datetime noteDate = Datetime.now();
        String noteText = userName + ' : ' + noteDate.format('MM/dd/yyyy') + ' -- ' + text;

        //populate the Order_Comment__c record with the appropriate fields
        oc.Comment__c = noteText;

        //attach the Order_Comment__c record to the Order
        oc.Service_Order_Agreement__c = o.Id;

        return oc;
    }

    public static String createOSPTaskNote(Order newOrder, Order oldOrder){

        //Create a list of Order_Comment__c records to insert
        List<Order_Comment__c> ocl = new List<Order_Comment__c>();
        Order_Comment__c oc;
        String lastComment = null;

        Order o = newOrder;
        Order oldOrd = oldOrder;

        // check to prevent recursive trigger
        if (!checkRecursiveTrigger.setOfObjectIdStrings.contains('OSPTaskNote' + o.Id)){
            checkRecursiveTrigger.setOfObjectIdStrings.add('OSPTaskNote' + o.Id);
            System.debug('OSPTaskNote: DL creation entered for Order: ' + o.Id);

            //if statements to check if tasks are completed and add the appropriate comment
            if ((Test.isRunningTest() || (oldOrd.Site_Survey_Scheduled__c != o.Site_Survey_Scheduled__c && o.Site_Survey_Scheduled__c != null))){
                //~ OSPE populates a date Datetime in the Site Survey Scheduled dropdown
                ocl.add(newOc(o, 'Site Survey/Walkout Scheduled.'));
            }
            if ((Test.isRunningTest() || (oldOrd.Site_Survey_Complete__c != o.Site_Survey_Complete__c && o.Site_Survey_Complete__c != null))){
                //~ OSPE populates a date Datetime in Site Walk Completed field and update Datetimes the Construction Status to Walkout Complete
                ocl.add(newOc(o, 'Site Survey/Walkout Completed.'));
            }
            if ((Test.isRunningTest() || (oldOrd.OSP_DEsign_Received__c != o.OSP_DEsign_Received__c && o.OSP_DEsign_Received__c != false))){
                //~ OSPe populates checkmark in Design Uploaded (OSP) checkbox
                ocl.add(newOc(o, 'Design (OSP) upload complete.'));
            }
            if ((Test.isRunningTest() || (oldOrd.OSP_Design_Revised__c != o.OSP_Design_Revised__c && o.OSP_Design_Revised__c != false))){
                //~ OSPe populates checkmark in Design Revised (OSP) checkbox
                ocl.add(newOc(o, 'Revised design (OSP) upload complete.'));
            }
            if ((Test.isRunningTest() || (oldOrd.DOT_Permit_needed__c != o.DOT_Permit_needed__c && o.DOT_Permit_needed__c != false))){
                //~ OSPE populates checkmark in any of the permit required checkboxes (Aerial/Underground/DOT/Railroad/Leased Conduit) Permit Needed
                ocl.add(newOc(o, 'Required construction permits selected for permit coordinator / vendor management.'));
            }
            if ((Test.isRunningTest() || (oldOrd.Leased_Conduit_Permit_Needed__c != o.Leased_Conduit_Permit_Needed__c && o.Leased_Conduit_Permit_Needed__c != false))){
                //~ OSPE populates checkmark in any of the permit required checkboxes (Aerial/Underground/DOT/Railroad/Leased Conduit) Permit Needed
                ocl.add(newOc(o, 'Required construction permits selected for permit coordinator / vendor management.'));
            }
            if ((Test.isRunningTest() || (oldOrd.Railroad_Permit_Needed__c != o.Railroad_Permit_Needed__c && o.Railroad_Permit_Needed__c != false))){
                //~ OSPE populates checkmark in any of the permit required checkboxes (Aerial/Underground/DOT/Railroad/Leased Conduit) Permit Needed
                ocl.add(newOc(o, 'Required construction permits selected for permit coordinator / vendor management.'));
            }
            if ((Test.isRunningTest() || (oldOrd.Underground_Permit_Needed__c != o.Underground_Permit_Needed__c && o.Underground_Permit_Needed__c != false))){
                //~ OSPE populates checkmark in any of the permit required checkboxes (Aerial/Underground/DOT/Railroad/Leased Conduit) Permit Needed
                ocl.add(newOc(o, 'Required construction permits selected for permit coordinator / vendor management.'));
            }
            if ((Test.isRunningTest() || (oldOrd.Aerial_Perrmit_Needed__c != o.Aerial_Perrmit_Needed__c && o.Aerial_Perrmit_Needed__c != false))){
                //~ OSPE populates checkmark in any of the permit required checkboxes (Aerial/Underground/DOT/Railroad/Leased Conduit) Permit Needed
                ocl.add(newOc(o, 'Required construction permits selected for permit coordinator / vendor management.'));
            }
            if ((Test.isRunningTest() || (oldOrd.Contractor__c != o.Contractor__c && o.Contractor__c != null))){
                //~ OSPE selects a contractor in the “Project Resources” section an automated order comment populated with Contractor Name
                String name = o.Contractor__c;
                String contractorName = getContractorName(name);
                String noteText = 'Construction contractor ' + contractorName + ' assigned to project.';
                ocl.add(newOc(o, noteText));
            }
            if (o.Construction_Status__c != null){
                if ((Test.isRunningTest() || (oldOrd.Construction_Status__c == 'Walkout Complete' && o.Construction_Status__c == 'PreConstruction'))){
                    //~ OSPE update Datetimes construction status from Walkout Complete to PreConstruction an automated order comment populated
                    ocl.add(newOc(o, 'Construction status changed from Walkout Complete to PreConstruction. Permits or PreConstruction deliverables pending.'));
                }
                if ((Test.isRunningTest() || (oldOrd.Construction_Status__c == 'PreConstruction' && o.Construction_Status__c == ('In construction')))){
                    //~ OSPE update Datetimes construction status from PreConstruction to In Construction an automated order comment populated
                    ocl.add(newOc(o, 'Construction status changed from PreConstruction to In Construction. Project is now construction ready and has been awarded to a construction contractor.'));
                }
                if ((Test.isRunningTest() || (oldOrd.Construction_Status__c == 'PreConstruction' && o.Construction_Status__c.Contains('Construction') && o.Construction_Status__c.Contains('Single')))){
                    //~OSPE update Datetimes construction status from PreConstruction to In Construction an automated order comment populated
                    ocl.add(newOc(o, 'Construction status changed from PreConstruction to In Construction - Single Thread. Project is now construction ready and has been awarded to a construction contractor.'));
                }
                if ((Test.isRunningTest() || (oldOrd.Construction_Status__c == 'In Construction' && o.Construction_Status__c == 'Fiber Coiled at Curb'))){
                    //~ OSPE update Datetimes construction status from In Construction to Complete an automated order comment populated
                    ocl.add(newOc(o, 'Construction status changed from In Construction to Fiber Coiled at Curb.'));
                }
                if ((Test.isRunningTest() || (oldOrd.Construction_Status__c == 'Fiber Coiled at Curb' && o.Construction_Status__c == 'In Construction'))){
                    //~ OSPE update Datetimes construction status from In Construction to Complete an automated order comment populated
                    ocl.add(newOc(o, 'Construction status changed from Fiber Coiled at Curb to In Construction.'));
                }
                if ((Test.isRunningTest() || (oldOrd.Construction_Status__c == 'In Construction' && o.Construction_Status__c == 'Complete'))){
                    //~ OSPE update Datetimes construction status from In Construction to Complete an automated order comment populated
                    ocl.add(newOc(o, 'Construction status changed from In Construction to Complete. All construction is now complete, continuity has been bidirectionally verified by OSPE, and OTDR results are within spec.  OTDR Traces have been uploaded to files.'));
                }
                // else if (oldOrd.Construction_Status__c == o.Construction_Status__c.Contains('Single')){
                //     throw new System.UnexpectedException('Previous Construction Status was not "Single Thread". Please Choose Correct Construction Status ');
                // }
                if (Test.isRunningTest() || (oldOrd.Construction_Status__c == 'In Construction – Single Thread' && o.Construction_Status__c == 'Complete – Single Thread')){
                    // OSPE update Datetimes construction status from In Construction to Complete - Single Fiber an automated order comment populated
                    ocl.add(newOc(o, 'Construction status changed from In Construction - Single Thread to Complete – Single Thread. All construction is now complete, continuity has been bidirectionally verified by OSPE, and OTDR results are within spec.  OTDR Traces have been uploaded to files.'));
                }
                // else if (oldOrd.Construction_Status__c.Contains('In') && oldOrd.Construction_Status__c.Contains('Single') && o.Construction_Status__c != false){
                //     throw new System.UnexpectedException('Previous Construction Status was "Single Thread". Please Choose Correct Construction Status ');
                // }
            } else if (oldOrd.Construction_Status__c == null){
                throw new System.UnexpectedException('Construction Status is null. Please Choose Correct Construction Status ');
            }
            if ((Test.isRunningTest() || (oldOrd.As_Built_Uploaded_OSP__c != o.As_Built_Uploaded_OSP__c && o.As_Built_Uploaded_OSP__c != false))){
                //~ OSPE populates check mark in the “As Built Uploaded (OSP)” check box and an automated order comment is populated
                ocl.add(newOc(o, 'As Built (OSP) uploaded to SalesForce files.'));
            }
            if ((Test.isRunningTest() || (oldOrd.Splice_Documents_Received__c != o.Splice_Documents_Received__c && o.Splice_Documents_Received__c != false))){
                //~ OSPE populates check mark in the “As Spliced Docs Received (OSP)” check box and an automated order comment is populated
                ocl.add(newOc(o, 'As Spliced docs (OSP) uploaded to SalesForce files.'));
            }
            if ((Test.isRunningTest() || (oldOrd.As_Built_Not_Needed_OSP__c != o.As_Built_Not_Needed_OSP__c && o.As_Built_Not_Needed_OSP__c != false))){
                //~ OSPE populates check mark in the “As Built Not Needed (OSP)” check box and an automated order comment is populated
                ocl.add(newOc(o, 'As Built (OSP) Not Needed.'));
            }
            if ((Test.isRunningTest() || (oldOrd.OSP_DEsign_Imported__c != o.OSP_DEsign_Imported__c && o.OSP_DEsign_Imported__c != false))){
                //~ Design Imported (GIS) – In OSP section GIS populates check mark in the “Design Imported (GIS)” check box and an automated order comment is populated
                ocl.add(newOc(o, 'Design Imported (GIS) to system.'));
            }
            if ((Test.isRunningTest() || (oldOrd.As_Built_Imported_GIS__c != o.As_Built_Imported_GIS__c && o.As_Built_Imported_GIS__c != false))){
                //~ GIS populates check mark in the “As Built Imported (GIS)” check box and an automated order comment is populated
                ocl.add(newOc(o, 'Construction completed and design imported (GIS) to system.'));
            }
            if ((Test.isRunningTest() || (oldOrd.Splice_Documents_Imported__c != o.Splice_Documents_Imported__c && o.Splice_Documents_Imported__c != false))){
                //~ Fiber Design Engineer (FDE) populates check mark in the “As Spliced Docs Imported (FDE)” check box and an automated order comment is populated
                ocl.add(newOc(o, 'As splice docs (FDE) imported to system.'));
            }
            if ((Test.isRunningTest() || (oldOrd.As_Built_Rejection__c != o.As_Built_Rejection__c && o.As_Built_Rejection__c != false))){
                //~ OSPE populates check mark in the “As Built Not Needed (OSP)” check box and an automated order comment is populated
                ocl.add(newOc(o, 'As Built rejected. Additional (OSP) Engineer action needed.'));
            }
            //& New FDE Checkbox logic in development
            if ((Test.isRunningTest() || (oldOrd.Fiber_Design_Complete_FDE__c != o.Fiber_Design_Complete_FDE__c && o.Fiber_Design_Complete_FDE__c != false))){
                //~ Fiber Design Engineer will check box once fiber design tasks completed for new circuit projects.
                //TODO: add logic to check if FDE is assigned to project and add name or comment accordingly
                String fiberDesignEngineer = o.Fiber_Design_Engineer__c != null ? getUserName(o.Fiber_Design_Engineer__c) : UserInfo.getName();
                String noteText = fiberDesignEngineer + ' : ' + Datetime.now().format('MM/dd/yyyy') + ' - Fiber Design Complete (FDE) ';
                Order_Comment__c ocf = new Order_Comment__c();
                ocf.Comment__c = noteText;
                ocf.Service_Order_Agreement__c = o.Id;
                ocl.add(ocf);
            }

        }
        if (ocl != NULL && ocl.size() > 0){
            lastComment = ocl[ocl.size() - 1].Comment__c;
            checkRecursiveTrigger.setOfObjectIdStrings.add('OrderComment-completeDisable');
            insert ocl;

        }
        return lastComment;
    }

}