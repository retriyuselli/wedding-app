import Foundation

enum L10n {
    enum Common {
        static var cancel: String { "common.cancel".localized }
        static var save: String { "common.save".localized }
        static var ok: String { "common.ok".localized }
        static var close: String { "common.close".localized }
        static var done: String { "common.done".localized }
        static var reset: String { "common.reset".localized }
        static var apply: String { "common.apply".localized }
        static var delete: String { "common.delete".localized }
        static var edit: String { "common.edit".localized }
        static var filter: String { "common.filter".localized }
        static var search: String { "common.search".localized }
        static var seeAll: String { "common.see_all".localized }
        static var seeDetail: String { "common.see_detail".localized }
        static var share: String { "common.share".localized }
        static var logout: String { "common.logout".localized }
        static var comingSoon: String { "common.coming_soon".localized }
        static var comingSoonMessage: String { "common.coming_soon_message".localized }
        static var tryAgain: String { "common.try_again".localized }
        static var sort: String { "common.sort".localized }
        static var notes: String { "common.notes".localized }
        static var location: String { "common.location".localized }
        static var date: String { "common.date".localized }
        static var time: String { "common.time".localized }
        static var all: String { "common.all".localized }
        static var confirmed: String { "common.confirmed".localized }
        static var pending: String { "common.pending".localized }
        static var notAttending: String { "common.not_attending".localized }
        static var description: String { "common.description".localized }
        static var category: String { "common.category".localized }
        static var notAvailable: String { "common.not_available".localized }
        static var success: String { "common.success".localized }
        static var warning: String { "common.warning".localized }
        static var soon: String { "common.soon".localized }
    }

    enum Tab {
        static var home: String { "tab.home".localized }
        static var checklist: String { "tab.checklist".localized }
        static var guest: String { "tab.guest".localized }
        static var budget: String { "tab.budget".localized }
        static var more: String { "tab.more".localized }
    }

    enum Auth {
        static var appName: String { "auth.app_name".localized }
        static var tagline: String { "auth.tagline".localized }
        static var emailOrPhone: String { "auth.email_or_phone".localized }
        static var emailPlaceholder: String { "auth.email_placeholder".localized }
        static var password: String { "auth.password".localized }
        static var passwordPlaceholder: String { "auth.password_placeholder".localized }
        static var confirmPassword: String { "auth.confirm_password".localized }
        static var fullName: String { "auth.full_name".localized }
        static var fullNamePlaceholder: String { "auth.full_name_placeholder".localized }
        static var invalidEmail: String { "auth.invalid_email".localized }
        static var passwordMismatch: String { "auth.password_mismatch".localized }
        static var forgotPassword: String { "auth.forgot_password".localized }
        static var login: String { "auth.login".localized }
        static var register: String { "auth.register".localized }
        static var registerNow: String { "auth.register_now".localized }
        static var haveAccount: String { "auth.have_account".localized }
        static var noAccount: String { "auth.no_account".localized }
        static var orLoginWith: String { "auth.or_login_with".localized }
        static var orRegisterWith: String { "auth.or_register_with".localized }
        static var taglineQuote: String { "auth.tagline_quote".localized }
        static var continueApple: String { "auth.continue_apple".localized }
        static var continueGoogle: String { "auth.continue_google".localized }
        static var continuePhone: String { "auth.continue_phone".localized }
        static var or: String { "auth.or".localized }
    }

