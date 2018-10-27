({
	doInit : function(cmp, event, helper) 
	{
		// some init stuff
		cmp.set("v.asyncInProgress", false);
		
	},

	unlockOne : function(cmp, event, helper) 
	{
		// some init stuff
		event.preventDefault()
		cmp.set("v.oneUnlock", true)
		helper.getMemberData(cmp).then(memberData => {
		cmp.set('v.memberData', memberData)
		})
	}, 
            
    lockOne : function(cmp, event, helper) 
	{
		// some init stuff
		//event.preventDefault()
		cmp.set("v.oneUnlock", false)
		
	}, 
	
})