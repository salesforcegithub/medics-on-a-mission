({
	doInit : function(cmp, event, helper) {
		// some init stuff
		helper.getMemberData(cmp).then(res => {
			console.log('returnAccount ', res.BillingStreet)
			res.BillingStreet = res.BillingStreet ? res.BillingStreet.replace(/(?:\r\n|\r|\n)/g, '\r\n') : res.BillingStreet
			cmp.set("v.updateAccount", res)
			cmp.set("v.originalAccount", res)
			cmp.set("v.asyncInProgress", false)
		}).catch(err => {
			console.error('save res', err)
			cmp.find('notifLib').showNotice({
				"variant": "error",
				"header": "Error!",
				"message": "err.message",
				closeCallback: function() {
					$A.get("e.force:closeQuickAction").fire() 
					$A.get('e.force:refreshView').fire()
				}
			})
			cmp.set("v.asyncInProgress", false)
		})
		
	},
	updateMember : function(cmp, event, helper) {
		event.preventDefault()
		var updateAccount = cmp.get("v.updateAccount")
		cmp.set("v.asyncInProgress", true)
		helper.updateDoDMember(cmp,updateAccount).then(res => {
			console.log('update account res', res)
			if (res.errors) {
				throw res.errors 
			}
			if(res.pending){
				cmp.find('notifLib').showNotice({
					"variant": "info",
					"header": "Update Pending",
					"message": res.pending || "Update queued",
					closeCallback: $A.getCallback(function(){
						$A.get("e.force:closeQuickAction").fire() 
						$A.get('e.force:refreshView').fire()
					})
				})
			} else {
				cmp.set("v.memberContact", res);
				cmp.find('notifLib').showNotice({
					"variant": "success",
					"header": "Success!",
					"message": 'Update member complete',
					closeCallback: $A.getCallback(function(){
						$A.get("e.force:closeQuickAction").fire() 
						$A.get('e.force:refreshView').fire()
					})
				})

			}
			cmp.set("v.asyncInProgress", false)
		}).catch(err => {
			console.error('save res', err)
			cmp.find('notifLib').showNotice({
				"variant": "error",
				"header": "Error!",
				"message": err.message || JSON.stringify(err)
			})
			cmp.set("v.asyncInProgress", false)
		})
	},
	closeWindow : function(cmp, event, helper) {
		event.preventDefault()
		$A.get("e.force:closeQuickAction").fire() 
		$A.get('e.force:refreshView').fire();
	}
})