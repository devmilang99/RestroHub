enum MembershipTier { gold, diamond, platinum, bronze, silver }

class MembershipRules {
  static MembershipTier getTier(int points) {
    if (points >= 2000) {
      return MembershipTier.platinum;
    } else if (points >= 1000) {
      return MembershipTier.diamond;
    } else if (points >= 500) {
      return MembershipTier.gold;
    } else if (points >= 200) {
      return MembershipTier.silver;
    } else {
      return MembershipTier.bronze;
    }
  }

  static String getTierName(MembershipTier tier) {
    switch (tier) {
      case MembershipTier.platinum:
        return 'Platinum Member';
      case MembershipTier.diamond:
        return 'Diamond Member';
      case MembershipTier.gold:
        return 'Gold Member';
      case MembershipTier.silver:
        return 'Silver Member';
      case MembershipTier.bronze:
        return 'Bronze Member';
    }
  }

  static double getNextTierProgress(int points) {
    if (points >= 2000) return 1.0;
    if (points >= 1000) return (points - 1000) / 1000;
    if (points >= 500) return (points - 500) / 500;
    if (points >= 200) return (points - 200) / 300;
    return points / 200;
  }

  static int getPointsToNextTier(int points) {
    if (points >= 2000) return 0;
    if (points >= 1000) return 2000 - points;
    if (points >= 500) return 1000 - points;
    if (points >= 200) return 500 - points;
    return 200 - points;
  }
}
