global class ParticipantsEmailHandler implements Messaging.InboundEmailHandler 
{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelop)
    {
        String previousMailText = '</br></br>___________________________________________________________________________________________________</br>';
        previousMailText += '<b>From:</b>'+email.fromAddress +'</br>'; 
        previousMailText += '<b>Subject:</b>'+email.subject+'</br>';
        previousMailText += '<b>To:</b>'+envelop.toAddress +'</br>';
        previousMailText += email.plainTextBody.replaceAll('\n','</br>');
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();   
        
        EmailTemplate emailTemplate = new EmailTemplate();
        String templateSubject='';
        String templateBody='';
        Integer sale=0;
        Integer claim=0;
        List<List<String>> DataListForProcessing = new List<List<String>>();
        
        if(email.subject.containsIgnoreCase('Trailympics')){
            DataListForProcessing = parseEmailTable(email, envelop, previousMailText);   
        }
        
        System.debug('DataListForProcessing---->'+DataListForProcessing);
        
        /* if(DataListForProcessing != null && DataListForProcessing.size()>1){
                                  
        } */  
        return result;
    }
    
     // This function parses the table in email 
        public List<List<String>> parseEmailTable(Messaging.InboundEmail email, Messaging.InboundEnvelope envelop, String previousMailText){
            System.debug('in method parseEmailTable');
            Integer countRows =0;        //This variable stores the number of rows in the table.
            Integer countCols =0;        //This variable stores the number of column in the table.
            Boolean countColsFlag = true;
            Boolean areTableHeadersInOrder = true;
            Integer customSettingCounter=0;
            String tableData = '';        //This variable stores the table body content
            List <String> trStringList = new List<String>();        //This list contains the table row string
            List <String> tdStringList = new List<String>();        //This list contains the table column string      
            List <String> finalTableData = new List<String>();         //This list contains the table data 
            List<List<String>> participantDataList = new List<List<String>>();
            List<List<String>> DataListForParticipantCreation = new List<List<String>>();
            
            List<Email_Template_Config__c>  participantCreationTemplateList = new List<Email_Template_Config__c>();
            List<String> tableHeaderList = new List<String>();
            List<String> invoiceNumberList =  new List<String>();
            String subject = email.subject;                     
            String mailBody = email.htmlBody;
            String mailTextBody = email.plainTextBody;
            String senderName = email.fromName;
            tableData = mailBody.substringBetween('<tbody>','</tbody>'); //Storing the html content between <tbody> and </tbody> into tableData String variable
            trStringList.addAll(tableData.split('</tr>'));         //Storing all table row content in trStringList 
            countRows = trStringList.size()-1;        //Storing count of rows
            trStringList.remove(countRows);        //Removing last element of the List because it does not contain useful data
            for(String tr : trStringList)    //This loop scans every row one by one and stores the values of table data in tdStringList
            {     
                if(countColsFlag)//This if block stores the total number of columns for a row
                {                
                    countCols = tr.countMatches('</td>');
                    countColsFlag = false;
                }
                tdStringList.addAll(tr.split('</td>'));         //Adding table data in tdStringList
                tdStringList.remove(tdStringList.size()-1);         //Removing the last element because it does not contain useful data               
            }
            for(String td : tdStringList)         //Removing all html tags and storing table data in finalTableData list
            {
                td = td.replaceAll('<[^>]*>','').replaceAll('\n', '').replaceAll('&nbsp;', '').trim();
                finalTableData.add(td);                  
            } 
            for(Integer i = 0, finalTableDataCount = 0; i<countRows; i++ ) //Storing the values of finalTableData into participantDataList List of lists
            { 
                List <String> tempList = new List<String>();
                
                for(Integer j = 0; j<countCols ; j++ )
                {    
                    tempList.add(finalTableData[finalTableDataCount++]);
                    
                }
                participantDataList.add(tempList);
                if(i==0)
                {
                    DataListForParticipantCreation.add(tempList);
                    System.debug('DataListForParticipantCreation ======================='+ DataListForParticipantCreation);
                }
            }   
            //Need to remove this code after testing        
            for(Integer i = 0; i< countRows ; i++ )
            {
                for(Integer j = 0; j<countCols ; j++ )
                { 
                    System.debug('participantDataList clean table data : '+participantDataList[i][j]);
                }
            }
            
            /*Storing the header values from custom setting and comparing with the table that comes in mail*/
            participantCreationTemplateList = [select Column_Header__c, Sequence_Number__c from Email_Template_Config__c order by Sequence_Number__c asc];
            tableHeaderList = participantDataList[0];
            if(participantCreationTemplateList.size()!=0 && tableHeaderList.size()!=0)
            {
                for(String tableHeader : tableHeaderList)
                {
                    System.debug('tableHeader'+tableHeader);
                    if(participantCreationTemplateList.get(customSettingCounter++).Column_Header__c != tableHeader)
                    {
                        areTableHeadersInOrder = false;
                        break;
                    }
                } 
            }       
            else
            {
                areTableHeadersInOrder = false;  
            }   
            
            if(areTableHeadersInOrder) // If table is in proper format
            {
                System.debug('in if areTableHeadersInOrder');
                /* EmailTemplate emailTemplate = [SELECT Id, Name, Subject, Body FROM EmailTemplate WHERE Name = 'XYZ...'];
                System.debug('in emailTemplate after |in if areTableHeadersInOrder' + emailTemplate.Id);  */     
                String contentToBeReplaced = '';             
                List<String> toAdd = new List<String>();
                toAdd.add(email.fromAddress);
                String tableHeaderForReplyMail =  '<table border="1" style="border-collapse: collapse"><tr>';
                for(String tableHeaderString :tableHeaderList)
                {
                    tableHeaderForReplyMail += '<th>'+ tableHeaderString +'</th>';
                }
                tableHeaderForReplyMail += '</tr>' ; 
                contentToBeReplaced += tableHeaderForReplyMail;
                Boolean sendEmailForMissingOHR = false;   
                for (Integer i = 1; i<countRows; i++)
                {
                    if(String.isBlank(participantDataList[i][((Email_Template_Config__c.getAll()).get('OHR').Sequence_Number__c).intValue()]))
                    {
                        sendEmailForMissingOHR = true;
                        contentToBeReplaced += '<tr>' ;
                        for(Integer j = 0; j< countCols; j++ )
                        {
                            contentToBeReplaced += '<td>' + participantDataList[i][j] + '</td>' ;
                        }
                        contentToBeReplaced += '</tr>' ;
                        
                    }          
                    else
                    {
                        DataListForParticipantCreation.add(participantDataList[i]);
                    }
                }
                
                
                contentToBeReplaced += '</tr></table></br></br> Regards, </br>Trailympics Team'; 
                
                if(sendEmailForMissingOHR == true)
                {
                    /* sendMailUsingTemplate(true, toAdd,contentToBeReplaced ,previousMailText,new Messaging.SingleEmailMessage(), emailTemplate.Subject, null, null, emailTemplate.Body, null);  */          
                }
                System.debug('DataListForParticipantCreation ***********'+DataListForParticipantCreation) ;
                
                return DataListForParticipantCreation;
            }
            else{
                System.debug('in improper table header');
                /* EmailTemplate emailTemplate = [SELECT Id, Subject, Body FROM EmailTemplate WHERE Name = 'XYZ...'];
                List<String> toAdd = new List<String>();
                toAdd.add(email.fromAddress);
                sendMailUsingTemplate(true, toAdd, null,null,new Messaging.SingleEmailMessage(), emailTemplate.Subject, null, null, emailTemplate.Body, null);  */              
                return null;
            }       
        }
    
            //This function sends mail from respective template
        public void sendMailUsingTemplate(Boolean setHtm, List<String> toAddress, String templateReplaceableContent, String previousEmailChain, Messaging.SingleEmailMessage replyMailUsingTemplate, String templateSubject,String dispNumber,String emailSenderName, String templateBody, String mailingGroup)
        {
            System.debug('in sendMailUsingTemplate');
            if(dispNumber!=null && templateBody!=null)
            {   
                templateBody = templateBody.replace('{DisputeNumber}', dispNumber );
            }
            if(previousEmailChain!=null && templateBody!=null)
            {                   
                templateBody =  templateBody.replace('{PreviousEmailChain}', previousEmailChain);
            }
            if(emailSenderName!=null && templateBody!=null)
            {  
                
                templateBody = templateBody.replace('{SenderName}', emailSenderName);
            }
            if(templateReplaceableContent !=null && templateBody!=null)
            { 
                templateBody =  templateBody.replace('{ReplaceableContent}', templateReplaceableContent);
            }
            if(templateBody!=null && replyMailUsingTemplate!=null && setHtm == true)
            {                        
                replyMailUsingTemplate.setHtmlBody(templateBody);
            }
            if(templateBody!=null && replyMailUsingTemplate!=null && setHtm == false)
            {                        
                replyMailUsingTemplate.setPlainTextBody(templateBody);
            }       
            if(mailingGroup!=null&& replyMailUsingTemplate!=null)
            {
                replyMailUsingTemplate.setToAddresses(getGroupMembersMailAddresses(mailingGroup));
            }
            if(templateSubject!=null && replyMailUsingTemplate!=null)
            {                       
                replyMailUsingTemplate.setSubject(templateSubject);
            }
            if(toAddress!=null && replyMailUsingTemplate!=null)
            {   
                replyMailUsingTemplate.setToAddresses(toAddress);
            }
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { replyMailUsingTemplate });
           
        }
    
    //This function takes the public group name and returns the email ids of users belonging to the group
        public List<String> getGroupMembersMailAddresses(String groupName)
        {
            List<String> groupMailList = new List<String>();
            List<String> groupMailAddresses = new List<String>();
            Group grp = [SELECT (select userOrGroupId from groupMembers) from group where name = :groupName];
            for (GroupMember gm : grp.groupMembers) 
            {
                groupMailList.add(gm.userOrGroupId);
            }
            User[] usr = [SELECT email FROM user WHERE id IN :groupMailList];
            for(User u : usr) 
            {
                groupMailAddresses.add(u.email);
            }
            System.debug('groupMailAddresses'+groupMailAddresses.size());
            return groupMailAddresses;
        }
    
}