({
	helperMethod : function() 
	{
		
	},

	getProviderData : function(cmp) 
	{
		return this.controllerCallout(cmp, "c.getProviderData")

	},

	controllerCallout : function(cmp, cFunction, params)
	{
		return new Promise($A.getCallback((resolve,reject) => 
		{
			var action = cmp.get(cFunction)
			params && action.setParams(params)
      action.setCallback(this, (response,event) => 
      {
        var state = response.getState()
        if (state === "SUCCESS") 
        {
          resolve(response.getReturnValue())
        }
        else 
        {
          reject(event)
        }
      });

       action.setParams({
            "providerID": cmp.get("v.recordId")
        });

      $A.enqueueAction(action)

    }))
	},

	thisCallout : function(cmp) 
	{
		var host = 'https://www.google.com'
		var  path = '/search/'
		var headerParam = 
		{
			'Accept-Encoding': 'br, gzip, deflate',
			'Connection': 'keep-alive',
			'Accept': 'application/json',
			'User-Agent': 'hermes/1.12.0 iOS/11.4',
			'Accept-Language': 'en;q=1',
		}
		var method = 'Get'
		return this.callAjax(method, host, path, headerParam)
	},

	callAjax : function(method, host, path, headerParam) 
	{
		return new Promise($A.getCallback((resolve,reject) => 
		{
			var xmlhttp = new XMLHttpRequest()
			xmlhttp.addEventListener("load", loadEvt => 
			{
				// var location = xmlhttp.getResponseHeader('Location')

				var reqId = xmlhttp.getResponseHeader('ETag')
				console.log('returnXMLrdy headerReceived ' + reqId + ' | ' + xmlhttp.responseText)
				console.log('load evtTarget', loadEvt )
				resolve(xmlhttp.responseText)
			})
			xmlhttp.addEventListener("error", loadEvt => {
				console.log('error evtTarget', loadEvt )
				console.log('error this', this )
				reject('failed:' + loadEvt)
			})
			
			xmlhttp.open(method, host + path)
			headerParam && Object.keys(headerParam).forEach( key => {
				xmlhttp.setRequestHeader(key,headerParam[key])
			})
			xmlhttp.send()
		}))
	}
})