    enum More {
        static var title: String { "more.title".localized }
        static var subtitle: String { "more.subtitle".localized }
        static var planningSection: String { "more.planning_section".localized }
        static var accountSection: String { "more.account_section".localized }
        static var weddingDetail: String { "more.wedding_detail".localized }
        static var weddingDetailSub: String { "more.wedding_detail_sub".localized }
        static var couple: String { "more.couple".localized }
        static var coupleSub: String { "more.couple_sub".localized }
        static var savedVendors: String { "more.saved_vendors".localized }
        static var savedVendorsSub: String { "more.saved_vendors_sub".localized }
        static var inspiration: String { "more.inspiration".localized }
        static var inspirationSub: String { "more.inspiration_sub".localized }
        static var documents: String { "more.documents".localized }
        static var documentsSub: String { "more.documents_sub".localized }
        static var settings: String { "more.settings".localized }
        static var settingsSub: String { "more.settings_sub".localized }
        static var privacy: String { "more.privacy".localized }
        static var privacySub: String { "more.privacy_sub".localized }
        static var reminders: String { "more.reminders".localized }
        static var remindersSub: String { "more.reminders_sub".localized }
        static var language: String { "more.language".localized }
        static var help: String { "more.help".localized }
        static var helpSub: String { "more.help_sub".localized }
        static var about: String { "more.about".localized }
        static var aboutSub: String { "more.about_sub".localized }
        static var shareApp: String { "more.share_app".localized }
        static var shareAppSub: String { "more.share_app_sub".localized }
        static var shareMessage: String { "more.share_message".localized }
        static var editProfile: String { "more.edit_profile".localized }
        static var logoutTitle: String { "more.logout_title".localized }
        static var logoutMessage: String { "more.logout_message".localized }
        static var dateNotSet: String { "more.date_not_set".localized }
        static var locationNotSet: String { "more.location_not_set".localized }
    }

    enum Reminders {
        static var title: String { "reminders.title".localized }
        static var subtitle: String { "reminders.subtitle".localized }
        static var statusOn: String { "reminders.status_on".localized }
        static var statusOnSub: String { "reminders.status_on_sub".localized }
        static var statusOff: String { "reminders.status_off".localized }
        static var statusOffSub: String { "reminders.status_off_sub".localized }
        static var statusNotSet: String { "reminders.status_not_set".localized }
        static var statusNotSetSub: String { "reminders.status_not_set_sub".localized }
        static var pushToggle: String { "reminders.push_toggle".localized }
        static var pushToggleSub: String { "reminders.push_toggle_sub".localized }
        static var openSettings: String { "reminders.open_settings".localized }
        static var info: String { "reminders.info".localized }
    }

    enum Language {
        static var title: String { "language.title".localized }
        static var subtitle: String { "language.subtitle".localized }
        static var indonesian: String { "language.indonesian".localized }
        static var english: String { "language.english".localized }
        static var info: String { "language.info".localized }
    }

    enum Dashboard {
        static var welcome: String { "dashboard.welcome".localized }
        static var planTogether: String { "dashboard.plan_together".localized }
        static var daysToGo: String { "dashboard.days_to_go".localized }
        static var weddingProgress: String { "dashboard.wedding_progress".localized }
        static var nextUp: String { "dashboard.next_up".localized }
        static var completed: String { "dashboard.completed".localized }
        static var inProgress: String { "dashboard.in_progress".localized }
        static var toDo: String { "dashboard.todo".localized }
        static var notifications: String { "dashboard.notifications".localized }
        static var noNotifications: String { "dashboard.no_notifications".localized }
        static var noNotificationsSub: String { "dashboard.no_notifications_sub".localized }
        static var tasks: String { "dashboard.tasks".localized }
        static var vendors: String { "dashboard.vendors".localized }
        static var inspiration: String { "dashboard.inspiration".localized }
        static var messages: String { "dashboard.messages".localized }
    }

    enum Guest {
        static var title: String { "guest.title".localized }
        static var subtitle: String { "guest.subtitle".localized }
        static var rsvpOverview: String { "guest.rsvp_overview".localized }
        static var totalGuests: String { "guest.total_guests".localized }
        static var people: String { "guest.people".localized }
        static var allGuests: String { "guest.all_guests".localized }
        static var searchPlaceholder: String { "guest.search_placeholder".localized }
        static var addGuest: String { "guest.add_guest".localized }
        static var sortName: String { "guest.sort_name".localized }
        static var name: String { "guest.name".localized }
        static var phone: String { "guest.phone".localized }
        static var email: String { "guest.email".localized }
    }

