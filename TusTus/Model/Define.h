//
//  Define.h
//  TusTus
//
//  Created by User on 4/7/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#ifndef TusTus_Define_h
#define TusTus_Define_h

#define validString(str) (str == nil)? @"" : str

typedef NS_ENUM(NSInteger, FromMode)
{
    fromNone   = 1,
    fromSignup,       //PhoneNumber
    fromForgot,       //PhoneNumber
    fromRegister,
    fromPickup,
    fromDropOff,
    fromEditContact,
    fromMyProfile
};

typedef NS_ENUM(NSInteger, CategoryMode){
    NONE_CAT = -1,
    SCOOTER_CAT,
    CAR_CAT,
    MOVING_CAT
};

//*****************Server Info**************
#define SERVER_DATE_TIME_URL            @"http://tustus.co/mobile/date_time.php"
#define SERVER_URL                      @"http://tustus.co/mobile/signup.php"

//*****************User Defaults Keys**************
#define DEFAULT_REMEMBER_ME             @"rememberMe"
#define DEFAULT_USER_PHONE              @"userPhone"
#define DEFAULT_USER_PSWD               @"userPswd"
#define DEFAULT_ALERT_DISABLED          @"alert_disabled"

#define pref_booked_array               @"booked"

//*****************Parse Keys**************
#define PARSE_APPLICATION_ID            @"mjV7tQXUZEjVPd8mUE4qV3RdtW3sS71NXw3iRi2k"
#define PARSE_CLIENT_KEY                @"2NFAKgXBhhDJxAegYlulrDjxiO0mX7WZggGs4e9q"

#define pClassContact                   @"Contact"

#define pKeyUserID                      @"userID"
#define pKeyObjectID                    @"objectId"

#define pKeyUser                        @"user"
#define pKeyUsername                    @"username"
#define pKeyEmail                       @"email"
#define pKeyNumberID                    @"id_number"
#define pKeyFullName                    @"fullName"
#define pKeyAddress                     @"address"
#define pKeyApartment                   @"apartment"
#define pKeyFloor                       @"floor"
#define pKeyMyUsername                  @"myUsername"
#define pKeyPSW                         @"psw"
#define pKeyPriceForScooter             @"scooter_price"
#define pKeyPriceForCar                 @"car_price"
#define pKeyPriceForTruck               @"truck_price"
#define pKeyMinPriceForScooter          @"minPriceForScooter"
#define pKeyMinDistanceForScooter       @"minDistanceForScooter"
#define pKeyMinPriceForCar              @"minPriceForCar"
#define pKeyMinDistanceForCar           @"minDistanceForCar"
#define pKeyMinPriceForTruck            @"minPriceForTruck"
#define pKeyMinDistanceForTruck         @"minDistanceForTruck"
#define pKeyFlatPrice                   @"flat_price"
#define pKeyModePrice                   @"price_mode"
#define pKeyWorkerFlag                  @"worker_flag"
#define pKeyFreePaymentFlag             @"freepayment_flag"
#define pKeyWorker                      @"worker"
#define pKeyRateDay                     @"day_rate"
#define pKeyRateEvening                 @"evening_rate"
#define pKeyRateNight                   @"night_rate"
#define pKeyHourDayStart                @"day_start"
#define pKeyHourDayEnd                  @"day_end"
#define pKeyHourEveningStart            @"evening_start"
#define pKeyHourEveningEnd              @"evening_end"
#define pKeyHourNightStart              @"night_start"
#define pKeyHourNightEnd                @"night_end"
#define pKeyAutoSMS                     @"auto_sms"

#define pClassDelivery                  @"Delivery"
#define pClassCanceledDelivery          @"Canceled"
#define pClassCompletedDelivery         @"Completed"

