@isTest
private class SyncPartsWithProductBatchTest {
	
    @isTest
    static void testProductExist(){
        
        Product2 existingPd = new Product2();
        existingPd.Name = 'Test Product';
        existingPd.ProductCode = 'TP001';
        existingPd.IsActive = true;
        insert existingPd;
        
        SQX_Part__c part = new SQX_Part__c();
        part.Name = 'Test Product';
        part.Part_Number__c = 'TP001';
        part.Active__c = true;
        insert part;

		Test.startTest();
        SyncPartsWithProductBatch syPaPrd = new SyncPartsWithProductBatch();
        String ID = Database.executeBatch(syPaPrd,200);
        Test.stopTest();
        
        List<SQX_Part__c> partList = [SELECT Id,Product__c FROM SQX_Part__c WHERE Product__c = :existingPd.Id Limit 1];
        System.assertEquals(partList[0].Product__c,existingPd.Id);
    }

	@isTest
    static void testProductNew(){
        
        SQX_Part__c part = new SQX_Part__c();
        part.Name = 'Test Product New';
        part.Part_Number__c = 'TP002';
        part.Active__c = true;
		
		insert part;
        
		Test.startTest();
        SyncPartsWithProductBatch syPaPrd = new SyncPartsWithProductBatch();
        String ID = Database.executeBatch(syPaPrd,200);
        Test.stopTest();
        SQX_Part__c partList = [SELECT Id,Product__c FROM SQX_Part__c WHERE Id = :part.Id Limit 1];
        List<Product2> newProd = [SELECT Id FROM Product2 WHERE Id = :partList.Product__c Limit 1];
        System.assertEquals(partList.Product__c,newProd[0].Id);
    }
    
}