    enum Checklist {
        static var title: String { "checklist.title".localized }
        static var subtitle: String { "checklist.subtitle".localized }
        static var searchPlaceholder: String { "checklist.search_placeholder".localized }
        static var tasks: String { "checklist.tasks".localized }
        static var done: String { "checklist.done".localized }
        static var running: String { "checklist.running".localized }
        static var notStarted: String { "checklist.not_started".localized }
        static var totalProgress: String { "checklist.total_progress".localized }
        static func tasksCompleted(_ done: Int, _ total: Int) -> String {
            "checklist.tasks_completed".localized(done, total)
        }
    }

    enum Budget {
        static var title: String { "budget.title".localized }
        static var subtitle: String { "budget.subtitle".localized }
        static var totalBudget: String { "budget.total_budget".localized }
        static var spent: String { "budget.spent".localized }
        static var commitment: String { "budget.commitment".localized }
        static var remaining: String { "budget.remaining".localized }
        static var expenses: String { "budget.expenses".localized }
        static var categories: String { "budget.categories".localized }
        static var incoming: String { "budget.incoming".localized }
        static var addExpense: String { "budget.add_expense".localized }
        static var addExpenseSub: String { "budget.add_expense_sub".localized }
        static var noExpenses: String { "budget.no_expenses".localized }
        static var noExpensesSub: String { "budget.no_expenses_sub".localized }
    }

    enum Vendor {
        static var title: String { "vendor.title".localized }
        static var subtitle: String { "vendor.subtitle".localized }
        static var searchPlaceholder: String { "vendor.search_placeholder".localized }
        static func found(_ count: Int) -> String { "vendor.found".localized(count) }
        static var notFound: String { "vendor.not_found".localized }
        static var notFoundSub: String { "vendor.not_found_sub".localized }
    }

    enum Inspiration {
        static var title: String { "inspiration.title".localized }
        static var subtitle: String { "inspiration.subtitle".localized }
        static var searchPlaceholder: String { "inspiration.search_placeholder".localized }
        static var latest: String { "inspiration.latest".localized }
        static var saved: String { "inspiration.saved".localized }
        static var saveIdea: String { "inspiration.save_idea".localized }
        static var allCategories: String { "inspiration.all_categories".localized }
        static var allCategoriesSub: String { "inspiration.all_categories_sub".localized }
        static func likes(_ count: String) -> String { "inspiration.likes".localized(count) }
        static func views(_ count: String) -> String { "inspiration.views".localized(count) }
        static var saveInspiration: String { "inspiration.save_inspiration".localized }
        static var savedLabel: String { "inspiration.saved_label".localized }
    }

    enum Documents {
        static var title: String { "documents.title".localized }
        static var subtitle: String { "documents.subtitle".localized }
        static var searchPlaceholder: String { "documents.search_placeholder".localized }
        static var storage: String { "documents.storage".localized }
        static func storageUsed(_ used: String, _ quota: Int) -> String {
            "documents.storage_used".localized(used, quota)
        }
        static var upload: String { "documents.upload".localized }
        static var uploadHint: String { "documents.upload_hint".localized }
        static var uploadLimit: String { "documents.upload_limit".localized }
        static var newFolder: String { "documents.new_folder".localized }
        static var recent: String { "documents.recent".localized }
        static var securityNote: String { "documents.security_note".localized }
        static var empty: String { "documents.empty".localized }
        static var emptySub: String { "documents.empty_sub".localized }
    }

    enum Messages {
        static var title: String { "messages.title".localized }
        static var subtitle: String { "messages.subtitle".localized }
        static var searchPlaceholder: String { "messages.search_placeholder".localized }
        static var writePlaceholder: String { "messages.write_placeholder".localized }
        static var notFound: String { "messages.not_found".localized }
        static var notFoundSub: String { "messages.not_found_sub".localized }
        static var totalChat: String { "messages.total_chat".localized }
        static var unread: String { "messages.unread".localized }
    }