#define pKeyCustomerName                @"customer_name"
#define pKeyCustomerEmail               @"customer_email"
#define pKeyCustomerAddress             @"customer_address"
#define pKeyCustomerPhone               @"customer_phone"
#define pKeyNCategory                   @"nCategory"
#define pKeyWorkerName                  @"worker_name"
#define pKeyWorkerFullName              @"worker_full_name"
#define pKeyWorkerPhone                 @"worker_phone_number"
#define pKeyCustomerObjId               @"customer_objId"
#define pKeyWorkerObjId                 @"worker_objId"
#define pKeyStatus                      @"nStatus"
#define pKeyStartAddress                @"start_address"
#define pKeyStartApartment              @"start_apartment"
#define pKeyStartFloor                  @"start_floor"
#define pKeyStartPerson                 @"start_person"
#define pKeyStartPhone                  @"start_phone"
#define pKeyEndAddress                  @"end_address"
#define pKeyEndApartment                @"end_apartment"
#define pKeyEndFloor                    @"end_floor"
#define pKeyEndPerson                   @"end_person"
#define pKeyEndPhone                    @"end_phone"
#define pKeyUrgencyType                 @"urgency_type"
#define pKeyPackageType                 @"package_type"
#define pKeyDoubleType                  @"double_type"
#define pKeyAmount                      @"nAmount"
#define pKeyComment                     @"comment"
#define pKeyPrice                       @"price"
#define pKeyPublishedDate               @"published_date"
#define pKeyAcceptedDate                @"accepted_date"
#define pKeyPickupedDate                @"pickuped_date"
#define pKeyCompletedDate               @"completed_date"
#define pKeyCanceledDate                @"canceled_date"
#define pKeyPurchasedDate               @"purchased_date"
#define pKeyFutureBooked                @"future_booked"
#define pKeyManagerOwn                  @"manager_own"
#define pKeyWorkerOwn                   @"worker_own"
#define pKeyPublicMode                  @"public_mode"
#define pKeyInvoiceNumber               @"invoice_number"
#define pKeyInventoryAmount             @"inventory_amount"
#define pKeyMovingDate                  @"moving_date"
#define pKeySMSPhoneNumber              @"sms_number"

#define pClassCity_En                   @"City_En"
#define pClassCity_Hebrew               @"City_Hebrew"

#define pKeyCityName                    @"city_name"

#define pClassWorkerScooter             @"Worker_Scooter"
#define pClassWorkerCar                 @"Worker_Car"
#define pClassWorkerTruck               @"Worker_Truck"

#define pnAps                           @"aps"
#define pnMode                          @"mode"
#define pnBookingID                     @"bookingID"
#define pnFromID                        @"fromID"
#define pnAlert                         @"alert"
#define pnInvoiceNumber                 @"invoice_number"

#define PN_NEW                          @"new"
#define PN_DISAPPEAR                    @"disappear"
#define PN_PURCHASE                     @"purchase"
#define PN_CANCEL                       @"cancel"
#define PN_ACCEPT_REQUEST               @"accept_request"
#define PN_ACCEPT_APPROVE               @"accept_apporve"
#define PN_ACCPET_FORBIDDEN             @"accept_forbidden"
#define PN_ACCEPT                       @"accept"
#define PN_PICKUP                       @"pickup"
#define PN_DELIVERY                     @"delivery"
#define PN_CANCEL_NEW                   @"cancel_new"

//*****************Segue Keys**************

#define SEGUE_NUMBER_FROM_SIGNUP        @"segueNumberFromSignup"
#define SEGUE_NUMBER_FROM_FORGOT        @"segueNumberFromForgot"
#define SEGUE_REGISTER_FROM_NUMBER      @"segueRegisterFromNumber"


//*****************Array Key**************
#define arrKeyWanaSend                  @"spinnerWannaSend"
#define arrKeyUrgency                   @"spinnerUrgency"
#define arrKeyStatusCategory            @"status_category"
#define arrKeyCategory                  @"spinnerCategory"
#define arrKeyInventory                 @"inventory_array"

//*****************Storyboard**************
#define main_storyboard                 @"Main"


