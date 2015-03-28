
#import "CommonMethods.h"
#import "DataBaseMethods.h"

@implementation CommonMethods

#define kNewActivityAlertKey @"ShowNewActivityAlert"



#pragma mark - Alerts

+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelBtnTitle:(NSString *)cancelTitle otherBtnTitle:(NSString *)otherTitle delegate:(id)sender tag:(NSInteger)alertTag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:sender cancelButtonTitle:cancelTitle otherButtonTitles:otherTitle,nil];
    alert.tag = alertTag;
    
    [alert show];
    //return alert;
}

#pragma mark - Data Conversions

+(NSData*)toJSON:(NSDictionary *)dict
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:dict
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}


+(NSDate *)convertStringtoDate:(NSString *)dateString
{
    //dateString = 2013-12-24 18:00:00
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//@"yyyy-MM-dd HH:mm:ss"];
    // voila!
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    NSLog(@"dateFromString %@", dateFromString);
    return dateFromString;
}

+(NSString *)convertDatetoSting:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setDateFormat:@"HH:mm a"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSLog(@"date: %@", strDate);
    return strDate;
}

+(NSString *)convertDateofBirthFormat:(NSString *)dob {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"dd-MMM-yyyy"];
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
// [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    NSDate *dateFromString = [dateFormatter dateFromString:dob];

    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSString *strDate = [dateFormatter stringFromDate:dateFromString];
    return strDate;
}

