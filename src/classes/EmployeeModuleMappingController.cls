public class EmployeeModuleMappingController {
    public static Contact selectedEmp{get;set;}
    public static Id selectedEmpId{get;set;}
    public static Id selectedModules{get;set;}
    public List<Selectoption> getEmployees()//list all emp with url<>null
    {
         List<Selectoption> lstnamesel = new List<selectoption>();
            lstnamesel.add(new selectOption('None', '- None -'));
            for(Contact con :[Select id, Name, Email, Trailhead_Profile_URL__c, OHR_ID__c from Contact where  Trailhead_Profile_URL__c <> null])
            {                lstnamesel.add(new selectoption(con.id,con.Name));                
                
    }
    return lstnamesel;
	}
    
    public PageReference SelectedEmployeeDetail()
    {
        selectedEmp=[Select id,Name,Email, Trailhead_Profile_URL__c, OHR_ID__c from Contact where id =: selectedEmpId];
        return null;
    }
    
    public List<SelectOption> getMyType(){ 
        List<SelectOption> lstType = new List<SelectOption>();                  

        // Adding apicklist values to the select list
        for(Module__c md : [Select id,Name from Module__c order by Name]){
            lstType.add(new SelectOption(md.Id, md.Name)); 
        }
    
        return lstType;
    }
}