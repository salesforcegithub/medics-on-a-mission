({
    doInit : function(component, event, helper) 
    {
        
        //call apex class method
        var action = component.get('c.initMethod');
        //component.set("v.oneUnlock", true)
        
        action.setCallback(this, function(response) 
       {
           //store state of response
           var state = response.getState();
           if (state === "SUCCESS") 
           {
               //set response value in wrapperList attribute on component.
               component.set('v.wrapperList', response.getReturnValue());
           }
       });
        
        action.setParams({
            "recordID": component.get("v.recordId")
        });
        $A.enqueueAction(action);
    },
    
    unlockOne : function(cmp, event, helper) 
	{	
		cmp.set("v.oneUnlock", true)
		
	}, 
            
    lockOne : function(cmp, event, helper) 
	{
		
		cmp.set("v.oneUnlock", false)
	}, 
})