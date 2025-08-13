/*
	Class Name: SyncPartsWithProductBatch
	Developer Name: Akshay Choudhary
	Description : This class is used to relate a product to a part. If the product does not exist, it will first be created, and then the part will be linked to that product.
*/
public class SyncPartsWithProductBatch implements Database.Batchable<sObject>,Schedulable {

    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Id,Name,Part_Number__c,Product__c,Active__c from SQX_Part__c '+
            			'where Product__c = Null AND Active__c = true';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<SQX_Part__c> scope){
        Set<String> productNameSet = new Set<String>(); 
        Set<String> productCodeSet = new Set<String>(); 
        List<SQX_Part__c> partUpdateList = new List<SQX_Part__c>(); 
        List<Product2> productInsertList = new List<Product2>(); 
        for(SQX_Part__c paObj:scope){
            productNameSet.add(paObj.Name);
            productCodeSet.add(paObj.Part_Number__c);
        }
        //fatch product using Part Name and Part Number and store in map. key is product name and product code so we work on exact product
        Map<String,Product2> productMap = new Map<String,Product2>();
        System.debug('query : '+[Select Id,Name,ProductCode,IsActive From Product2 Where IsActive = true AND Name IN:productNameSet AND ProductCode IN : productCodeSet]);
        for(Product2 pdObj:[Select Id,Name,ProductCode,IsActive From Product2 Where IsActive = true AND Name IN:productNameSet AND ProductCode IN : productCodeSet]){
            String key = pdObj.Name+'####'+pdObj.ProductCode;
            productMap.put(key,pdObj);
        }
        System.debug('productMap : '+productMap);
        //checking for product is available or not
        for(SQX_Part__c paObj:scope){
            String key = paObj.Name+'####'+paobj.Part_Number__c;
            if(productMap.containsKey(key)){
                paObj.Product__c = productMap.get(key).Id;
                partUpdateList.add(paObj);
            }else{
                Product2 pd = new Product2();
                pd.Name = paObj.Name;
                pd.IsActive = true;
                pd.ProductCode = paObj.Part_Number__c;
                productInsertList.add(pd);
            }
        }
        
        Map<String,Product2> productNewMap = new Map<String,Product2>();
        if(!productInsertList.isEmpty()){
            insert productInsertList;
            
            for(Product2 pdObj:productInsertList){
                String key = pdObj.Name+'####'+pdObj.ProductCode;
                productNewMap.put(key,pdObj);
            }
        }
        for(SQX_Part__c paObj:scope){
            String key = paObj.Name+'####'+paobj.Part_Number__c;
            if(productNewMap.containsKey(key)){
                paObj.Product__c = productNewMap.get(key).Id;
                partUpdateList.add(paObj);
            }
        }
        System.debug('partUpdateList else  : '+partUpdateList);
        if(!partUpdateList.isEmpty()){
            update partUpdateList;
        }
        
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    
    
    // to schedule batch class
    public void execute(SchedulableContext sc){
        SyncPartsWithProductBatch syBatch = new SyncPartsWithProductBatch();
        Database.executeBatch(syBatch,200);
    }
}