    enum Privacy {
        static var title: String { "privacy.title".localized }
        static var subtitle: String { "privacy.subtitle".localized }
        static var accountSafe: String { "privacy.account_safe".localized }
        static var accountSafeSub: String { "privacy.account_safe_sub".localized }
        static var privacySettings: String { "privacy.privacy_settings".localized }
        static var accountSecurity: String { "privacy.account_security".localized }
        static var changePassword: String { "privacy.change_password".localized }
        static var deleteAccount: String { "privacy.delete_account".localized }
        static var activeSessions: String { "privacy.active_sessions".localized }
        static var activeSessionsSub: String { "privacy.active_sessions_sub".localized }
        static var privacyPolicy: String { "privacy.privacy_policy".localized }
        static var helpCenter: String { "privacy.help_center".localized }
        static var socialLoginPassword: String { "privacy.social_login_password".localized }
        static var loginViaSocial: String { "privacy.login_via_social".localized }
        static func passwordLastChanged(_ date: String) -> String { "privacy.password_last_changed".localized(date) }
        static var passwordUpdateHint: String { "privacy.password_update_hint".localized }
        static var dataVisibility: String { "privacy.data_visibility".localized }
        static var dataVisibilitySub: String { "privacy.data_visibility_sub".localized }
        static var notifications: String { "privacy.notifications".localized }
        static var notificationsSub: String { "privacy.notifications_sub".localized }
        static var permissions: String { "privacy.permissions".localized }
        static var permissionsSub: String { "privacy.permissions_sub".localized }
        static var downloadData: String { "privacy.download_data".localized }
        static var downloadDataSub: String { "privacy.download_data_sub".localized }
        static var deleteAccountSub: String { "privacy.delete_account_sub".localized }
        static var trustedDevices: String { "privacy.trusted_devices".localized }
        static var trustedDevicesSub: String { "privacy.trusted_devices_sub".localized }
        static var twoFactor: String { "privacy.two_factor".localized }
        static var twoFactorSub: String { "privacy.two_factor_sub".localized }
        static var twoFactorActive: String { "privacy.two_factor_active".localized }
        static var twoFactorInactive: String { "privacy.two_factor_inactive".localized }
        static var commitment: String { "privacy.commitment".localized }
        static var helpCenterSub: String { "privacy.help_center_sub".localized }
    }

    enum ChangePassword {
        static var title: String { "change_password.title".localized }
        static var subtitle: String { "change_password.subtitle".localized }
        static var section: String { "change_password.section".localized }
        static var current: String { "change_password.current".localized }
        static var newPassword: String { "change_password.new".localized }
        static var confirm: String { "change_password.confirm".localized }
        static var mismatch: String { "change_password.mismatch".localized }
        static var info: String { "change_password.info".localized }
        static var save: String { "change_password.save".localized }
        static var successMessage: String { "change_password.success_message".localized }
    }

    enum DeleteAccount {
        static var title: String { "delete_account.title".localized }
        static var subtitle: String { "delete_account.subtitle".localized }
        static var warningTitle: String { "delete_account.warning_title".localized }
        static var warningMessage: String { "delete_account.warning_message".localized }
        static var confirmSection: String { "delete_account.confirm_section".localized }
        static var passwordPlaceholder: String { "delete_account.password_placeholder".localized }
        static var socialNote: String { "delete_account.social_note".localized }
        static var confirmPlaceholder: String { "delete_account.confirm_placeholder".localized }
        static var dataTitle: String { "delete_account.data_title".localized }
        static var dataProfile: String { "delete_account.data_profile".localized }
        static var dataWedding: String { "delete_account.data_wedding".localized }
        static var dataGuests: String { "delete_account.data_guests".localized }
        static var dataBudget: String { "delete_account.data_budget".localized }
        static var dataChecklist: String { "delete_account.data_checklist".localized }
        static var button: String { "delete_account.button".localized }
        static var alertTitle: String { "delete_account.alert_title".localized }
        static var alertMessage: String { "delete_account.alert_message".localized }
    }

