({
	doInit : function(cmp, event, helper) 
	{
		// some init stuff
		cmp.set("v.asyncInProgress", false)
		
	},

	unlockOne : function(cmp, event, helper) 
	{
		// some init stuff
		event.preventDefault()
		cmp.set("v.oneUnlock", true)
		helper.getProviderData(cmp).then(providerData => {
		cmp.set('v.providerData', providerData)
		})
	}, 
            
    lockOne : function(cmp, event, helper) 
	{
		
		cmp.set("v.oneUnlock", false)
	}, 
	
})