//*****************TableView Cell**************
#define CELL_SEARCH_RESULT              @"SearchResultCell"
#define CELL_RIGHT_MENU                 @"RightMenuCell"
#define CELL_PROFILE                    @"ProfileCell"
#define CELL_NUMBER_DELIVERY            @"NumberDeliveryCell"
#define CELL_LEFT_FROM_ME_CANCEL        @"LeftFromMeCancelCell"
#define CELL_LEFT_FROM_ME               @"LeftFromMeCell"
#define CELL_LEFT_GENERAL_CANCEL        @"LeftGeneralCancelCell"
#define CELL_LEFT_GENERAL               @"LeftGeneralCell"
#define CELL_LEFT_TO_ME_CANCEL          @"LeftToMeCancelCell"
#define CELL_LEFT_TO_ME                 @"LeftToMeCell"
#define CELL_CONTACT                    @"ContactsCell"
#define CELL_HISTORY                    @"HistoryItemCell"
#define CELL_INVENTORY_ITEM             @"InventoryItemCell"
#define CELL_TITLE                      @"TitleCell"
#define CELL_GENERAL                    @"GeneralCell"
#define CELL_ADDRESS_INFO               @"AddressInfoCell"
#define CELL_PRICE                      @"PriceCell"
#define CELL_BUTTON_ORDER               @"ButtonOrderCell"
#define CELL_REWIND_CANCEL              @"RewindCancelCell"
#define CELL_ITEM                       @"ItemCell"

//*****************ViewController**************
#define NAV_SIGN_PART                   @"SignPartNavigationController"
#define VC_LOGIN                        @"LoginViewController"
#define VC_SEARCH_ADDRESS               @"SearchAddressViewController"
#define VC_LEFT_MENU                    @"LeftMenuTableViewController"
#define VC_RIGHT_MENU                   @"RightMenuTableViewController"
#define VC_SELECT_CATEGORY              @"SelectCategoryViewController"
#define VC_SELECT_CATEGORY_I            @"SelectCategoryViewController_I"
#define VC_PICK_DATE                    @"DatePickViewController"
#define NAV_MAIN                        @"MainNavigationController"
#define VC_HISTORY                      @"HistoryViewController"
#define VC_PICKUP_ADDRESS               @"PickupAddressViewController"
#define VC_DROP_OFF_ADDRESS             @"DropOffAddressViewController"
#define VC_CONTACT_LIST                 @"ContactListViewController"
#define VC_EDIT_CONTACT                 @"EditContactViewController"
#define VC_SETTING                      @"SettingViewController"
#define VC_MY_PROFILE                   @"MyProfileViewController"
#define VC_CONTACTS                     @"ContactsViewController"
#define VC_HISTORY                      @"HistoryViewController"
#define VC_INVENTORY_ITEM               @"InventoryItemViewController"
#define VC_TOTAL_PAGE                   @"TotalPageViewController"

#define VC_TEST                         @"TestViewController"

//*****************Notification center String**************
#define N_ContactSelectedForPickup             @"N_ContactSelectedForPickup"
#define N_ContactSelectedForDropOff            @"N_ContactSelectedForDropOff"
#define N_ContactUpdated                       @"N_ContactUpdated"
#define N_SearchAddressSelectedForRegister     @"N_SearchAddressSelectedForRegister"
#define N_SearchAddressSelectedForPickup       @"N_SearchAddressSelectedForPickup"
#define N_SearchAddressSelectedForDropOff      @"N_SearchAddressSelectedForDropOff"
#define N_SearchAddressSelectedForEditContact  @"N_SearchAddressSelectedForEditContact"
#define N_SearchAddressSelectedForMyProfile    @"N_SearchAddressSelectedForMyProfile"
#define N_NewBookingPublished                  @"N_NewBookingPublished"
#define N_InitSelectCategory                   @"N_InitSelectCategory"



//*****************Constant value**************
#define nMinPriceForScooter             15
#define nMinPriceForCar                 50
#define nMinPriceForTruck               99
#define nMinDistanceForScooter          3
#define nMinDistanceForCar              3
#define nMinDistanceForTruck            3
#define nFlatPrice                      100
#define nTax                            18
#define nPerKmPriceForScooter           4
#define nPerKmPriceForCar               5
#define nPerKmPriceForTruck             9
#define nPriceForA4                     10
#define nPriceForBOX50                  20
#define nPriceForBOX150                 50
#define nDayRate                        0
#define nEveningRate                    20
#define nNightRate                      60
#define nDayStart                       700
#define nDayEnd                         1600
#define nEveningStart                   1600
#define nEveningEnd                     2000
#define nNightStart                     2000
#define nNightEnd                       700

#define nUrgencyRate                    75
#define nDoubleRate                     75
#define nElevatorYesRate                3
#define nElevatorNoRate                 6
#endif
