class BankInfo {
  final String bankIcon;
  final String bankName;
  final String offerVal;
  final String? expiringInDays;
  final String states;
  final String? offerLink;
  final String? accountType;
  final String? directDepositAmt;

  BankInfo(
      {required this.bankIcon,
      required this.bankName,
      required this.offerVal,
      required this.expiringInDays,
      required this.states,
      required this.accountType,
      required this.directDepositAmt,
      required this.offerLink});

  factory BankInfo.fromJson(Map<String, dynamic> json) {
    return BankInfo(
        bankName: json['bankName'],
        offerVal: json['bankOffer'],
        expiringInDays: json['bankOfferExpireIn'],
        states: json['bankStates'],
        offerLink: json['bankOfferLink'],
        accountType: json['accountType'],
        directDepositAmt: json['directDepositAmt'],
        bankIcon: json['bankIcon']);
  }
}
