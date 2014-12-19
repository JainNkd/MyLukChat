//
//  SignUpViewController.m
//  LukChat
//
//  Created by Administrator on 26/07/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "SignUpViewController.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface SignUpViewController ()

@property (retain, nonatomic) UIAlertView *alert;

@end

@implementation SignUpViewController
@synthesize pno,dob,country,nameLabel,birthDate,dateSheet,codeLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    myPickerView = [[CountryPicker alloc] initWithFrame:CGRectMake(0, 150, 170, 160)];
    myPickerView.delegate = self;
    myPickerView.showsSelectionIndicator = YES;
    myPickerView.userInteractionEnabled = YES;
    
    country.inputView = myPickerView;
    myToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(inputAccessoryViewDidFinish)];
  
    [myToolbar setItems:[NSArray arrayWithObject: doneButton] animated:NO];
    country.inputAccessoryView = myToolbar;
    
    //Fetch current country
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    
    NSString *countryName = [locale displayNameForKey: NSLocaleCountryCode value: countryCode];
    NSLog(@"country is %@", countryName);
    country.text = countryName;
    
    [self countryPhoneCode];
    
    codeLabel.hidden = YES;
    nameLabel.hidden = YES;

    
    pnTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:pnTab];
    
    [self.checkBoxButton setImage:[UIImage imageNamed:@"signup-terms-checkbox-normal-view.png"] forState:UIControlStateNormal];
    [self.checkBoxButton setImage:[UIImage imageNamed:@"signup-terms-checkbox-selection.png"] forState:UIControlStateSelected];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)inputAccessoryViewDidFinish{
    //myToolbar.hidden = YES;
    // myPickerView.hidden = YES;
    [self.view endEditing:YES];
    
}

-(void)dismissKeyboard {
    [pno resignFirstResponder];
    [dob resignFirstResponder];
    [self.view addGestureRecognizer:pnTab];
    [pikerView removeFromSuperview];
    pikerView = nil;
    
}
-(void)setBirth{
    
    [self.view removeGestureRecognizer:pnTab];
    
    [pno resignFirstResponder];
    [pikerView removeFromSuperview];
    pikerView = nil;
    
    pikerView = [[UIView alloc]initWithFrame:CGRectMake(0,534, 320,234)];
    [pikerView setBackgroundColor:[UIColor clearColor]];
    
    UIToolbar *controlToolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0,0, pikerView.bounds.size.width, 44)];

    [controlToolBar sizeToFit];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *setButton = [[UIBarButtonItem alloc] initWithTitle:@"Set" style:UIBarButtonItemStyleDone target:self action:@selector(dismissDateSet)];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelDateSet)];
    
    [controlToolBar setItems:[NSArray arrayWithObjects:spacer, cancelButton, setButton, nil] animated:NO];
    
    [pikerView addSubview:controlToolBar];

    UIDatePicker *birthDayPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,44, 320, 200)];
    [birthDayPicker setBackgroundColor:[UIColor whiteColor] ];
    [birthDayPicker setDatePickerMode:UIDatePickerModeDate];
    [pikerView addSubview:birthDayPicker];
    
    [self.view addSubview:pikerView];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.5];
    
    CGRect frame= pikerView.frame;
    pikerView.frame = CGRectMake(0, 334, frame.size.width, frame.size.height);
    
    [UIView commitAnimations];

}

-(void)cancelDateSet{
   
    [self.view addGestureRecognizer:pnTab];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.5];
    
    CGRect frame= pikerView.frame;
    pikerView.frame = CGRectMake(0, 568, frame.size.width, frame.size.height);
    
    [UIView commitAnimations];
    [self.view endEditing:YES];
}

