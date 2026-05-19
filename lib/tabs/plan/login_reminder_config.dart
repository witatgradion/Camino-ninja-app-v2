/// Plans must have strictly more than this many stages for the login reminder
/// banner to appear. At or below this threshold, only the generic "Sign in to
/// sync" banner is shown.
const int kLoginReminderStageThreshold = 3;

/// Source identifier for the Plan detail screen, included in analytics events.
const String kLoginReminderSourcePlanDetail = 'plan_detail';
