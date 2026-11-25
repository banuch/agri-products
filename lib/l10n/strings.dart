import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../state/language_controller.dart';

/// All user-facing text, English and Telugu side by side so a Telugu
/// speaker can review every line in one place.
///
/// Usage: `final s = S.of(context); Text(s.login)`.
class S {
  const S(this.isTelugu);

  final bool isTelugu;

  static S of(BuildContext context) =>
      S(context.watch<LanguageController>().isTelugu);

  /// Same as [of] but does not subscribe to changes (for callbacks).
  static S read(BuildContext context) =>
      S(context.read<LanguageController>().isTelugu);

  String _t(String en, String te) => isTelugu ? te : en;

  // ---------- App / language ----------
  String get appName => _t('Agriculture Society', 'అగ్రికల్చర్ సొసైటీ');
  String get tagline => _t('A digital initiative to transform agriculture in India',
      'భారత వ్యవసాయాన్ని మార్చే డిజిటల్ ప్రయత్నం');
  String get chooseLanguage => _t('Choose your language', 'మీ భాషను ఎంచుకోండి');
  String get language => _t('Language', 'భాష');
  String get welcomeTo => _t('Welcome to', 'స్వాగతం');
  String get getStarted => _t('Get Started', 'మొదలు పెట్టండి');

  // ---------- Role ----------
  String get whoAreYou => _t('Who are you?', 'మీరు ఎవరు?');
  String get seller => _t('Seller', 'అమ్మేవారు');
  String get sellerHint => _t('I am a farmer. I want to SELL my crops',
      'నేను రైతును. నా పంట అమ్మాలి');
  String get buyer => _t('Buyer', 'కొనేవారు');
  String get buyerHint => _t('I want to BUY crops from farmers',
      'నేను రైతుల దగ్గర పంట కొనాలి');

  // ---------- Auth ----------
  String get welcomeBack => _t('Welcome Back', 'మళ్ళీ స్వాగతం');
  String get signInToContinue => _t('Sign in to continue', 'కొనసాగడానికి లాగిన్ అవ్వండి');
  String get mobileNumber => _t('Mobile number', 'మొబైల్ నంబర్');
  String get pin => _t('6-digit PIN', '6 అంకెల పిన్');
  String get confirmPin => _t('Enter PIN again', 'పిన్ మళ్ళీ ఇవ్వండి');
  String get pinHelp => _t('Choose any 6 numbers you can remember. Do not share it.',
      'మీకు గుర్తుండే 6 అంకెలు ఎంచుకోండి. ఎవరికీ చెప్పకండి.');
  String get login => _t('Login', 'లాగిన్');
  String get forgotPin => _t('Forgot PIN?', 'పిన్ మర్చిపోయారా?');
  String get forgotPinHelp => _t(
      'Please call our helpline. We will help you set a new PIN.',
      'దయచేసి మా హెల్ప్‌లైన్‌కు కాల్ చేయండి. కొత్త పిన్ పెట్టడానికి సహాయం చేస్తాము.');
  String get callHelpline => _t('Call Helpline', 'హెల్ప్‌లైన్‌కు కాల్ చేయండి');
  String get noAccount => _t('New here?', 'కొత్తగా వచ్చారా?');
  String get createAccount => _t('Create Account', 'ఖాతా తెరవండి');
  String get haveAccount => _t('Already have an account?', 'ఇప్పటికే ఖాతా ఉందా?');
  String get registerAsSeller => _t('Register as Seller', 'అమ్మేవారిగా నమోదు');
  String get registerAsBuyer => _t('Register as Buyer', 'కొనేవారిగా నమోదు');
  String get yourName => _t('Your name', 'మీ పేరు');
  String get logout => _t('Logout', 'లాగౌట్');
  String get logoutConfirm => _t('Do you want to logout?', 'లాగౌట్ అవ్వాలా?');