+(NSString*)countryPhoneCode:(NSString*)countryCode
{
    NSString *cnCode;
    if([countryCode isEqualToString:@"IN"]){
        cnCode = [NSString stringWithFormat:@"91"];
    }
    else if([countryCode isEqualToString:@"DE"]){
        cnCode = [NSString stringWithFormat:@"49"];
    }
    else if([countryCode isEqualToString:@"AF"]){
        cnCode = [NSString stringWithFormat:@"93"];
    }
    else if([countryCode isEqualToString:@"AL"]){
        cnCode = [NSString stringWithFormat:@"355"];
    }
    else if([countryCode isEqualToString:@"DZ"]){
        cnCode = [NSString stringWithFormat:@"213"];
    }
    else if([countryCode isEqualToString:@"AS"]){
        cnCode = [NSString stringWithFormat:@"1684"];
    }
    else if([countryCode isEqualToString:@"AD"]){
        cnCode = [NSString stringWithFormat:@"376"];
    }
    else if([countryCode isEqualToString:@"AO"]){
        cnCode = [NSString stringWithFormat:@"244"];
    }
    else if([countryCode isEqualToString:@"AI"]){
        cnCode = [NSString stringWithFormat:@"1264"];
    }
    else if([countryCode isEqualToString:@"AQ"]){
        cnCode = [NSString stringWithFormat:@"672"];
    }
    else if([countryCode isEqualToString:@"AG"]){
        cnCode = [NSString stringWithFormat:@"1268"];
    }
    else if([countryCode isEqualToString:@"AR"]){
        cnCode = [NSString stringWithFormat:@"54"];
    }
    else if([countryCode isEqualToString:@"AM"]){
        cnCode = [NSString stringWithFormat:@"374"];
    }
    else if([countryCode isEqualToString:@"AW"]){
        cnCode = [NSString stringWithFormat:@"297"];
    }
    else if([countryCode isEqualToString:@"AU"]){
        cnCode = [NSString stringWithFormat:@"61"];
    }
    else if([countryCode isEqualToString:@"AT"]){
        cnCode = [NSString stringWithFormat:@"43"];
    }
    else if([countryCode isEqualToString:@"AZ"]){
        cnCode = [NSString stringWithFormat:@"994"];
    }
    else if([countryCode isEqualToString:@"BS"]){
        cnCode = [NSString stringWithFormat:@"1242"];
    }
    else if([countryCode isEqualToString:@"BH"]){
        cnCode = [NSString stringWithFormat:@"973"];
    }
    else if([countryCode isEqualToString:@"BD"]){
        cnCode = [NSString stringWithFormat:@"880"];
    }
    else if([countryCode isEqualToString:@"BB"]){
        cnCode = [NSString stringWithFormat:@"1246"];
    }
    else if([countryCode isEqualToString:@"BY"]){
        cnCode = [NSString stringWithFormat:@"375"];
    }
    else if([countryCode isEqualToString:@"BE"]){
        cnCode = [NSString stringWithFormat:@"32"];
    }
    else if([countryCode isEqualToString:@"BZ"]){
        cnCode = [NSString stringWithFormat:@"501"];
    }
    else if([countryCode isEqualToString:@"BJ"]){
        cnCode = [NSString stringWithFormat:@"229"];
    }
    else if([countryCode isEqualToString:@"BM"]){
        cnCode = [NSString stringWithFormat:@"1441"];
    }
    else if([countryCode isEqualToString:@"BT"]){
        cnCode = [NSString stringWithFormat:@"975"];
    }
    else if([countryCode isEqualToString:@"BO"]){
        cnCode = [NSString stringWithFormat:@"591"];
    }
    else if([countryCode isEqualToString:@"BA"]){
        cnCode = [NSString stringWithFormat:@"387"];
    }
    else if([countryCode isEqualToString:@"BW"]){
        cnCode = [NSString stringWithFormat:@"267"];
    }
    else if([countryCode isEqualToString:@"BR"]){
        cnCode = [NSString stringWithFormat:@"55"];
    }
    else if([countryCode isEqualToString:@"VG"]){
        cnCode = [NSString stringWithFormat:@"1284"];
    }
    else if([countryCode isEqualToString:@"BN"]){
        cnCode = [NSString stringWithFormat:@"673"];
    }
    else if([countryCode isEqualToString:@"BG"]){
        cnCode = [NSString stringWithFormat:@"359"];
    }
    else if([countryCode isEqualToString:@"BF"]){
        cnCode = [NSString stringWithFormat:@"226"];
    }
    else if([countryCode isEqualToString:@"MM"]){
        cnCode = [NSString stringWithFormat:@"95"];
    }
    else if([countryCode isEqualToString:@"BI"]){
        cnCode = [NSString stringWithFormat:@"257"];
    }
    else if([countryCode isEqualToString:@"KH"]){
        cnCode = [NSString stringWithFormat:@"855"];
    }
    else if([countryCode isEqualToString:@"CM"]){
        cnCode = [NSString stringWithFormat:@"237"];
    }
    else if([countryCode isEqualToString:@"CA"]){
        cnCode = [NSString stringWithFormat:@"1"];
    }
    else if([countryCode isEqualToString:@"CV"]){
        cnCode = [NSString stringWithFormat:@"238"];
    }
    else if([countryCode isEqualToString:@"KY"]){
        cnCode = [NSString stringWithFormat:@"1345"];
    }
    else if([countryCode isEqualToString:@"CF"]){
        cnCode = [NSString stringWithFormat:@"236"];
    }
    else if([countryCode isEqualToString:@"TD"]){
        cnCode = [NSString stringWithFormat:@"235"];
    }
    else if([countryCode isEqualToString:@"CL"]){
        cnCode = [NSString stringWithFormat:@"56"];
    }
    else if([countryCode isEqualToString:@"CN"]){
        cnCode = [NSString stringWithFormat:@"86"];
    }
    else if([countryCode isEqualToString:@"CX"]){
        cnCode = [NSString stringWithFormat:@"61"];
    }
    else if([countryCode isEqualToString:@"CC"]){
        cnCode = [NSString stringWithFormat:@"61"];
    }
    else if([countryCode isEqualToString:@"CO"]){
        cnCode = [NSString stringWithFormat:@"57"];
    }
    else if([countryCode isEqualToString:@"KM"]){
        cnCode = [NSString stringWithFormat:@"269"];
    }
    else if([countryCode isEqualToString:@"CK"]){
        cnCode = [NSString stringWithFormat:@"682"];
    }
    else if([countryCode isEqualToString:@"CR"]){
        cnCode = [NSString stringWithFormat:@"506"];
    }
    else if([countryCode isEqualToString:@"HR"]){
        cnCode = [NSString stringWithFormat:@"385"];
    }
    else if([countryCode isEqualToString:@"CU"]){
        cnCode = [NSString stringWithFormat:@"53"];
    }
    else if([countryCode isEqualToString:@"CY"]){
        cnCode = [NSString stringWithFormat:@"357"];
    }
    else if([countryCode isEqualToString:@"DK"]){
        cnCode = [NSString stringWithFormat:@"45"];
    }
    else if([countryCode isEqualToString:@"DJ"]){
        cnCode = [NSString stringWithFormat:@"253"];
    }
    else if([countryCode isEqualToString:@"DM"]){
        cnCode = [NSString stringWithFormat:@"1767"];
    }
    else if([countryCode isEqualToString:@"EC"]){
        cnCode = [NSString stringWithFormat:@"593"];
    }
    else if([countryCode isEqualToString:@"EG"]){
        cnCode = [NSString stringWithFormat:@"20"];
    }
    else if([countryCode isEqualToString:@"SV"]){
        cnCode = [NSString stringWithFormat:@"503"];
    }
    else if([countryCode isEqualToString:@"GQ"]){
        cnCode = [NSString stringWithFormat:@"240"];
    }
    else if([countryCode isEqualToString:@"ER"]){
        cnCode = [NSString stringWithFormat:@"291"];
    }else if([countryCode isEqualToString:@"EE"]){
        cnCode = [NSString stringWithFormat:@"372"];
    }
    else if([countryCode isEqualToString:@"ET"]){
        cnCode = [NSString stringWithFormat:@"251"];
    }
    else if([countryCode isEqualToString:@"FK"]){
        cnCode = [NSString stringWithFormat:@"500"];
    }
    else if([countryCode isEqualToString:@"FO"]){
        cnCode = [NSString stringWithFormat:@"298"];
    }
    else if([countryCode isEqualToString:@"FJ"]){
        cnCode = [NSString stringWithFormat:@"679"];
    }else if([countryCode isEqualToString:@"FI"]){
        cnCode = [NSString stringWithFormat:@"358"];
    }
    else if([countryCode isEqualToString:@"FR"]){
        cnCode = [NSString stringWithFormat:@"33"];
    }
    else if([countryCode isEqualToString:@"PF"]){
        cnCode = [NSString stringWithFormat:@"689"];
    }
    else if([countryCode isEqualToString:@"GA"]){
        cnCode = [NSString stringWithFormat:@"241"];
    }
    else if([countryCode isEqualToString:@"GM"]){
        cnCode = [NSString stringWithFormat:@"220"];
    }
    else if([countryCode isEqualToString:@"GE"]){
        cnCode = [NSString stringWithFormat:@"995"];
    }
    else if([countryCode isEqualToString:@"GH"]){
        cnCode = [NSString stringWithFormat:@"233"];
    }
    else if([countryCode isEqualToString:@"GI"]){
        cnCode = [NSString stringWithFormat:@"350"];
    }
    else if([countryCode isEqualToString:@"GR"]){
        cnCode = [NSString stringWithFormat:@"30"];
    }
    else if([countryCode isEqualToString:@"GL"]){
        cnCode = [NSString stringWithFormat:@"299"];
    }
    else if([countryCode isEqualToString:@"GD"]){
        cnCode = [NSString stringWithFormat:@"1473"];
    } else if([countryCode isEqualToString:@"GU"]){
        cnCode = [NSString stringWithFormat:@"1671"];
    }
    else if([countryCode isEqualToString:@"GT"]){
        cnCode = [NSString stringWithFormat:@"502"];
    }
    else if([countryCode isEqualToString:@"GN"]){
        cnCode = [NSString stringWithFormat:@"224"];
    }
    else if([countryCode isEqualToString:@"GY"]){
        cnCode = [NSString stringWithFormat:@"592"];
    }
    else if([countryCode isEqualToString:@"HT"]){
        cnCode = [NSString stringWithFormat:@"509"];
    }
    else if([countryCode isEqualToString:@"VA"]){
        cnCode = [NSString stringWithFormat:@"39"];
    }
    else if([countryCode isEqualToString:@"HN"]){
        cnCode = [NSString stringWithFormat:@"504"];
    } else if([countryCode isEqualToString:@"HK"]){
        cnCode = [NSString stringWithFormat:@"852"];
    }
    else if([countryCode isEqualToString:@"HU"]){
        cnCode = [NSString stringWithFormat:@"36"];
    } else if([countryCode isEqualToString:@"IS"]){
        cnCode = [NSString stringWithFormat:@"354"];
    }
    else if([countryCode isEqualToString:@"ID"]){
        cnCode = [NSString stringWithFormat:@"62"];
    }
    else if([countryCode isEqualToString:@"IR"]){
        cnCode = [NSString stringWithFormat:@"98"];
    }
    else if([countryCode isEqualToString:@"IQ"]){
        cnCode = [NSString stringWithFormat:@"964"];
    }
    else if([countryCode isEqualToString:@"IE"]){
        cnCode = [NSString stringWithFormat:@"353"];
    }
    else if([countryCode isEqualToString:@"IM"]){
        cnCode = [NSString stringWithFormat:@"44"];
    }
    else if([countryCode isEqualToString:@"IL"]){
        cnCode = [NSString stringWithFormat:@"972"];
    } else if([countryCode isEqualToString:@"IT"]){
        cnCode = [NSString stringWithFormat:@"39"];
    }
    else if([countryCode isEqualToString:@"JM"]){
        cnCode = [NSString stringWithFormat:@"1876"];
    } else if([countryCode isEqualToString:@"JP"]){
        cnCode = [NSString stringWithFormat:@"81"];
    }
    else if([countryCode isEqualToString:@"JO"]){
        cnCode = [NSString stringWithFormat:@"962"];
    }
    else if([countryCode isEqualToString:@"KZ"]){
        cnCode = [NSString stringWithFormat:@"7"];
    }
    else if([countryCode isEqualToString:@"KE"]){
        cnCode = [NSString stringWithFormat:@"254"];
    }
    else if([countryCode isEqualToString:@"KI"]){
        cnCode = [NSString stringWithFormat:@"686"];
    }
    else if([countryCode isEqualToString:@"KW"]){
        cnCode = [NSString stringWithFormat:@"965"];
    }
    else if([countryCode isEqualToString:@"KG"]){
        cnCode = [NSString stringWithFormat:@"996"];
    }
    else if([countryCode isEqualToString:@"LA"]){
        cnCode = [NSString stringWithFormat:@"856"];
    }
    else if([countryCode isEqualToString:@"LV"]){
        cnCode = [NSString stringWithFormat:@"371"];
    }
    else if([countryCode isEqualToString:@"LB"]){
        cnCode = [NSString stringWithFormat:@"961"];
    }
    else if([countryCode isEqualToString:@"LS"]){
        cnCode = [NSString stringWithFormat:@"266"];
    }
    else if([countryCode isEqualToString:@"LR"]){
        cnCode = [NSString stringWithFormat:@"231"];
    }
    else if([countryCode isEqualToString:@"LY"]){
        cnCode = [NSString stringWithFormat:@"218"];
    }
    else if([countryCode isEqualToString:@"LT"]){
        cnCode = [NSString stringWithFormat:@"370"];
    }
    else if([countryCode isEqualToString:@"LU"]){
        cnCode = [NSString stringWithFormat:@"352"];
    }
    else if([countryCode isEqualToString:@"MO"]){
        cnCode = [NSString stringWithFormat:@"853"];
    }
    else if([countryCode isEqualToString:@"MK"]){
        cnCode = [NSString stringWithFormat:@"389"];
    }
    else if([countryCode isEqualToString:@"MG"]){
        cnCode = [NSString stringWithFormat:@"261"];
    }
    else if([countryCode isEqualToString:@"MW"]){
        cnCode = [NSString stringWithFormat:@"265"];
    }
    else if([countryCode isEqualToString:@"MY"]){
        cnCode = [NSString stringWithFormat:@"60"];
    }
    else if([countryCode isEqualToString:@"MV"]){
        cnCode = [NSString stringWithFormat:@"960"];
    }
    else if([countryCode isEqualToString:@"ML"]){
        cnCode = [NSString stringWithFormat:@"223"];
    }
    else if([countryCode isEqualToString:@"MT"]){
        cnCode = [NSString stringWithFormat:@"356"];
    }
    else if([countryCode isEqualToString:@"MH"]){
        cnCode = [NSString stringWithFormat:@"692"];
    }
    else if([countryCode isEqualToString:@"MR"]){
        cnCode = [NSString stringWithFormat:@"222"];
    }
    else if([countryCode isEqualToString:@"MU"]){
        cnCode = [NSString stringWithFormat:@"230"];
    }
    else if([countryCode isEqualToString:@"YT"]){
        cnCode = [NSString stringWithFormat:@"262"];
    }
    else if([countryCode isEqualToString:@"MX"]){
        cnCode = [NSString stringWithFormat:@"52"];
    }
    else if([countryCode isEqualToString:@"FM"]){
        cnCode = [NSString stringWithFormat:@"691"];
    }
    else if([countryCode isEqualToString:@"MD"]){
        cnCode = [NSString stringWithFormat:@"373"];
    }
    else if([countryCode isEqualToString:@"MC"]){
        cnCode = [NSString stringWithFormat:@"377"];
    }
    else if([countryCode isEqualToString:@"MN"]){
        cnCode = [NSString stringWithFormat:@"976"];
    }
    else if([countryCode isEqualToString:@"MS"]){
        cnCode = [NSString stringWithFormat:@"1664"];
    }
    else if([countryCode isEqualToString:@"MA"]){
        cnCode = [NSString stringWithFormat:@"212"];
    }
    else if([countryCode isEqualToString:@"MZ"]){
        cnCode = [NSString stringWithFormat:@"258"];
    }
    else if([countryCode isEqualToString:@"NA"]){
        cnCode = [NSString stringWithFormat:@"264"];
    }
    else if([countryCode isEqualToString:@"NR"]){
        cnCode = [NSString stringWithFormat:@"674"];
    }
    else if([countryCode isEqualToString:@"NP"]){
        cnCode = [NSString stringWithFormat:@"977"];
    }
    else if([countryCode isEqualToString:@"NL"]){
        cnCode = [NSString stringWithFormat:@"31"];
    }
    else if([countryCode isEqualToString:@"NC"]){
        cnCode = [NSString stringWithFormat:@"687"];
    }
    else if([countryCode isEqualToString:@"NZ"]){
        cnCode = [NSString stringWithFormat:@"64"];
    }
    else if([countryCode isEqualToString:@"NI"]){
        cnCode = [NSString stringWithFormat:@"505"];
    }
    else if([countryCode isEqualToString:@"NE"]){
        cnCode = [NSString stringWithFormat:@"227"];
    }
    else if([countryCode isEqualToString:@"NG"]){
        cnCode = [NSString stringWithFormat:@"234"];
    }
    else if([countryCode isEqualToString:@"NU"]){
        cnCode = [NSString stringWithFormat:@"683"];
    }
    else if([countryCode isEqualToString:@"NF"]){
        cnCode = [NSString stringWithFormat:@"672"];
    }
    else if([countryCode isEqualToString:@"KP"]){
        cnCode = [NSString stringWithFormat:@"850"];
    } else if([countryCode isEqualToString:@"MP"]){
        cnCode = [NSString stringWithFormat:@"1670"];
    }
    else if([countryCode isEqualToString:@"NO"]){
        cnCode = [NSString stringWithFormat:@"47"];
    }
    else if([countryCode isEqualToString:@"OM"]){
        cnCode = [NSString stringWithFormat:@"968"];
    }
    else if([countryCode isEqualToString:@"PK"]){
        cnCode = [NSString stringWithFormat:@"92"];
    } else if([countryCode isEqualToString:@"PW"]){
        cnCode = [NSString stringWithFormat:@"680"];
    } else if([countryCode isEqualToString:@"PA"]){
        cnCode = [NSString stringWithFormat:@"507"];
    }
    else if([countryCode isEqualToString:@"PG"]){
        cnCode = [NSString stringWithFormat:@"675"];
    }
    else if([countryCode isEqualToString:@"PY"]){
        cnCode = [NSString stringWithFormat:@"595"];
    }
    else if([countryCode isEqualToString:@"PE"]){
        cnCode = [NSString stringWithFormat:@"51"];
    }
    else if([countryCode isEqualToString:@"PH"]){
        cnCode = [NSString stringWithFormat:@"63"];
    }
    else if([countryCode isEqualToString:@"PN"]){
        cnCode = [NSString stringWithFormat:@"870"];
    } else if([countryCode isEqualToString:@"PL"]){
        cnCode = [NSString stringWithFormat:@"48"];
    } else if([countryCode isEqualToString:@"PT"]){
        cnCode = [NSString stringWithFormat:@"351"];
    }
    else if([countryCode isEqualToString:@"PR"]){
        cnCode = [NSString stringWithFormat:@"1"];
    }
    else if([countryCode isEqualToString:@"QA"]){
        cnCode = [NSString stringWithFormat:@"974"];
    }
    else if([countryCode isEqualToString:@"RO"]){
        cnCode = [NSString stringWithFormat:@"40"];
    }
    else if([countryCode isEqualToString:@"RU"]){
        cnCode = [NSString stringWithFormat:@"7"];
    }
    else if([countryCode isEqualToString:@"RW"]){
        cnCode = [NSString stringWithFormat:@"250"];
    }
    else if([countryCode isEqualToString:@"BL"]){
        cnCode = [NSString stringWithFormat:@"590"];
    }
    else if([countryCode isEqualToString:@"SH"]){
        cnCode = [NSString stringWithFormat:@"290"];
    }
    else if([countryCode isEqualToString:@"KN"]){
        cnCode = [NSString stringWithFormat:@"1869"];
    }
    else if([countryCode isEqualToString:@"LC"]){
        cnCode = [NSString stringWithFormat:@"1758"];
    }
    else if([countryCode isEqualToString:@"MF"]){
        cnCode = [NSString stringWithFormat:@"1599"];
    }
    else if([countryCode isEqualToString:@"WS"]){
        cnCode = [NSString stringWithFormat:@"685"];
    }
    else if([countryCode isEqualToString:@"SM"]){
        cnCode = [NSString stringWithFormat:@"378"];
    }
    else if([countryCode isEqualToString:@"ST"]){
        cnCode = [NSString stringWithFormat:@"239"];
    }
    else if([countryCode isEqualToString:@"SA"]){
        cnCode = [NSString stringWithFormat:@"966"];
    }
    else if([countryCode isEqualToString:@"SN"]){
        cnCode = [NSString stringWithFormat:@"221"];
    }else if([countryCode isEqualToString:@"RS"]){
        cnCode = [NSString stringWithFormat:@"381"];
    }else if([countryCode isEqualToString:@"SC"]){
        cnCode = [NSString stringWithFormat:@"248"];
    }else if([countryCode isEqualToString:@"SL"]){
        cnCode = [NSString stringWithFormat:@"232"];
    }
    else if([countryCode isEqualToString:@"SG"]){
        cnCode = [NSString stringWithFormat:@"65"];
    }
    else if([countryCode isEqualToString:@"SK"]){
        cnCode = [NSString stringWithFormat:@"421"];
    }
    else if([countryCode isEqualToString:@"SI"]){
        cnCode = [NSString stringWithFormat:@"386"];
    }
    else if([countryCode isEqualToString:@"SB"]){
        cnCode = [NSString stringWithFormat:@"677"];
    }
    else if([countryCode isEqualToString:@"SO"]){
        cnCode = [NSString stringWithFormat:@"252"];
    }
    else if([countryCode isEqualToString:@"ZA"]){
        cnCode = [NSString stringWithFormat:@"27"];
    }
    else if([countryCode isEqualToString:@"KR"]){
        cnCode = [NSString stringWithFormat:@"82"];
    }
    else if([countryCode isEqualToString:@"ES"]){
        cnCode = [NSString stringWithFormat:@"34"];
    }
    else if([countryCode isEqualToString:@"LK"]){
        cnCode = [NSString stringWithFormat:@"94"];
    }
    else if([countryCode isEqualToString:@"SD"]){
        cnCode = [NSString stringWithFormat:@"249"];
    }
    else if([countryCode isEqualToString:@"SR"]){
        cnCode = [NSString stringWithFormat:@"597"];
    }
    else if([countryCode isEqualToString:@"SZ"]){
        cnCode = [NSString stringWithFormat:@"268"];
    }
    else if([countryCode isEqualToString:@"SE"]){
        cnCode = [NSString stringWithFormat:@"46"];
    }
    else if([countryCode isEqualToString:@"CH"]){
        cnCode = [NSString stringWithFormat:@"41"];
    }
    else if([countryCode isEqualToString:@"SY"]){
        cnCode = [NSString stringWithFormat:@"963"];
    }
    else if([countryCode isEqualToString:@"TW"]){
        cnCode = [NSString stringWithFormat:@"886"];
    }
    else if([countryCode isEqualToString:@"TJ"]){
        cnCode = [NSString stringWithFormat:@"992"];
    }
    else if([countryCode isEqualToString:@"TZ"]){
        cnCode = [NSString stringWithFormat:@"255"];
    }
    else if([countryCode isEqualToString:@"TH"]){
        cnCode = [NSString stringWithFormat:@"66"];
    }
    else if([countryCode isEqualToString:@"TL"]){
        cnCode = [NSString stringWithFormat:@"670"];
    }
    else if([countryCode isEqualToString:@"TG"]){
        cnCode = [NSString stringWithFormat:@"228"];
    }
    else if([countryCode isEqualToString:@"TK"]){
        cnCode = [NSString stringWithFormat:@"690"];
    }
    else if([countryCode isEqualToString:@"TO"]){
        cnCode = [NSString stringWithFormat:@"676"];
    }
    else if([countryCode isEqualToString:@"TT"]){
        cnCode = [NSString stringWithFormat:@"1868"];
    }
    else if([countryCode isEqualToString:@"TN"]){
        cnCode = [NSString stringWithFormat:@"216"];
    }
    else if([countryCode isEqualToString:@"TR"]){
        cnCode = [NSString stringWithFormat:@"90"];
    }
    else if([countryCode isEqualToString:@"TM"]){
        cnCode = [NSString stringWithFormat:@"993"];
    }
    else if([countryCode isEqualToString:@"TC"]){
        cnCode = [NSString stringWithFormat:@"1649"];
    }
    else if([countryCode isEqualToString:@"TV"]){
        cnCode = [NSString stringWithFormat:@"688"];
    }
    else if([countryCode isEqualToString:@"UG"]){
        cnCode = [NSString stringWithFormat:@"256"];
    }
    else if([countryCode isEqualToString:@"UA"]){
        cnCode = [NSString stringWithFormat:@"380"];
    }
    else if([countryCode isEqualToString:@"AE"]){
        cnCode = [NSString stringWithFormat:@"971"];
    }
    else if([countryCode isEqualToString:@"GB"]){
        cnCode = [NSString stringWithFormat:@"44"];
    }
    else if([countryCode isEqualToString:@"US"]){
        cnCode = [NSString stringWithFormat:@"1"];
    }
    else if([countryCode isEqualToString:@"UY"]){
        cnCode = [NSString stringWithFormat:@"598"];
    }
    else if([countryCode isEqualToString:@"VI"]){
        cnCode = [NSString stringWithFormat:@"1340"];
    }
    else if([countryCode isEqualToString:@"UZ"]){
        cnCode = [NSString stringWithFormat:@"998"];
    }
    else if([countryCode isEqualToString:@"VU"]){
        cnCode = [NSString stringWithFormat:@"678"];
    }
    else if([countryCode isEqualToString:@"VE"]){
        cnCode = [NSString stringWithFormat:@"58"];
    }
    else if([countryCode isEqualToString:@"VN"]){
        cnCode = [NSString stringWithFormat:@"84"];
    }
    else if([countryCode isEqualToString:@"WF"]){
        cnCode = [NSString stringWithFormat:@"681"];
    }
    else if([countryCode isEqualToString:@"YE"]){
        cnCode = [NSString stringWithFormat:@"967"];
    }
    else if([countryCode isEqualToString:@"ZM"]){
        cnCode = [NSString stringWithFormat:@"260"];
    }
    else {
        cnCode = [NSString stringWithFormat:@"263"];
    }
    
    return cnCode;
}


+(BOOL)fileExist:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *localURL = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:localURL])
        return YES;
    else
        return NO;
    
}

+(NSString*)localFileUrl:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *localURL = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    return localURL;
}


@end

