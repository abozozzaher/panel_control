// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Blue textiles`
  String get blue_textiles {
    return Intl.message(
      'Blue textiles',
      name: 'blue_textiles',
      desc: '',
      args: [],
    );
  }

  /// `Toggle Theme`
  String get toggle_theme {
    return Intl.message(
      'Toggle Theme',
      name: 'toggle_theme',
      desc: '',
      args: [],
    );
  }

  /// `Toggle Language`
  String get toggle_language {
    return Intl.message(
      'Toggle Language',
      name: 'toggle_language',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message(
      'Register',
      name: 'register',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get first_name {
    return Intl.message(
      'First Name',
      name: 'first_name',
      desc: '',
      args: [],
    );
  }

  /// `Last Name`
  String get last_name {
    return Intl.message(
      'Last Name',
      name: 'last_name',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message(
      'Phone',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account?`
  String get no_account_register {
    return Intl.message(
      'Don\'t have an account?',
      name: 'no_account_register',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password`
  String get forgot_password {
    return Intl.message(
      'Forgot Password',
      name: 'forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `Password Reset`
  String get password_reset {
    return Intl.message(
      'Password Reset',
      name: 'password_reset',
      desc: '',
      args: [],
    );
  }

  /// `email sent`
  String get email_sent {
    return Intl.message(
      'email sent',
      name: 'email_sent',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `ID`
  String get id {
    return Intl.message(
      'ID',
      name: 'id',
      desc: '',
      args: [],
    );
  }

  /// `Product`
  String get product {
    return Intl.message(
      'Product',
      name: 'product',
      desc: '',
      args: [],
    );
  }

  /// `For`
  String get for2 {
    return Intl.message(
      'For',
      name: 'for2',
      desc: '',
      args: [],
    );
  }

  /// `Data`
  String get data {
    return Intl.message(
      'Data',
      name: 'data',
      desc: '',
      args: [],
    );
  }

  /// `Sale Status`
  String get sale_status {
    return Intl.message(
      'Sale Status',
      name: 'sale_status',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your email`
  String get please_enter_your_email {
    return Intl.message(
      'Please enter your email',
      name: 'please_enter_your_email',
      desc: '',
      args: [],
    );
  }

  /// `Pick image`
  String get pick_image {
    return Intl.message(
      'Pick image',
      name: 'pick_image',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get select {
    return Intl.message(
      'Select',
      name: 'select',
      desc: '',
      args: [],
    );
  }

  /// `Yarn number`
  String get yarn_number {
    return Intl.message(
      'Yarn number',
      name: 'yarn_number',
      desc: '',
      args: [],
    );
  }

  /// `Color`
  String get color {
    return Intl.message(
      'Color',
      name: 'color',
      desc: '',
      args: [],
    );
  }

  /// `Weight`
  String get weight {
    return Intl.message(
      'Weight',
      name: 'weight',
      desc: '',
      args: [],
    );
  }

  /// `Width`
  String get width {
    return Intl.message(
      'Width',
      name: 'width',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get type {
    return Intl.message(
      'Type',
      name: 'type',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get new1 {
    return Intl.message(
      'New',
      name: 'new1',
      desc: '',
      args: [],
    );
  }

  /// `Shift`
  String get shift {
    return Intl.message(
      'Shift',
      name: 'shift',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get quantity {
    return Intl.message(
      'Quantity',
      name: 'quantity',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Item`
  String get item {
    return Intl.message(
      'Item',
      name: 'item',
      desc: '',
      args: [],
    );
  }

  /// `saved successfully with`
  String get saved_successfully_with {
    return Intl.message(
      'saved successfully with',
      name: 'saved_successfully_with',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message(
      'Details',
      name: 'details',
      desc: '',
      args: [],
    );
  }

  /// `Image uploaded successfully`
  String get image_uploaded_successfully {
    return Intl.message(
      'Image uploaded successfully',
      name: 'image_uploaded_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Failed to upload image`
  String get failed_to_upload_image {
    return Intl.message(
      'Failed to upload image',
      name: 'failed_to_upload_image',
      desc: '',
      args: [],
    );
  }

  /// `Please select a type.`
  String get please_select_a_type {
    return Intl.message(
      'Please select a type.',
      name: 'please_select_a_type',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Scan`
  String get scan {
    return Intl.message(
      'Scan',
      name: 'scan',
      desc: '',
      args: [],
    );
  }

  /// `Scanned`
  String get scanned {
    return Intl.message(
      'Scanned',
      name: 'scanned',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get total {
    return Intl.message(
      'Total',
      name: 'total',
      desc: '',
      args: [],
    );
  }

  /// `The Code`
  String get the_code {
    return Intl.message(
      'The Code',
      name: 'the_code',
      desc: '',
      args: [],
    );
  }

  /// `has already been scanned.`
  String get has_already_been_scanned {
    return Intl.message(
      'has already been scanned.',
      name: 'has_already_been_scanned',
      desc: '',
      args: [],
    );
  }

  /// `Please fill all fields`
  String get please_fill_all_fields {
    return Intl.message(
      'Please fill all fields',
      name: 'please_fill_all_fields',
      desc: '',
      args: [],
    );
  }

  /// `Sold`
  String get sold {
    return Intl.message(
      'Sold',
      name: 'sold',
      desc: '',
      args: [],
    );
  }

  /// `Available`
  String get available {
    return Intl.message(
      'Available',
      name: 'available',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get menu {
    return Intl.message(
      'Menu',
      name: 'menu',
      desc: '',
      args: [],
    );
  }

  /// `Length`
  String get length {
    return Intl.message(
      'Length',
      name: 'length',
      desc: '',
      args: [],
    );
  }

  /// `ZAHİR LOJİSTİK TEKSTİL SANAYİ VE TİCARET LİMİTED ŞİRKETİ`
  String get company_name {
    return Intl.message(
      'ZAHİR LOJİSTİK TEKSTİL SANAYİ VE TİCARET LİMİTED ŞİRKETİ',
      name: 'company_name',
      desc: '',
      args: [],
    );
  }

  /// `Türkiye Gaziantep Sanayi MAH. 60092`
  String get addres {
    return Intl.message(
      'Türkiye Gaziantep Sanayi MAH. 60092',
      name: 'addres',
      desc: '',
      args: [],
    );
  }

  /// `Scan a code`
  String get scan_a_code {
    return Intl.message(
      'Scan a code',
      name: 'scan_a_code',
      desc: '',
      args: [],
    );
  }

  /// `Access Denied. You do not have the required role.`
  String get access_denied_you_do_not_have_the_required_role {
    return Intl.message(
      'Access Denied. You do not have the required role.',
      name: 'access_denied_you_do_not_have_the_required_role',
      desc: '',
      args: [],
    );
  }

  /// `Go to the main page`
  String get go_to_page {
    return Intl.message(
      'Go to the main page',
      name: 'go_to_page',
      desc: '',
      args: [],
    );
  }

  /// `Error 404`
  String get error_404 {
    return Intl.message(
      'Error 404',
      name: 'error_404',
      desc: '',
      args: [],
    );
  }

  /// `Page not found`
  String get page_not_found {
    return Intl.message(
      'Page not found',
      name: 'page_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Play Beep Sound`
  String get play_beep_sound {
    return Intl.message(
      'Play Beep Sound',
      name: 'play_beep_sound',
      desc: '',
      args: [],
    );
  }

  /// `Play Scan Sound`
  String get play_scan_sound {
    return Intl.message(
      'Play Scan Sound',
      name: 'play_scan_sound',
      desc: '',
      args: [],
    );
  }

  /// `Product Details`
  String get product_details {
    return Intl.message(
      'Product Details',
      name: 'product_details',
      desc: '',
      args: [],
    );
  }

  /// `No data found.`
  String get no_data_found {
    return Intl.message(
      'No data found.',
      name: 'no_data_found',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate Code`
  String get duplicate_code {
    return Intl.message(
      'Duplicate Code',
      name: 'duplicate_code',
      desc: '',
      args: [],
    );
  }

  /// `Error Code`
  String get error_code {
    return Intl.message(
      'Error Code',
      name: 'error_code',
      desc: '',
      args: [],
    );
  }

  /// `No data found for this code.`
  String get no_data_found_for_this_code {
    return Intl.message(
      'No data found for this code.',
      name: 'no_data_found_for_this_code',
      desc: '',
      args: [],
    );
  }

  /// `Enter Code`
  String get enter_code {
    return Intl.message(
      'Enter Code',
      name: 'enter_code',
      desc: '',
      args: [],
    );
  }

  /// `Button`
  String get button {
    return Intl.message(
      'Button',
      name: 'button',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'tr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