    enum Sessions {
        static var title: String { "sessions.title".localized }
        static var subtitle: String { "sessions.subtitle".localized }
        static var info: String { "sessions.info".localized }
        static var emptyTitle: String { "sessions.empty_title".localized }
        static var emptyMessage: String { "sessions.empty_message".localized }
        static var thisDevice: String { "sessions.this_device".localized }
        static var logout: String { "sessions.logout".localized }
        static var end: String { "sessions.end".localized }
        static var endAll: String { "sessions.end_all".localized }
        static var alertEndTitle: String { "sessions.alert_end_title".localized }
        static var alertEndAction: String { "sessions.alert_end_action".localized }
        static var alertEndCurrent: String { "sessions.alert_end_current".localized }
        static func alertEndDevice(_ device: String) -> String { "sessions.alert_end_device".localized(device) }
        static var alertEndAllTitle: String { "sessions.alert_end_all_title".localized }
        static var alertEndAllAction: String { "sessions.alert_end_all_action".localized }
        static var alertEndAllMessage: String { "sessions.alert_end_all_message".localized }
        static func lastActive(_ date: String) -> String { "sessions.last_active".localized(date) }
        static func loginSince(_ date: String) -> String { "sessions.login_since".localized(date) }
        static var active: String { "sessions.active".localized }
    }

    enum Profile {
        static var title: String { "profile.title".localized }
        static var subtitle: String { "profile.subtitle".localized }
        static var accountSection: String { "profile.account_section".localized }
        static var contactSection: String { "profile.contact_section".localized }
        static var namePlaceholder: String { "profile.name_placeholder".localized }
        static var emailUnavailable: String { "profile.email_unavailable".localized }
        static var emailLocked: String { "profile.email_locked".localized }
        static var whatsappPlaceholder: String { "profile.whatsapp_placeholder".localized }
        static var nameEmpty: String { "profile.name_empty".localized }
        static var photoNote: String { "profile.photo_note".localized }
        static var info: String { "profile.info".localized }
        static var save: String { "profile.save".localized }
    }

    enum Couple {
        static var title: String { "couple.title".localized }
        static var subtitle: String { "couple.subtitle".localized }
        static var nameEmpty: String { "couple.name_empty".localized }
        static var cultureEmpty: String { "couple.culture_empty".localized }
        static var brideSection: String { "couple.bride_section".localized }
        static var groomSection: String { "couple.groom_section".localized }
        static var cultureSection: String { "couple.culture_section".localized }
        static var bridePlaceholder: String { "couple.bride_placeholder".localized }
        static var groomPlaceholder: String { "couple.groom_placeholder".localized }
        static var culturePlaceholder: String { "couple.culture_placeholder".localized }
        static var save: String { "couple.save".localized }
    }

    enum WeddingDetail {
        static var title: String { "wedding_detail.title".localized }
        static var subtitle: String { "wedding_detail.subtitle".localized }
        static var tabSummary: String { "wedding_detail.tab_summary".localized }
        static var tabSchedule: String { "wedding_detail.tab_schedule".localized }
        static var tabGuests: String { "wedding_detail.tab_guests".localized }
        static var eventInfo: String { "wedding_detail.event_info".localized }
        static var eventSeries: String { "wedding_detail.event_series".localized }
        static var notes: String { "wedding_detail.notes".localized }
        static var concept: String { "wedding_detail.concept".localized }
        static var timeUntilDone: String { "wedding_detail.time_until_done".localized }
        static var defaultNote: String { "wedding_detail.default_note".localized }
        static var noGuests: String { "wedding_detail.no_guests".localized }
        static var noGuestsSub: String { "wedding_detail.no_guests_sub".localized }
        static var noEvents: String { "wedding_detail.no_events".localized }
        static var noEventsSub: String { "wedding_detail.no_events_sub".localized }
        static var attending: String { "wedding_detail.attending".localized }
        static var timeNotSet: String { "wedding_detail.time_not_set".localized }
        static var defaultLocation: String { "wedding_detail.default_location".localized }
        static var defaultCouple: String { "wedding_detail.default_couple".localized }
        static var defaultDate: String { "wedding_detail.default_date".localized }
        static var defaultDateWeekday: String { "wedding_detail.default_date_weekday".localized }
    }

    enum InspirationCategory {
        static var decoration: String { "inspiration_category.decoration".localized }
        static var dress: String { "inspiration_category.dress".localized }
        static var makeup: String { "inspiration_category.makeup".localized }
        static var catering: String { "inspiration_category.catering".localized }
        static var venue: String { "inspiration_category.venue".localized }
    }
}