-(void)dismissDateSet{
    NSArray *listOfViews = [pikerView subviews];
    
    for(UIView *subView in listOfViews){
        if([subView isKindOfClass:[UIDatePicker class]]){
            self.birthDate = [(UIDatePicker *)subView date];
        }
        
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd/MM/YYYY"];
    [dob setText:[dateFormatter stringFromDate:self.birthDate]];

    [self cancelDateSet];
}

- (void)countryPicker:(__unused CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code
{
    country.text = name;
    nameLabel.text = name;
    codeLabel.text = code;
    [self countryPhoneCode];
    
}


-(void)countryPhoneCode
{
    if([nameLabel.text isEqualToString:@"India"]){
        cnCode = [NSString stringWithFormat:@"91"];
    }
    else if([nameLabel.text isEqualToString:@"Germany"]){
        cnCode = [NSString stringWithFormat:@"49"];
    }
    else if([nameLabel.text isEqualToString:@"Afghanistan"]){
        cnCode = [NSString stringWithFormat:@"93"];
    }
    else if([nameLabel.text isEqualToString:@"Albania"]){
        cnCode = [NSString stringWithFormat:@"355"];
    }
    else if([nameLabel.text isEqualToString:@"Algeria"]){
        cnCode = [NSString stringWithFormat:@"213"];
    }
    else if([nameLabel.text isEqualToString:@"American Samoa"]){
        cnCode = [NSString stringWithFormat:@"1684"];
    }
    else if([nameLabel.text isEqualToString:@"Andorra"]){
        cnCode = [NSString stringWithFormat:@"376"];
    }
    else if([nameLabel.text isEqualToString:@"Angola"]){
        cnCode = [NSString stringWithFormat:@"244"];
    }
    else if([nameLabel.text isEqualToString:@"Anguilla"]){
        cnCode = [NSString stringWithFormat:@"1264"];
    }
    else if([nameLabel.text isEqualToString:@"Antarctica"]){
        cnCode = [NSString stringWithFormat:@"672"];
    }
    else if([nameLabel.text isEqualToString:@"Antigua and Barbuda"]){
        cnCode = [NSString stringWithFormat:@"1268"];
    }
    else if([nameLabel.text isEqualToString:@"Argentina"]){
        cnCode = [NSString stringWithFormat:@"54"];
    }
    else if([nameLabel.text isEqualToString:@"Armenia"]){
        cnCode = [NSString stringWithFormat:@"374"];
    }
    else if([nameLabel.text isEqualToString:@"Aruba"]){
        cnCode = [NSString stringWithFormat:@"297"];
    }
    else if([nameLabel.text isEqualToString:@"Australia"]){
        cnCode = [NSString stringWithFormat:@"61"];
    }
    else if([nameLabel.text isEqualToString:@"Austria"]){
        cnCode = [NSString stringWithFormat:@"43"];
    }
    else if([nameLabel.text isEqualToString:@"Azerbaijan"]){
        cnCode = [NSString stringWithFormat:@"994"];
    }
    else if([nameLabel.text isEqualToString:@"Bahamas"]){
        cnCode = [NSString stringWithFormat:@"1242"];
    }
    else if([nameLabel.text isEqualToString:@"Bahrain"]){
        cnCode = [NSString stringWithFormat:@"973"];
    }
    else if([nameLabel.text isEqualToString:@"Bangladesh"]){
        cnCode = [NSString stringWithFormat:@"880"];
    }
    else if([nameLabel.text isEqualToString:@"Barbados"]){
        cnCode = [NSString stringWithFormat:@"1246"];
    }
    else if([nameLabel.text isEqualToString:@"Belarus"]){
        cnCode = [NSString stringWithFormat:@"375"];
    }
    else if([nameLabel.text isEqualToString:@"Belgium"]){
        cnCode = [NSString stringWithFormat:@"32"];
    }
    else if([nameLabel.text isEqualToString:@"Belize"]){
        cnCode = [NSString stringWithFormat:@"501"];
    }
    else if([nameLabel.text isEqualToString:@"Benin"]){
        cnCode = [NSString stringWithFormat:@"229"];
    }
    else if([nameLabel.text isEqualToString:@"Bermuda"]){
        cnCode = [NSString stringWithFormat:@"1441"];
    }
    else if([nameLabel.text isEqualToString:@"Bhutan"]){
        cnCode = [NSString stringWithFormat:@"975"];
    }
    else if([nameLabel.text isEqualToString:@"Bolivia"]){
        cnCode = [NSString stringWithFormat:@"591"];
    }
    else if([nameLabel.text isEqualToString:@"Bosnia and Herzegovina"]){
        cnCode = [NSString stringWithFormat:@"387"];
    }
    else if([nameLabel.text isEqualToString:@"Botswana"]){
        cnCode = [NSString stringWithFormat:@"267"];
    }
    else if([nameLabel.text isEqualToString:@"Brazil"]){
        cnCode = [NSString stringWithFormat:@"55"];
    }
    else if([nameLabel.text isEqualToString:@"British Virgin Islands"]){
        cnCode = [NSString stringWithFormat:@"1284"];
    }
    else if([nameLabel.text isEqualToString:@"Brunei"]){
        cnCode = [NSString stringWithFormat:@"673"];
    }
    else if([nameLabel.text isEqualToString:@"Bulgaria"]){
        cnCode = [NSString stringWithFormat:@"359"];
    }
    else if([nameLabel.text isEqualToString:@"Burkina Faso"]){
        cnCode = [NSString stringWithFormat:@"226"];
    }
    else if([nameLabel.text isEqualToString:@"Burma(Myanmar)"]){
        cnCode = [NSString stringWithFormat:@"95"];
    }
    else if([nameLabel.text isEqualToString:@"Burundi"]){
        cnCode = [NSString stringWithFormat:@"257"];
    }
    else if([nameLabel.text isEqualToString:@"Cambodia"]){
        cnCode = [NSString stringWithFormat:@"855"];
    }
    else if([nameLabel.text isEqualToString:@"Cameroon"]){
        cnCode = [NSString stringWithFormat:@"237"];
    }
    else if([nameLabel.text isEqualToString:@"Canada"]){
        cnCode = [NSString stringWithFormat:@"1"];
    }
    else if([nameLabel.text isEqualToString:@"Cape Verde"]){
        cnCode = [NSString stringWithFormat:@"238"];
    }
    else if([nameLabel.text isEqualToString:@"Cayman Islands"]){
        cnCode = [NSString stringWithFormat:@"1345"];
    }
    else if([nameLabel.text isEqualToString:@"Central African Republic"]){
        cnCode = [NSString stringWithFormat:@"236"];
    }
    else if([nameLabel.text isEqualToString:@"Chad"]){
        cnCode = [NSString stringWithFormat:@"235"];
    }
    else if([nameLabel.text isEqualToString:@"Chile"]){
        cnCode = [NSString stringWithFormat:@"56"];
    }
    else if([nameLabel.text isEqualToString:@"China"]){
        cnCode = [NSString stringWithFormat:@"86"];
    }
    else if([nameLabel.text isEqualToString:@"Christmas Island"]){
        cnCode = [NSString stringWithFormat:@"61"];
    }
    else if([nameLabel.text isEqualToString:@"Cocos(Keeling) Islands"]){
        cnCode = [NSString stringWithFormat:@"61"];
    }
    else if([nameLabel.text isEqualToString:@"Colombia"]){
        cnCode = [NSString stringWithFormat:@"57"];
    }
    else if([nameLabel.text isEqualToString:@"Comoros"]){
        cnCode = [NSString stringWithFormat:@"269"];
    }
    else if([nameLabel.text isEqualToString:@"Cook Islands"]){
        cnCode = [NSString stringWithFormat:@"682"];
    }
    else if([nameLabel.text isEqualToString:@"Costa Rica"]){
        cnCode = [NSString stringWithFormat:@"506"];
    }
    else if([nameLabel.text isEqualToString:@"Croatia"]){
        cnCode = [NSString stringWithFormat:@"385"];
    }
    else if([nameLabel.text isEqualToString:@"Cuba"]){
        cnCode = [NSString stringWithFormat:@"53"];
    }
    else if([nameLabel.text isEqualToString:@"Cyprus"]){
        cnCode = [NSString stringWithFormat:@"357"];
    }
    else if([nameLabel.text isEqualToString:@"Denmark"]){
        cnCode = [NSString stringWithFormat:@"45"];
    }
    else if([nameLabel.text isEqualToString:@"Djibouti"]){
        cnCode = [NSString stringWithFormat:@"253"];
    }
    else if([nameLabel.text isEqualToString:@"Dominica"]){
        cnCode = [NSString stringWithFormat:@"1767"];
    }
    else if([nameLabel.text isEqualToString:@"Ecuador"]){
        cnCode = [NSString stringWithFormat:@"593"];
    }
    else if([nameLabel.text isEqualToString:@"Egypt"]){
        cnCode = [NSString stringWithFormat:@"20"];
    }
    else if([nameLabel.text isEqualToString:@"EI Salvador"]){
        cnCode = [NSString stringWithFormat:@"503"];
    }
    else if([nameLabel.text isEqualToString:@"Equatorial Guinea"]){
        cnCode = [NSString stringWithFormat:@"240"];
    }
    else if([nameLabel.text isEqualToString:@"Eritrea"]){
        cnCode = [NSString stringWithFormat:@"291"];
    }else if([nameLabel.text isEqualToString:@"Estonia"]){
        cnCode = [NSString stringWithFormat:@"372"];
    }
    else if([nameLabel.text isEqualToString:@"Ethiopia"]){
        cnCode = [NSString stringWithFormat:@"251"];
    }
    else if([nameLabel.text isEqualToString:@"Falkland Islands"]){
        cnCode = [NSString stringWithFormat:@"500"];
    }
    else if([nameLabel.text isEqualToString:@"Faroe Islands"]){
        cnCode = [NSString stringWithFormat:@"298"];
    }
    else if([nameLabel.text isEqualToString:@"Fiji"]){
        cnCode = [NSString stringWithFormat:@"679"];
    }else if([nameLabel.text isEqualToString:@"Finland"]){
        cnCode = [NSString stringWithFormat:@"358"];
    }
    else if([nameLabel.text isEqualToString:@"France"]){
        cnCode = [NSString stringWithFormat:@"33"];
    }
    else if([nameLabel.text isEqualToString:@"French Polynesia"]){
        cnCode = [NSString stringWithFormat:@"689"];
    }
    else if([nameLabel.text isEqualToString:@"Gabon"]){
        cnCode = [NSString stringWithFormat:@"241"];
    }
    else if([nameLabel.text isEqualToString:@"Gambia"]){
        cnCode = [NSString stringWithFormat:@"220"];
    }
    else if([nameLabel.text isEqualToString:@"Gaza Strip"]){
        cnCode = [NSString stringWithFormat:@"970"];
    }
    else if([nameLabel.text isEqualToString:@"Georgia"]){
        cnCode = [NSString stringWithFormat:@"995"];
    }
    else if([nameLabel.text isEqualToString:@"Ghana"]){
        cnCode = [NSString stringWithFormat:@"233"];
    }
    else if([nameLabel.text isEqualToString:@"Gibraltar"]){
        cnCode = [NSString stringWithFormat:@"350"];
    }
    else if([nameLabel.text isEqualToString:@"Greece"]){
        cnCode = [NSString stringWithFormat:@"30"];
    }
    else if([nameLabel.text isEqualToString:@"Greenland"]){
        cnCode = [NSString stringWithFormat:@"299"];
    }
    else if([nameLabel.text isEqualToString:@"Grenada"]){
        cnCode = [NSString stringWithFormat:@"1473"];
    } else if([nameLabel.text isEqualToString:@"Guam"]){
        cnCode = [NSString stringWithFormat:@"1671"];
    }
    else if([nameLabel.text isEqualToString:@"Guatemala"]){
        cnCode = [NSString stringWithFormat:@"502"];
    }
    else if([nameLabel.text isEqualToString:@"Guinea"]){
        cnCode = [NSString stringWithFormat:@"224"];
    }
    else if([nameLabel.text isEqualToString:@"Guyana"]){
        cnCode = [NSString stringWithFormat:@"592"];
    }
    else if([nameLabel.text isEqualToString:@"Haiti"]){
        cnCode = [NSString stringWithFormat:@"509"];
    }
    else if([nameLabel.text isEqualToString:@"Holy See(Vatican City)"]){
        cnCode = [NSString stringWithFormat:@"39"];
    }
    else if([nameLabel.text isEqualToString:@"Honduras"]){
        cnCode = [NSString stringWithFormat:@"504"];
    } else if([nameLabel.text isEqualToString:@"Hong Kong"]){
        cnCode = [NSString stringWithFormat:@"852"];
    }
    else if([nameLabel.text isEqualToString:@"Hungary"]){
        cnCode = [NSString stringWithFormat:@"36"];
    } else if([nameLabel.text isEqualToString:@"Iceland"]){
        cnCode = [NSString stringWithFormat:@"354"];
    }
    else if([nameLabel.text isEqualToString:@"Indonesia"]){
        cnCode = [NSString stringWithFormat:@"62"];
    }
    else if([nameLabel.text isEqualToString:@"Iran"]){
        cnCode = [NSString stringWithFormat:@"98"];
    }
    else if([nameLabel.text isEqualToString:@"Iraq"]){
        cnCode = [NSString stringWithFormat:@"964"];
    }
    else if([nameLabel.text isEqualToString:@"Ireland"]){
        cnCode = [NSString stringWithFormat:@"353"];
    }
    else if([nameLabel.text isEqualToString:@"Isle of Man"]){
        cnCode = [NSString stringWithFormat:@"44"];
    }
    else if([nameLabel.text isEqualToString:@"Israel"]){
        cnCode = [NSString stringWithFormat:@"972"];
    } else if([nameLabel.text isEqualToString:@"Italy"]){
        cnCode = [NSString stringWithFormat:@"39"];
    }
    else if([nameLabel.text isEqualToString:@"Ivory Coast"]){
        cnCode = [NSString stringWithFormat:@"225"];
    }
    else if([nameLabel.text isEqualToString:@"Jamaica"]){
        cnCode = [NSString stringWithFormat:@"1876"];
    } else if([nameLabel.text isEqualToString:@"Japan"]){
        cnCode = [NSString stringWithFormat:@"81"];
    }
    else if([nameLabel.text isEqualToString:@"Jordan"]){
        cnCode = [NSString stringWithFormat:@"962"];
    }
    else if([nameLabel.text isEqualToString:@"Kazakhstan"]){
        cnCode = [NSString stringWithFormat:@"7"];
    }
    else if([nameLabel.text isEqualToString:@"Kenya"]){
        cnCode = [NSString stringWithFormat:@"254"];
    }
    else if([nameLabel.text isEqualToString:@"Kiribati"]){
        cnCode = [NSString stringWithFormat:@"686"];
    }
    else if([nameLabel.text isEqualToString:@"Kosovo"]){
        cnCode = [NSString stringWithFormat:@"381"];
    }
    else if([nameLabel.text isEqualToString:@"Kuwait"]){
        cnCode = [NSString stringWithFormat:@"965"];
    }
    else if([nameLabel.text isEqualToString:@"Kyrgyzstan"]){
        cnCode = [NSString stringWithFormat:@"996"];
    }
    else if([nameLabel.text isEqualToString:@"Laos"]){
        cnCode = [NSString stringWithFormat:@"856"];
    }
    else if([nameLabel.text isEqualToString:@"Latvia"]){
        cnCode = [NSString stringWithFormat:@"371"];
    }
    else if([nameLabel.text isEqualToString:@"Lebanon"]){
        cnCode = [NSString stringWithFormat:@"961"];
    }
    else if([nameLabel.text isEqualToString:@"Lesotho"]){
        cnCode = [NSString stringWithFormat:@"266"];
    }
    else if([nameLabel.text isEqualToString:@"Liberia"]){
        cnCode = [NSString stringWithFormat:@"231"];
    }
    else if([nameLabel.text isEqualToString:@"Libya"]){
        cnCode = [NSString stringWithFormat:@"218"];
    }
    else if([nameLabel.text isEqualToString:@"Lithuania"]){
        cnCode = [NSString stringWithFormat:@"370"];
    }
    else if([nameLabel.text isEqualToString:@"Luxembourg"]){
        cnCode = [NSString stringWithFormat:@"352"];
    }
    else if([nameLabel.text isEqualToString:@"Macau"]){
        cnCode = [NSString stringWithFormat:@"853"];
    }
    else if([nameLabel.text isEqualToString:@"Macedonia"]){
        cnCode = [NSString stringWithFormat:@"389"];
    }
    else if([nameLabel.text isEqualToString:@"Madagascar"]){
        cnCode = [NSString stringWithFormat:@"261"];
    }
    else if([nameLabel.text isEqualToString:@"Malawi"]){
        cnCode = [NSString stringWithFormat:@"265"];
    }
    else if([nameLabel.text isEqualToString:@"Malaysia"]){
        cnCode = [NSString stringWithFormat:@"60"];
    }
    else if([nameLabel.text isEqualToString:@"Maldives"]){
        cnCode = [NSString stringWithFormat:@"960"];
    }
    else if([nameLabel.text isEqualToString:@"Mali"]){
        cnCode = [NSString stringWithFormat:@"223"];
    }
    else if([nameLabel.text isEqualToString:@"Malta"]){
        cnCode = [NSString stringWithFormat:@"356"];
    }
    else if([nameLabel.text isEqualToString:@"Marshall Islands"]){
        cnCode = [NSString stringWithFormat:@"692"];
    }
    else if([nameLabel.text isEqualToString:@"Mauritania"]){
        cnCode = [NSString stringWithFormat:@"222"];
    }
    else if([nameLabel.text isEqualToString:@"Mauritius"]){
        cnCode = [NSString stringWithFormat:@"230"];
    }
    else if([nameLabel.text isEqualToString:@"Mayotte"]){
        cnCode = [NSString stringWithFormat:@"262"];
    }
    else if([nameLabel.text isEqualToString:@"Mexico"]){
        cnCode = [NSString stringWithFormat:@"52"];
    }
    else if([nameLabel.text isEqualToString:@"Micronesia"]){
        cnCode = [NSString stringWithFormat:@"691"];
    }
    else if([nameLabel.text isEqualToString:@"Moldova"]){
        cnCode = [NSString stringWithFormat:@"373"];
    }
    else if([nameLabel.text isEqualToString:@"Monaco"]){
        cnCode = [NSString stringWithFormat:@"377"];
    }
    else if([nameLabel.text isEqualToString:@"Mongolia"]){
        cnCode = [NSString stringWithFormat:@"976"];
    }
    else if([nameLabel.text isEqualToString:@"Montserrat"]){
        cnCode = [NSString stringWithFormat:@"1664"];
    }
    else if([nameLabel.text isEqualToString:@"Morocco"]){
        cnCode = [NSString stringWithFormat:@"212"];
    }
    else if([nameLabel.text isEqualToString:@"Mozambique"]){
        cnCode = [NSString stringWithFormat:@"258"];
    }
    else if([nameLabel.text isEqualToString:@"Namibia"]){
        cnCode = [NSString stringWithFormat:@"264"];
    }
    else if([nameLabel.text isEqualToString:@"Nauru"]){
        cnCode = [NSString stringWithFormat:@"674"];
    }
    else if([nameLabel.text isEqualToString:@"Nepal"]){
        cnCode = [NSString stringWithFormat:@"977"];
    }
    else if([nameLabel.text isEqualToString:@"Netherlands"]){
        cnCode = [NSString stringWithFormat:@"31"];
    }
    else if([nameLabel.text isEqualToString:@"Netherlands Antilles"]){
        cnCode = [NSString stringWithFormat:@"599"];
    }
    else if([nameLabel.text isEqualToString:@"New Caledonia"]){
        cnCode = [NSString stringWithFormat:@"687"];
    }
    else if([nameLabel.text isEqualToString:@"New Zealand"]){
        cnCode = [NSString stringWithFormat:@"64"];
    }
    else if([nameLabel.text isEqualToString:@"Nicaragua"]){
        cnCode = [NSString stringWithFormat:@"505"];
    }
    else if([nameLabel.text isEqualToString:@"Niger"]){
        cnCode = [NSString stringWithFormat:@"227"];
    }
    else if([nameLabel.text isEqualToString:@"Nigeria"]){
        cnCode = [NSString stringWithFormat:@"234"];
    }
    else if([nameLabel.text isEqualToString:@"Niue"]){
        cnCode = [NSString stringWithFormat:@"683"];
    }
    else if([nameLabel.text isEqualToString:@"Norfolk Island"]){
        cnCode = [NSString stringWithFormat:@"672"];
    }
    else if([nameLabel.text isEqualToString:@"North Korea"]){
        cnCode = [NSString stringWithFormat:@"850"];
    } else if([nameLabel.text isEqualToString:@"Northern Mariana Islands"]){
        cnCode = [NSString stringWithFormat:@"1670"];
    }
    else if([nameLabel.text isEqualToString:@"Norway"]){
        cnCode = [NSString stringWithFormat:@"47"];
    }
    else if([nameLabel.text isEqualToString:@"Oman"]){
        cnCode = [NSString stringWithFormat:@"968"];
    }
    else if([nameLabel.text isEqualToString:@"Pakistan"]){
        cnCode = [NSString stringWithFormat:@"92"];
    } else if([nameLabel.text isEqualToString:@"Palau"]){
        cnCode = [NSString stringWithFormat:@"680"];
    } else if([nameLabel.text isEqualToString:@"Panama"]){
        cnCode = [NSString stringWithFormat:@"507"];
    }
    else if([nameLabel.text isEqualToString:@"Papua New Guinea"]){
        cnCode = [NSString stringWithFormat:@"675"];
    }
    else if([nameLabel.text isEqualToString:@"Paraguay"]){
        cnCode = [NSString stringWithFormat:@"595"];
    }
    else if([nameLabel.text isEqualToString:@"Peru"]){
        cnCode = [NSString stringWithFormat:@"51"];
    }
    else if([nameLabel.text isEqualToString:@"Philippines"]){
        cnCode = [NSString stringWithFormat:@"63"];
    }
    else if([nameLabel.text isEqualToString:@"Pitcairn Islands"]){
        cnCode = [NSString stringWithFormat:@"870"];
    } else if([nameLabel.text isEqualToString:@"Poland"]){
        cnCode = [NSString stringWithFormat:@"48"];
    } else if([nameLabel.text isEqualToString:@"Portugal"]){
        cnCode = [NSString stringWithFormat:@"351"];
    }
    else if([nameLabel.text isEqualToString:@"Puerto Rico"]){
        cnCode = [NSString stringWithFormat:@"1"];
    }
    else if([nameLabel.text isEqualToString:@"Qatar"]){
        cnCode = [NSString stringWithFormat:@"974"];
    }
    else if([nameLabel.text isEqualToString:@"Republic of the Congo"]){
        cnCode = [NSString stringWithFormat:@"242"];
    } else if([nameLabel.text isEqualToString:@"Romania"]){
        cnCode = [NSString stringWithFormat:@"40"];
    }
    else if([nameLabel.text isEqualToString:@"Russia"]){
        cnCode = [NSString stringWithFormat:@"7"];
    }
    else if([nameLabel.text isEqualToString:@"Rwanda"]){
        cnCode = [NSString stringWithFormat:@"250"];
    }
    else if([nameLabel.text isEqualToString:@"Saint Barthelemy"]){
        cnCode = [NSString stringWithFormat:@"590"];
    }
    else if([nameLabel.text isEqualToString:@"Saint Helena"]){
        cnCode = [NSString stringWithFormat:@"290"];
    }
    else if([nameLabel.text isEqualToString:@"Saint Kitts and Nevis"]){
        cnCode = [NSString stringWithFormat:@"1869"];
    }
    else if([nameLabel.text isEqualToString:@"Saint Lucia"]){
        cnCode = [NSString stringWithFormat:@"1758"];
    }
    else if([nameLabel.text isEqualToString:@"Saint Martin"]){
        cnCode = [NSString stringWithFormat:@"1599"];
    }
    else if([nameLabel.text isEqualToString:@"Samoa"]){
        cnCode = [NSString stringWithFormat:@"685"];
    }
    else if([nameLabel.text isEqualToString:@"San Marino"]){
        cnCode = [NSString stringWithFormat:@"378"];
    }
    else if([nameLabel.text isEqualToString:@"Sao Tome and Principe"]){
        cnCode = [NSString stringWithFormat:@"239"];
    }
    else if([nameLabel.text isEqualToString:@"Saudi Arabia"]){
        cnCode = [NSString stringWithFormat:@"966"];
    }
    else if([nameLabel.text isEqualToString:@"Senegal"]){
        cnCode = [NSString stringWithFormat:@"221"];
    }else if([nameLabel.text isEqualToString:@"Serbia"]){
        cnCode = [NSString stringWithFormat:@"381"];
    }else if([nameLabel.text isEqualToString:@"Seychelles"]){
        cnCode = [NSString stringWithFormat:@"248"];
    }else if([nameLabel.text isEqualToString:@"Sierra Leone"]){
        cnCode = [NSString stringWithFormat:@"232"];
    }
    else if([nameLabel.text isEqualToString:@"Singapore"]){
        cnCode = [NSString stringWithFormat:@"65"];
    }
    else if([nameLabel.text isEqualToString:@"Slovakia"]){
        cnCode = [NSString stringWithFormat:@"421"];
    }
    else if([nameLabel.text isEqualToString:@"Slovenia"]){
        cnCode = [NSString stringWithFormat:@"386"];
    }
    else if([nameLabel.text isEqualToString:@"Solomon Islands"]){
        cnCode = [NSString stringWithFormat:@"677"];
    }
    else if([nameLabel.text isEqualToString:@"Somalia"]){
        cnCode = [NSString stringWithFormat:@"252"];
    }
    else if([nameLabel.text isEqualToString:@"South Africa"]){
        cnCode = [NSString stringWithFormat:@"27"];
    }
    else if([nameLabel.text isEqualToString:@"South Korea"]){
        cnCode = [NSString stringWithFormat:@"82"];
    }
    else if([nameLabel.text isEqualToString:@"Spain"]){
        cnCode = [NSString stringWithFormat:@"34"];
    }
    else if([nameLabel.text isEqualToString:@"SriLanka"]){
        cnCode = [NSString stringWithFormat:@"94"];
    }
    else if([nameLabel.text isEqualToString:@"Sudan"]){
        cnCode = [NSString stringWithFormat:@"249"];
    }
    else if([nameLabel.text isEqualToString:@"Suriname"]){
        cnCode = [NSString stringWithFormat:@"597"];
    }
    else if([nameLabel.text isEqualToString:@"Swaziland"]){
        cnCode = [NSString stringWithFormat:@"268"];
    }
    else if([nameLabel.text isEqualToString:@"Sweden"]){
        cnCode = [NSString stringWithFormat:@"46"];
    }
    else if([nameLabel.text isEqualToString:@"Switzerland"]){
        cnCode = [NSString stringWithFormat:@"41"];
    }
    else if([nameLabel.text isEqualToString:@"Syria"]){
        cnCode = [NSString stringWithFormat:@"963"];
    }
    else if([nameLabel.text isEqualToString:@"Taiwan"]){
        cnCode = [NSString stringWithFormat:@"886"];
    }
    else if([nameLabel.text isEqualToString:@"Tajikistan"]){
        cnCode = [NSString stringWithFormat:@"992"];
    }
    else if([nameLabel.text isEqualToString:@"Tanzania"]){
        cnCode = [NSString stringWithFormat:@"255"];
    }
    else if([nameLabel.text isEqualToString:@"Tahiland"]){
        cnCode = [NSString stringWithFormat:@"66"];
    }
    else if([nameLabel.text isEqualToString:@"Timor-Leste"]){
        cnCode = [NSString stringWithFormat:@"670"];
    }
    else if([nameLabel.text isEqualToString:@"Togo"]){
        cnCode = [NSString stringWithFormat:@"228"];
    }
    else if([nameLabel.text isEqualToString:@"Tokelau"]){
        cnCode = [NSString stringWithFormat:@"690"];
    }
    else if([nameLabel.text isEqualToString:@"Tonga"]){
        cnCode = [NSString stringWithFormat:@"676"];
    }
    else if([nameLabel.text isEqualToString:@"Trinidad and Tobago"]){
        cnCode = [NSString stringWithFormat:@"1868"];
    }
    else if([nameLabel.text isEqualToString:@"Tunisia"]){
        cnCode = [NSString stringWithFormat:@"216"];
    }
    else if([nameLabel.text isEqualToString:@"Turkey"]){
        cnCode = [NSString stringWithFormat:@"90"];
    }
    else if([nameLabel.text isEqualToString:@"Turkmenistan"]){
        cnCode = [NSString stringWithFormat:@"993"];
    }
    else if([nameLabel.text isEqualToString:@"Turks and caicos Islands"]){
        cnCode = [NSString stringWithFormat:@"1649"];
    }
    else if([nameLabel.text isEqualToString:@"Tuvalu"]){
        cnCode = [NSString stringWithFormat:@"688"];
    }
    else if([nameLabel.text isEqualToString:@"Uganda"]){
        cnCode = [NSString stringWithFormat:@"256"];
    }
    else if([nameLabel.text isEqualToString:@"Ukraine"]){
        cnCode = [NSString stringWithFormat:@"380"];
    }
    else if([nameLabel.text isEqualToString:@"United Arab Emirates"]){
        cnCode = [NSString stringWithFormat:@"971"];
    }
    else if([nameLabel.text isEqualToString:@"United Kingdom"]){
        cnCode = [NSString stringWithFormat:@"44"];
    }
    else if([nameLabel.text isEqualToString:@"United States"]){
        cnCode = [NSString stringWithFormat:@"1"];
    }
    else if([nameLabel.text isEqualToString:@"Uruguay"]){
        cnCode = [NSString stringWithFormat:@"598"];
    }
    else if([nameLabel.text isEqualToString:@"US Virgin Islands"]){
        cnCode = [NSString stringWithFormat:@"1340"];
    }
    else if([nameLabel.text isEqualToString:@"Uzbekistan"]){
        cnCode = [NSString stringWithFormat:@"998"];
    }
    else if([nameLabel.text isEqualToString:@"Vanuatu"]){
        cnCode = [NSString stringWithFormat:@"678"];
    }
    else if([nameLabel.text isEqualToString:@"Venezuela"]){
        cnCode = [NSString stringWithFormat:@"58"];
    }
    else if([nameLabel.text isEqualToString:@"Vietnam"]){
        cnCode = [NSString stringWithFormat:@"84"];
    }
    else if([nameLabel.text isEqualToString:@"Wallis and Futuna"]){
        cnCode = [NSString stringWithFormat:@"681"];
    }
    else if([nameLabel.text isEqualToString:@"West Bank"]){
        cnCode = [NSString stringWithFormat:@"970"];
    }
    else if([nameLabel.text isEqualToString:@"Yemen"]){
        cnCode = [NSString stringWithFormat:@"967"];
    }
    else if([nameLabel.text isEqualToString:@"Zambia"]){
        cnCode = [NSString stringWithFormat:@"260"];
    }
    else {
        cnCode = [NSString stringWithFormat:@"263"];
    }
    if([country.text isEqualToString:@"India"]){
        cnCode = [NSString stringWithFormat:@"91"];
    }
    else if([country.text isEqualToString:@"Germany"]){
        cnCode = [NSString stringWithFormat:@"49"];
    }
    
    self.mobileCountryCode.text = cnCode;
    

}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self setBirth];
    return NO;
}