  // ---------- Location ----------
  String get pincode => _t('Pincode', 'పిన్‌కోడ్');
  String get pincodeHelp => _t('Enter the 6-digit pincode of your village',
      'మీ గ్రామం 6 అంకెల పిన్‌కోడ్ ఇవ్వండి');
  String get pincodeOptional => _t('Pincode (optional)', 'పిన్‌కోడ్ (ఐచ్ఛికం)');
  String get findingPlace => _t('Finding your place…', 'మీ ఊరు వెతుకుతున్నాం…');
  String get villagePostOffice => _t('Village / Post office', 'గ్రామం / పోస్టాఫీసు');
  String get selectVillage => _t('Select your village', 'మీ గ్రామం ఎంచుకోండి');
  String get district => _t('District', 'జిల్లా');
  String get state => _t('State', 'రాష్ట్రం');
  String get address => _t('House / street (optional)', 'ఇల్లు / వీధి (ఐచ్ఛికం)');
  String get pincodeNotFound => _t('Pincode not found. Please check the number.',
      'పిన్‌కోడ్ దొరకలేదు. నంబర్ సరిచూడండి.');
  String get pincodeLookupFailed => _t(
      'Could not check pincode (no internet?). Please type district and state.',
      'పిన్‌కోడ్ చూడలేకపోయాం (ఇంటర్నెట్ లేదా?). జిల్లా, రాష్ట్రం టైప్ చేయండి.');
  String get location => _t('Location', 'ప్రాంతం');

  // ---------- Validation / errors ----------
  String get required => _t('Please fill this', 'దయచేసి ఇది నింపండి');
  String get invalidMobile => _t('Enter a 10-digit mobile number',
      '10 అంకెల మొబైల్ నంబర్ ఇవ్వండి');
  String get invalidPin => _t('PIN must be 6 numbers', 'పిన్ 6 అంకెలు ఉండాలి');
  String get pinMismatch => _t('Both PINs are not the same', 'రెండు పిన్‌లు ఒకటి కాదు');
  String get invalidPincode => _t('Pincode must be 6 numbers', 'పిన్‌కోడ్ 6 అంకెలు ఉండాలి');
  String get invalidNumber => _t('Enter a number above 0', '0 కంటే ఎక్కువ నంబర్ ఇవ్వండి');
  String get wrongLogin => _t('Mobile number or PIN is wrong',
      'మొబైల్ నంబర్ లేదా పిన్ తప్పు');
  String get mobileAlreadyUsed => _t(
      'This mobile number is already registered. Please login.',
      'ఈ మొబైల్ నంబర్‌తో ఇప్పటికే ఖాతా ఉంది. లాగిన్ అవ్వండి.');
  String get noInternet => _t('No internet. Please try again.',
      'ఇంటర్నెట్ లేదు. మళ్ళీ ప్రయత్నించండి.');
  String get somethingWrong => _t('Something went wrong. Please try again.',
      'ఏదో పొరపాటు జరిగింది. మళ్ళీ ప్రయత్నించండి.');
  String get tryAgain => _t('Try again', 'మళ్ళీ ప్రయత్నించండి');

  // ---------- Common ----------
  String get yes => _t('Yes', 'అవును');
  String get no => _t('No', 'వద్దు');
  String get next => _t('Next', 'తర్వాత');
  String get back => _t('Back', 'వెనక్కి');
  String get save => _t('Save', 'సేవ్ చేయండి');
  String get saved => _t('Saved', 'సేవ్ అయింది');
  String get cancel => _t('Cancel', 'రద్దు');
  String get edit => _t('Edit', 'మార్చండి');
  String get delete => _t('Delete', 'తీసేయండి');
  String get call => _t('Call', 'కాల్ చేయండి');
  String get loading => _t('Please wait…', 'దయచేసి ఆగండి…');

  // ---------- Navigation ----------
  String get account => _t('Account', 'ఖాతా');
  String get category => _t('Category', 'రకాలు');
  String get search => _t('Search', 'వెతకండి');
  String get myProducts => _t('My Crops', 'నా పంటలు');
  String get enquiries => _t('Enquiries', 'విచారణలు');

