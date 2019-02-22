public class SmartNewsController {
	@AuraEnabled
    public static List<News__c> parseJSONResponse() {  
        System.debug('Inside SmartNewsController');
        List<News__c> listOfNews;
        HttpRequest request;
        HttpResponse response;
        JSONParserUtil parseToApex;
        try{
			Http httpProtocol = new Http();
        
            // Create HTTP request to send.
            request = new HttpRequest();
            // Set the endpoint URL.
            String endpoint = 'https://newsapi.org/v2/top-headlines?' +'category=technology&' + 'country=us&' + 'source=abc-news&' + 'apiKey=3c533185a10a4307a47c1356d4d7b9be';
            request.setEndPoint(endpoint);
            // Set the HTTP verb to GET.
            request.setMethod('GET');
            request.setTimeout(60000); 
            // Send the HTTP request and get the response.
            // The response is in JSON format.
            response = httpProtocol.send(request);
            System.debug(response.getBody());
            String jsonString = response.getBody();
            parseToApex = JSONParserUtil.parse(jsonString);
            
            endpoint = 'https://newsapi.org/v2/sources?apiKey=3c533185a10a4307a47c1356d4d7b9be';
            request.setEndPoint(endpoint);
            // Set the HTTP verb to GET.
            request.setMethod('GET');
            request.setTimeout(60000); 
            // Send the HTTP request and get the response.
            // The response is in JSON format.
            response = httpProtocol.send(request);
            System.debug(response.getBody());            
        }catch(System.CalloutException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        String jsonSourceString = response.getBody();
        JSON2ApexSources parseToApexSources = JSON2ApexSources.parse(jsonSourceString);
		
        Boolean isSavedNews = saveRecords(parseToApex);
        System.debug(parseToApex);
        System.debug(isSavedNews);
        listOfNews = [select id, publishedAt__c, SourceUrl__c, Author__c, Title__c, Description__c, urlToImage__c, Source__c,
                                       Content__c from News__c order by publishedAt__c desc];
									   
		Boolean isSavedSources = saveSources(parseToApexSources);
        System.debug(parseToApexSources);
        System.debug(isSavedSources);
       
        return listOfNews;
    }   
    
    public static Boolean saveRecords(JSONParserUtil parseToApex) { 
        Boolean isSaved = false;
        if(parseToApex.status.equalsignorecase('ok')){
            List<News__c> listOfNews = new List<News__c>();
            News__c newsRecord;
            Boolean newRecordsLoaded = true;
            
            //remove old records from the object
            List<News__c> oldRecordList = [select id, publishedAt__c, SourceUrl__c from News__c order by publishedAt__c desc];
            
            if(oldRecordList != null && oldRecordList.size() > 0){
                News__c oldRecord = oldRecordList[0];
                Date lastRecordSavedDate = date.newinstance(oldRecord.publishedAt__c.year(), oldRecord.publishedAt__c.month(), 
                                                        oldRecord.publishedAt__c.day());
            
                if(lastRecordSavedDate != System.today()){
                    delete [select id from News__c];
                }else{
                    for(JSONParserUtil.Articles article : parseToApex.articles){
                        if(article.url.equalsignorecase(oldRecord.SourceUrl__c)){
                            newRecordsLoaded = false;
                            break;
                        }
                    }
                }
            }
            
            
            if(newRecordsLoaded){
                 for(JSONParserUtil.Articles article : parseToApex.articles){
                    newsRecord = new News__c();
                    newsRecord.Author__c = article.author;
                    newsRecord.Title__c = article.title;
                    newsRecord.Description__c = article.description;
                    newsRecord.SourceUrl__c = article.url;
                    newsRecord.urlToImage__c = article.urlToImage;
                    newsRecord.publishedAt__c =  (DateTime)json.deserialize(article.publishedAt, datetime.class);
                    newsRecord.Content__c = article.content;
                    newsRecord.Source__c = String.valueOf(article.source);
                    listOfNews.add(newsRecord);
                }
                if( listOfNews != null && listOfNews.size() > 0 ){
                    insert listOfNews;
                    isSaved = true;
                }
            }
        }
        
        return isSaved;
    }
    
       
    public static Boolean saveSources(JSON2ApexSources parseToApex) { 
        Boolean isSaved = false;
        if(parseToApex.status.equalsignorecase('ok')){
            System.debug('Status:'+parseToApex.status);
			List<News_Source__c> listOfNewsSources = new List<News_Source__c>();
            News_Source__c newsSouceRecord;
            
            //remove old records from the object
            List<News_Source__c> oldRecordList = [select id from News_Source__c];
            
            if(oldRecordList != null){
                delete oldRecordList;
            }
            
            for(JSON2ApexSources.Sources source : parseToApex.Sources){
                    newsSouceRecord = new News_Source__c();
                    newsSouceRecord.ID__c = source.id;
                    newsSouceRecord.Name__c = source.name;
                	newsSouceRecord.Name = source.name;
                    newsSouceRecord.Description__c = source.description;
                    newsSouceRecord.URL__c = source.url;
                    newsSouceRecord.Category__c = source.category;
                    newsSouceRecord.Language__c = source.language;
                	newsSouceRecord.Country__c = source.country;
                    listOfNewsSources.add(newsSouceRecord);
                }
            
            if(listOfNewsSources != null && listOfNewsSources.size() > 0){
                insert listOfNewsSources;
                isSaved = true;
            }
            System.debug('listOfNewsSources:'+ listOfNewsSources);
        }
        System.debug('Sources Saved:'+ isSaved);
        
        return isSaved;
    }
    
     @AuraEnabled
     public static List <String> getselectOptions(sObject objObject, string fieldName) {
      system.debug('objObject --->' + objObject);
      system.debug('fieldName --->' + fieldName);
      List < String > allOpts = new list < String > ();
      // Get the object type of the SObject.
      Schema.sObjectType objType = objObject.getSObjectType();
     
      // Describe the SObject using its object type.
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
     
      // Get a map of fields for the SObject
      map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
      system.debug('fieldMap ---->' + fieldMap);
     
      // Get the list of picklist values for this field.
      list < Schema.PicklistEntry > values =
      fieldMap.get(fieldName).getDescribe().getPickListValues();
     
      // Add these values to the selectoption list.
      for (Schema.PicklistEntry a: values) {
       allOpts.add(a.getValue());
      }
      system.debug('allOpts ---->' + allOpts);
      allOpts.sort();
      return allOpts;
     }
}