-(IBAction)clear:(id)sender

{
    country.placeholder=@"";
}

-(IBAction)DoneClicked:(id)sender{
    [pno resignFirstResponder];
}

-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

-(IBAction)textFielddidendediting:(id)sender{
    country.placeholder = @"";
    [sender resignFirstResponder];
    
}



- (IBAction)verifyButtonPressed:(id)sender {
    if (pno.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Enter Phone Number"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    if (dob.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Enter Date of Birth"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if(!self.checkBoxButton.selected)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Follow terms and conditions."
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    app.number = pno.text;
    
    NSString *str = pno.text;
    if ([[str substringToIndex:1] isEqualToString:@"0"])  {
        
        str = [str substringFromIndex:1];
        NSLog(@"string is %@",str);
    }
    else{
        NSString *str = pno.text;
        NSLog(@"string is %@",str);
    }
    
    
    int number = (arc4random()%100)+1000; //Generates Number from 1 to 100.
    NSString *string = [NSString stringWithFormat:@"%i", number];
    NSLog(@"random number is %@",string);
    app.pinValue = string;
    
    [[NSUserDefaults standardUserDefaults] setValue:string forKey:kMY_VERIFICATION_CODE];
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@%@",cnCode,str] forKey:kMYPhoneNumber];
    [[NSUserDefaults standardUserDefaults] setValue:dob.text forKey:kMYDOB];
    
    NSURL *targetURL = [NSURL URLWithString:@"https://rest.nexmo.com/sms/json"];
    NSString *postbody = [NSString stringWithFormat:@"api_key=4cc0a6c5&api_secret=041bc169&text=Welcome to Luk! Your verification code is %@&to=%@%@&from=Luk",string,cnCode,str];
    NSData *postData = [postbody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:targetURL];
    [request setHTTPMethod:@"post"];
    //[request setValue:@"application/x-www-form-urlencoded" forKey:@"content-Type"];
    [request setValue:postLength forHTTPHeaderField:@"content-length"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response =nil;
    NSError *errorReturned = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&errorReturned];
    
    if(errorReturned){
        NSLog(@"error");
    }
    else{
        NSError *jsonParsingError = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&jsonParsingError];
        NSLog(@"json array is %@",jsonArray);
        
        [self performSegueWithIdentifier:@"Confirmation" sender:self];
    }
}

- (IBAction)checkboxButtonPressed:(UIButton *)sender {
    NSLog(@"CheckBox,........");
    self.checkBoxButton.selected = !self.checkBoxButton.selected;

}

- (IBAction)termsAndConditionButtonPressed:(id)sender {
    
     [self performSegueWithIdentifier:@"TermsAndConditions" sender:self];
}
@end