  // ---------- Buyer browsing ----------
  String get allCategories => _t('All Categories', 'అన్ని రకాలు');
  String get searchHint => _t('Type crop name…', 'పంట పేరు టైప్ చేయండి…');
  String get noProducts => _t('No crops found here yet', 'ఇక్కడ ఇంకా పంటలు లేవు');
  String get filterAll => _t('All places', 'అన్ని ప్రాంతాలు');
  String filterMyDistrict(String d) => _t('My district: $d', 'నా జిల్లా: $d');
  String get filterPincode => _t('By pincode', 'పిన్‌కోడ్ ద్వారా');
  String filterPincodeValue(String p) => _t('Pincode: $p', 'పిన్‌కోడ్: $p');
  String get enterPincode => _t('Enter pincode', 'పిన్‌కోడ్ ఇవ్వండి');
  String get available => _t('Available', 'అందుబాటులో');
  String get price => _t('Price', 'ధర');
  String get soldBy => _t('Sold by', 'అమ్మేవారు');
  String get contactOwner => _t('Contact Owner', 'యజమానిని సంప్రదించండి');
  String get callOwner => _t('Call Farmer', 'రైతుకు కాల్ చేయండి');
  String get sendEnquiry => _t('Send Enquiry', 'విచారణ పంపండి');
  String get howMuchYouNeed => _t('How much do you need?', 'మీకు ఎంత కావాలి?');
  String get messageOptional => _t('Message (optional)', 'సందేశం (ఐచ్ఛికం)');
  String get enquirySent => _t('Enquiry sent. The farmer will call you.',
      'విచారణ పంపాము. రైతు మీకు కాల్ చేస్తారు.');
  String get sellerDetails => _t('Farmer details', 'రైతు వివరాలు');
  String get otherCrops => _t('Other crops from this farmer', 'ఈ రైతు ఇతర పంటలు');
  String get myEnquiries => _t('My Enquiries', 'నా విచారణలు');
  String get noEnquiries => _t('No enquiries yet', 'ఇంకా విచారణలు లేవు');
  String get statusNew => _t('Waiting', 'ఎదురుచూస్తోంది');
  String get statusResponded => _t('Farmer responded', 'రైతు స్పందించారు');
  String get noPhoto => _t('No photo', 'ఫోటో లేదు');

  // ---------- Seller ----------
  String get addCrop => _t('Add Crop', 'పంట చేర్చండి');
  String get editCrop => _t('Edit Crop', 'పంట మార్చండి');
  String get noCropsYet => _t('You have not added any crop yet.\nTap the button below to add.',
      'మీరు ఇంకా పంట చేర్చలేదు.\nకింద ఉన్న బటన్ నొక్కండి.');
  String get step1Category => _t('Step 1: What type of crop?', 'దశ 1: ఏ రకం పంట?');
  String get step2Crop => _t('Step 2: Which crop?', 'దశ 2: ఏ పంట?');
  String get step3Photo => _t('Step 3: Take photos', 'దశ 3: ఫోటోలు తీయండి');
  String get step4Price => _t('Step 4: Price and quantity', 'దశ 4: ధర మరియు పరిమాణం');
  String get step5Check => _t('Step 5: Check and save', 'దశ 5: సరిచూసి సేవ్ చేయండి');
  String get otherCrop => _t('Other', 'ఇతర');
  String get typeCropName => _t('Type crop name', 'పంట పేరు టైప్ చేయండి');
  String get takePhoto => _t('Take Photo', 'ఫోటో తీయండి');
  String get fromGallery => _t('From Gallery', 'గ్యాలరీ నుండి');
  String get photoHelp => _t('Add up to 3 clear photos of your crop (optional)',
      'మీ పంట యొక్క 3 వరకు స్పష్టమైన ఫోటోలు (ఐచ్ఛికం)');
  String get unit => _t('Sell by', 'అమ్మే కొలత');
  String pricePer(String unit) => _t('Price for 1 $unit (₹)', '1 $unit ధర (₹)');
  String get quantityAvailable => _t('How much do you have?', 'మీ దగ్గర ఎంత ఉంది?');
  String get description => _t('Details (optional)', 'వివరాలు (ఐచ్ఛికం)');
  String get descriptionHint => _t('Example: organic, fresh, harvest date',
      'ఉదా: సేంద్రియ, తాజా, కోత తేదీ');
  String get saveCrop => _t('Save Crop', 'పంట సేవ్ చేయండి');
  String get uploading => _t('Saving… please wait', 'సేవ్ అవుతోంది… ఆగండి');
  String get deleteCropConfirm => _t('Remove this crop from the app?',
      'ఈ పంటను యాప్ నుండి తీసేయాలా?');
  String get enquiryFrom => _t('Enquiry from', 'విచారణ చేసినవారు');
  String get wants => _t('Wants', 'కావాలి');
  String get callBuyer => _t('Call Buyer', 'కొనేవారికి కాల్');
  String get markResponded => _t('Mark as done', 'పూర్తి అయింది');
  String get editProfile => _t('Edit my details', 'నా వివరాలు మార్చండి');
  String get helpline => _t('Helpline', 'హెల్ప్‌లైన్');

  // ---------- Units ----------
  String unitName(String key) {
    switch (key) {
      case 'quintal':
        return _t('quintal', 'క్వింటాల్');
      case 'litre':
        return _t('litre', 'లీటరు');
      case 'dozen':
        return _t('dozen', 'డజను');
      case 'piece':
        return _t('piece', 'ఒక్కటి');
      case 'kg':
      default:
        return _t('kg', 'కిలో');
    }
  }
}
