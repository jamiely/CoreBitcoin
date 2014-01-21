#import "BTCBlockchainInfo.h"
#import "BTCTransactionOutput.h"
#import "BTCScript.h"
#import "BTCData.h"

@implementation BTCBlockchainInfo

// Builds a request from a list of BTCAddress objects.
- (NSMutableURLRequest*) requestForUnspentOutputsWithAddresses:(NSArray*)addresses
{
    if (addresses.count == 0) return nil;
    
    NSString* urlstring = [NSString stringWithFormat:@"https://blockchain.info/unspent?active=%@", [[addresses valueForKey:@"base58String"] componentsJoinedByString:@"|"]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring]];
    request.HTTPMethod = @"GET";
    return request;
}

// List of BTCTransactionOutput instances.
- (NSArray*) unspentOutputsForResponseData:(NSData*)responseData error:(NSError**)errorOut
{
    if (!responseData) return nil;
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:errorOut];
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    
    NSMutableArray* outputs = [NSMutableArray array];
    
    for (NSDictionary* item in dict[@"unspent_outputs"])
    {
        BTCTransactionOutput* txout = [[BTCTransactionOutput alloc] init];
        
        txout.value = [item[@"value"] longLongValue];
        txout.script = [[BTCScript alloc] initWithData:BTCDataWithHexString(item[@"script"])];
        txout.index = [item[@"tx_output_n"] intValue];
        txout.confirmations = [item[@"confirmations"] unsignedLongLongValue];
        txout.transactionHash = BTCDataWithHexString(item[@"tx_hash"]);
        
        [outputs addObject:txout];
    }
    
    return outputs;
    
    /*
     {
	 
         "unspent_outputs":[
     
             {
                 "tx_hash":"982051fd1e4ba744bbbe680e1fee14677ba1a3c3540bf7b1cdb606e857233e0e",
                 "tx_index":2,
                 "tx_output_n": 0,
                 "script":"410496b538e853519c726a2c91e61ec11600ae1390813a627c66fb8be7947be63c52da7589379515d4e0a604f8141781e62294721166bf621e73a82cbf2342c858eeac",
                 "value": 5000000000,
                 "value_hex": "012a05f200",
                 "confirmations":281337
             },
             
             {
                 "tx_hash":"520cae06673fc6950fdb2a2cba32f63b50fe99ce2d8469cfc3ddedf6cc34bed6",
                 "tx_index":668673,
                 "tx_output_n": 1,
                 "script":"76a914119b098e2e980a229e139a9ed01a469e518e6f2688ac",
                 "value": 2000000,
                 "value_hex": "1e8480",
                 "confirmations":153679
             },
             ...
    */
}

- (NSMutableURLRequest*) requestForTransactionBroadcastWithData:(NSData*)data
{
    if (data.length == 0) return nil;
    
    NSString* urlstring = @"https://blockchain.info/pushtx";
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring]];
    request.HTTPMethod = @"POST";
    NSString* form = [NSString stringWithFormat:@"tx=%@", BTCHexStringFromData(data)];
    request.HTTPBody = [form dataUsingEncoding:NSUTF8StringEncoding];
    return request;
    
}


@end