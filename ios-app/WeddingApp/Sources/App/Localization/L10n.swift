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
        static var heroTagline: String { "auth.hero_tagline".localized }
        static var welcome: String { "auth.welcome".localized }
        static var loginSubtitle: String { "auth.login_subtitle".localized }
        static var createAccount: String { "auth.create_account".localized }
        static var loginCta: String { "auth.login_cta".localized }
        static var emailOrPhone: String { "auth.email_or_phone".localized }
        static var email: String { "auth.email".localized }
        static var emailPlaceholder: String { "auth.email_placeholder".localized }
        static var password: String { "auth.password".localized }
        static var passwordPlaceholder: String { "auth.password_placeholder".localized }
        static var confirmPassword: String { "auth.confirm_password".localized }
        static var fullName: String { "auth.full_name".localized }
        static var fullNamePlaceholder: String { "auth.full_name_placeholder".localized }
        static var invalidEmail: String { "auth.invalid_email".localized }
        static var passwordMismatch: String { "auth.password_mismatch".localized }
        static var emailRequired: String { "auth.email_required".localized }
        static var forgotPassword: String { "auth.forgot_password".localized }
        static var forgotTitle: String { "auth.forgot_title".localized }
        static var forgotSubtitle: String { "auth.forgot_subtitle".localized }
        static var forgotSend: String { "auth.forgot_send".localized }
        static var forgotResend: String { "auth.forgot_resend".localized }
        static var forgotBackToLogin: String { "auth.forgot_back_to_login".localized }
        static var forgotSent: String { "auth.forgot_sent".localized }
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
        static var back: String { "auth.back".localized }
        static var googleNotConfigured: String { "auth.google_not_configured".localized }
        static var googleCannotOpen: String { "auth.google_cannot_open".localized }
        static var googleTokenMissing: String { "auth.google_token_missing".localized }
        static var googleCancelled: String { "auth.google_cancelled".localized }
        static var appleTokenMissing: String { "auth.apple_token_missing".localized }
        static var appleCancelled: String { "auth.apple_cancelled".localized }
        static var appleFailed: String { "auth.apple_failed".localized }
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

    enum Settings {
        static var title: String { "settings.title".localized }
        static var subtitle: String { "settings.subtitle".localized }
        static var preferencesSection: String { "settings.preferences_section".localized }
        static var appearanceSection: String { "settings.appearance_section".localized }
        static var accountSection: String { "settings.account_section".localized }
        static var notifications: String { "settings.notifications".localized }
        static var language: String { "settings.language".localized }
        static var theme: String { "settings.theme".localized }
        static var themeSub: String { "settings.theme_sub".localized }
        static var themeChooserSub: String { "settings.theme_chooser_sub".localized }
        static var colorPaletteSection: String { "settings.color_palette_section".localized }
        static var appearanceModeSection: String { "settings.appearance_mode_section".localized }
        static var paletteSage: String { "settings.palette_sage".localized }
        static var paletteSageSub: String { "settings.palette_sage_sub".localized }
        static var paletteBlush: String { "settings.palette_blush".localized }
        static var paletteBlushSub: String { "settings.palette_blush_sub".localized }
        static var paletteChampagne: String { "settings.palette_champagne".localized }
        static var paletteChampagneSub: String { "settings.palette_champagne_sub".localized }
        static var paletteOcean: String { "settings.palette_ocean".localized }
        static var paletteOceanSub: String { "settings.palette_ocean_sub".localized }
        static var themeSystem: String { "settings.theme_system".localized }
        static var themeSystemSub: String { "settings.theme_system_sub".localized }
        static var themeLight: String { "settings.theme_light".localized }
        static var themeLightSub: String { "settings.theme_light_sub".localized }
        static var themeDark: String { "settings.theme_dark".localized }
        static var themeDarkSub: String { "settings.theme_dark_sub".localized }
        static var themeInfo: String { "settings.theme_info".localized }
        static var textSize: String { "settings.text_size".localized }
        static var textSizeSub: String { "settings.text_size_sub".localized }
        static var textSizeChooserSub: String { "settings.text_size_chooser_sub".localized }
        static var textSizeSmall: String { "settings.text_size_small".localized }
        static var textSizeSmallSub: String { "settings.text_size_small_sub".localized }
        static var textSizeMedium: String { "settings.text_size_medium".localized }
        static var textSizeMediumSub: String { "settings.text_size_medium_sub".localized }
        static var textSizeLarge: String { "settings.text_size_large".localized }
        static var textSizeLargeSub: String { "settings.text_size_large_sub".localized }
        static var textSizePreview: String { "settings.text_size_preview".localized }
        static var textSizePreviewSample: String { "settings.text_size_preview_sample".localized }
        static var textSizeInfo: String { "settings.text_size_info".localized }
        static var editProfile: String { "settings.edit_profile".localized }
        static var editProfileSub: String { "settings.edit_profile_sub".localized }
        static var privacySecurity: String { "settings.privacy_security".localized }
        static var privacySecuritySub: String { "settings.privacy_security_sub".localized }
        static var info: String { "settings.info".localized }
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
        static var noUnreadNotifications: String { "dashboard.no_unread_notifications".localized }
        static var noUnreadNotificationsSub: String { "dashboard.no_unread_notifications_sub".localized }
        static func notificationsAccountHint(_ email: String) -> String { "dashboard.notifications_account_hint".localized(email) }
        static var notificationsLoadError: String { "dashboard.notifications_load_error".localized }
        static var markRead: String { "dashboard.mark_read".localized }
        static var markAllRead: String { "dashboard.mark_all_read".localized }
        static var unreadOnly: String { "dashboard.unread_only".localized }
        static var notificationGroupPayment: String { "dashboard.notification_group_payment".localized }
        static var notificationGroupGuest: String { "dashboard.notification_group_guest".localized }
        static var notificationGroupPreparation: String { "dashboard.notification_group_preparation".localized }
        static var notificationGroupSystem: String { "dashboard.notification_group_system".localized }
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
        static var addVip: String { "guest.add_vip".localized }
        static var addFamily: String { "guest.add_family".localized }
        static var sortName: String { "guest.sort_name".localized }
        static var sortNumberAsc: String { "guest.sort_number_asc".localized }
        static var sortNameAsc: String { "guest.sort_name_asc".localized }
        static var sortNameDesc: String { "guest.sort_name_desc".localized }
        static var sequenceNumber: String { "guest.sequence_number".localized }
        static var name: String { "guest.name".localized }
        static var phone: String { "guest.phone".localized }
        static var email: String { "guest.email".localized }
        static var notes: String { "guest.notes".localized }
        static var tableNumberField: String { "guest.table_number_field".localized }
        static func tableNumber(_ number: String) -> String { "guest.table_number".localized(number) }
        static var position: String { "guest.position".localized }
        static var institution: String { "guest.institution".localized }
        static var category: String { "guest.category".localized }
        static var familyRole: String { "guest.family_role".localized }
        static var familyMemberFallback: String { "guest.family_member_fallback".localized }
        static var emptyTitle: String { "guest.empty_title".localized }
        static var emptySub: String { "guest.empty_sub".localized }
        static var emptyVipTitle: String { "guest.empty_vip_title".localized }
        static var emptyVipSub: String { "guest.empty_vip_sub".localized }
        static var emptyFamilyTitle: String { "guest.empty_family_title".localized }
        static var emptyFamilySub: String { "guest.empty_family_sub".localized }
        static var noResults: String { "guest.no_results".localized }
        static var tabGuests: String { "guest.tab_guests".localized }
        static var tabVip: String { "guest.tab_vip".localized }
        static var tabFamily: String { "guest.tab_family".localized }
        static func listCount(_ title: String, _ count: Int) -> String { "guest.list_count".localized(title, count) }
        static var shareInvite: String { "guest.share_invite".localized }
        static var shareInviteSub: String { "guest.share_invite_sub".localized }
        static var qrCheckIn: String { "guest.qr_check_in".localized }
        static var qrCheckInSub: String { "guest.qr_check_in_sub".localized }
        static var exportData: String { "guest.export_data".localized }
        static var exportDataSub: String { "guest.export_data_sub".localized }
        static var vipCategoryVip: String { "guest.vip_category_vip".localized }
        static var vipCategoryFamily: String { "guest.vip_category_family".localized }
        static var vipCategoryOfficial: String { "guest.vip_category_official".localized }
        static var vipCategoryFigure: String { "guest.vip_category_figure".localized }
        static var vipCategoryBusiness: String { "guest.vip_category_business".localized }
        static var vipCategoryFriend: String { "guest.vip_category_friend".localized }
        static var detailTitle: String { "guest.detail_title".localized }
        static var detailSection: String { "guest.detail_section".localized }
        static var rsvpStatus: String { "guest.rsvp_status".localized }
        static var editEntry: String { "guest.edit_entry".localized }
        static var deleteEntry: String { "guest.delete_entry".localized }
        static var deleteConfirmTitle: String { "guest.delete_confirm_title".localized }
        static func deleteConfirmMessage(_ name: String) -> String { "guest.delete_confirm_message".localized(name) }
        static func rsvpUpdatedBy(_ name: String) -> String { "guest.rsvp_updated_by".localized(name) }
        static func rsvpUpdatedAt(_ date: String) -> String { "guest.rsvp_updated_at".localized(date) }
        static func rsvpUpdatedByAt(_ name: String, _ date: String) -> String {
            "guest.rsvp_updated_by_at".localized(name, date)
        }
        static var exportTitle: String { "guest.export_title".localized }
        static var exportOverview: String { "guest.export_overview".localized }
        static var exportIncluded: String { "guest.export_included".localized }
        static var exportFormatTitle: String { "guest.export_format_title".localized }
        static var exportFormatSub: String { "guest.export_format_sub".localized }
        static var exportShareAction: String { "guest.export_share_action".localized }
        static var exportEmpty: String { "guest.export_empty".localized }
        static var downloadTemplate: String { "guest.download_template".localized }
        static var uploadExcel: String { "guest.upload_excel".localized }
        static var templateReady: String { "guest.template_ready".localized }
        static var shareTemplate: String { "guest.share_template".localized }
        static var importDoneTitle: String { "guest.import_done_title".localized }
        static func importDoneMessage(_ imported: Int, _ skipped: Int) -> String {
            "guest.import_done_message".localized(imported, skipped)
        }
        static var excelFileTooLarge: String { "guest.excel_file_too_large".localized }
        static func deleteAll(_ segment: String) -> String { "guest.delete_all".localized(segment) }
        static var deleteAllAction: String { "guest.delete_all_action".localized }
        static func deleteAllConfirmTitle(_ segment: String) -> String {
            "guest.delete_all_confirm_title".localized(segment)
        }
        static func deleteAllConfirmMessage(_ segment: String, _ count: Int) -> String {
            "guest.delete_all_confirm_message".localized(segment, count)
        }
        static var deleteAllDoneTitle: String { "guest.delete_all_done_title".localized }
        static func deleteAllDoneMessage(_ segment: String, _ count: Int) -> String {
            "guest.delete_all_done_message".localized(segment, count)
        }
        static var loadMore: String { "guest.load_more".localized }
        static func showingCount(_ shown: Int, _ total: Int) -> String {
            "guest.showing_count".localized(shown, total)
        }
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
        static var emptyTitle: String { "checklist.empty_title".localized }
        static var emptySub: String { "checklist.empty_sub".localized }
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
        static var tapToSetTotal: String { "budget.tap_to_set_total".localized }
        static func allocationOfPlan(_ percent: Int) -> String { "budget.allocation_of_plan".localized(percent) }
        static var totalPlan: String { "budget.total_plan".localized }
        static var searchPlaceholder: String { "budget.search_placeholder".localized }
        static var searchEmptyTitle: String { "budget.search_empty_title".localized }
        static var searchEmptySub: String { "budget.search_empty_sub".localized }
        static var searchNotFound: String { "budget.search_not_found".localized }
        static func searchNoResults(_ query: String) -> String { "budget.search_no_results".localized(query) }
        static var summary: String { "budget.summary".localized }
        static var categoriesAction: String { "budget.categories_action".localized }
        static var categoriesActionSub: String { "budget.categories_action_sub".localized }
        static var report: String { "budget.report".localized }
        static var reportSub: String { "budget.report_sub".localized }
        static func allocationAmount(_ amount: String) -> String { "budget.allocation_amount".localized(amount) }
        static func notSetRecorded(_ amount: String) -> String { "budget.not_set_recorded".localized(amount) }
        static func commitmentAmount(_ amount: String) -> String { "budget.commitment_amount".localized(amount) }
        static func percentUsed(_ percent: Int) -> String { "budget.percent_used".localized(percent) }
        static func percentPaid(_ percent: Int) -> String { "budget.percent_paid".localized(percent) }
        static func percentOfTotal(_ percent: Int) -> String { "budget.percent_of_total".localized(percent) }
        static var allocation: String { "budget.allocation".localized }
        static var categoryPlan: String { "budget.category_plan".localized }
        static var awaitingPayment: String { "budget.awaiting_payment".localized }
        static var noExpenseRecorded: String { "budget.no_expense_recorded".localized }
        static func spentOfAllocation(_ percent: Int, _ amount: String) -> String { "budget.spent_of_allocation".localized(percent, amount) }
        static func paidFromRecordedWaiting(_ paid: String, _ recorded: String) -> String { "budget.paid_from_recorded_waiting".localized(paid, recorded) }
        static func paidPercentFromRecorded(_ percent: Int, _ recorded: String) -> String { "budget.paid_percent_from_recorded".localized(percent, recorded) }
        static var reportTitleFull: String { "budget.report_title_full".localized }
        static func reportTotalBudget(_ amount: String) -> String { "budget.report_total_budget".localized(amount) }
        static func reportSpent(_ amount: String, _ percent: Int) -> String { "budget.report_spent".localized(amount, percent) }
        static func reportCommitment(_ amount: String, _ percent: Int) -> String { "budget.report_commitment".localized(amount, percent) }
        static func reportRemaining(_ amount: String, _ percent: Int) -> String { "budget.report_remaining".localized(amount, percent) }
        static func reportOverBudget(_ amount: String, _ percent: Int) -> String { "budget.report_over_budget".localized(amount, percent) }
        static func reportIncoming(_ amount: String) -> String { "budget.report_incoming".localized(amount) }
        static var reportPerCategory: String { "budget.report_per_category".localized }
        static func reportCategoryLine(_ name: String, _ spent: String, _ recorded: String) -> String { "budget.report_category_line".localized(name, spent, recorded) }
        static func reportAllocationLine(_ amount: String) -> String { "budget.report_allocation_line".localized(amount) }
        static var reportAllocationNotSet: String { "budget.report_allocation_not_set".localized }
        static func reportCommitmentLine(_ amount: String) -> String { "budget.report_commitment_line".localized(amount) }
        static var overBudget: String { "budget.over_budget".localized }
        static func overBudgetBy(_ amount: String) -> String { "budget.over_budget_by".localized(amount) }
        static var reportOverview: String { "budget.report_overview".localized }
        static var reportCategories: String { "budget.report_categories".localized }
        static var reportAllocationLabel: String { "budget.report_allocation_label".localized }
        static var reportRecordedLabel: String { "budget.report_recorded_label".localized }
        static var reportSpentLabel: String { "budget.report_spent_label".localized }
        static var notSetShort: String { "budget.not_set_short".localized }
        static var editExpense: String { "budget.edit_expense".localized }
        static var addExpenseFormSub: String { "budget.add_expense_form_sub".localized }
        static var editExpenseFormSub: String { "budget.edit_expense_form_sub".localized }
        static var pickCategory: String { "budget.pick_category".localized }
        static var pickPaymentMethod: String { "budget.pick_payment_method".localized }
        static var noEventOptional: String { "budget.no_event_optional".localized }
        static var expenseTitlePlaceholder: String { "budget.expense_title_placeholder".localized }
        static var vendorOptional: String { "budget.vendor_optional".localized }
        static var enterAmount: String { "budget.enter_amount".localized }
        static var notesPlaceholder: String { "budget.notes_placeholder".localized }
        static var deleteExpense: String { "budget.delete_expense".localized }
        static var paymentStatus: String { "budget.payment_status".localized }
        static var unpaid: String { "budget.unpaid".localized }
        static var paid: String { "budget.paid".localized }
        static var overdue: String { "budget.overdue".localized }
        static var statusHintPaid: String { "budget.status_hint_paid".localized }
        static var statusHintOverdue: String { "budget.status_hint_overdue".localized }
        static var statusHintPending: String { "budget.status_hint_pending".localized }
        static var proofOptional: String { "budget.proof_optional".localized }
        static var view: String { "budget.view".localized }
        static var replaceProof: String { "budget.replace_proof".localized }
        static var proofMaxSize: String { "budget.proof_max_size".localized }
        static var tapToOpenProof: String { "budget.tap_to_open_proof".localized }
        static var addProof: String { "budget.add_proof".localized }
        static var saveExpense: String { "budget.save_expense".localized }
        static var saveChanges: String { "budget.save_changes".localized }
        static var fileTooLarge: String { "budget.file_too_large".localized }
        static var fileTooLargeDefault: String { "budget.file_too_large_default".localized }
        static func fileTooLargeDetail(_ size: String) -> String { "budget.file_too_large_detail".localized(size) }
        static var proofReadError: String { "budget.proof_read_error".localized }
        static var proof: String { "budget.proof".localized }
        static var openDocument: String { "budget.open_document".localized }
        static var pdfProof: String { "budget.pdf_proof".localized }
        static var proofLoadError: String { "budget.proof_load_error".localized }
        static var proofLoadErrorSub: String { "budget.proof_load_error_sub".localized }
        static var proofUnavailable: String { "budget.proof_unavailable".localized }
        static var proofNoFile: String { "budget.proof_no_file".localized }
        static var pickCategoryTitle: String { "budget.pick_category_title".localized }
        static var pickDate: String { "budget.pick_date".localized }
        static var pickEvent: String { "budget.pick_event".localized }
        static var paymentMethodTitle: String { "budget.payment_method_title".localized }
        static var noEvent: String { "budget.no_event".localized }
        static var noPaymentMethods: String { "budget.no_payment_methods".localized }
        static var noPaymentMethodsSub: String { "budget.no_payment_methods_sub".localized }
        static var addPaymentMethod: String { "budget.add_payment_method".localized }
        static var paymentMethodName: String { "budget.payment_method_name".localized }
        static var accountNumber: String { "budget.account_number".localized }
        static var accountName: String { "budget.account_name".localized }
        static var paymentType: String { "budget.payment_type".localized }
        static var paymentTypeBank: String { "budget.payment_type_bank".localized }
        static var paymentTypeEwallet: String { "budget.payment_type_ewallet".localized }
        static var paymentTypeCash: String { "budget.payment_type_cash".localized }
        static var paymentTypeOther: String { "budget.payment_type_other".localized }
        static var isPrimaryMethod: String { "budget.is_primary_method".localized }
        static var savePaymentMethod: String { "budget.save_payment_method".localized }
        static var chooseProofSource: String { "budget.choose_proof_source".localized }
        static var choosePhoto: String { "budget.choose_photo".localized }
        static var chooseFile: String { "budget.choose_file".localized }
        static var filterExpenses: String { "budget.filter_expenses".localized }
        static var filterActive: String { "budget.filter_active".localized }
        static var clearFilter: String { "budget.clear_filter".localized }
        static var downloadShareReport: String { "budget.download_share_report".localized }
        static var noExpensesScheduleSub: String { "budget.no_expenses_schedule_sub".localized }
        static var markPaid: String { "budget.mark_paid".localized }
        static var noExpensesSummarySub: String { "budget.no_expenses_summary_sub".localized }
        static var perCategory: String { "budget.per_category".localized }
        static var remainingShort: String { "budget.remaining_short".localized }
        static var noCategories: String { "budget.no_categories".localized }
        static var categoriesLoadError: String { "budget.categories_load_error".localized }
        static var categoriesTitle: String { "budget.categories_title".localized }
        static func editAllocationNamed(_ name: String) -> String { "budget.edit_allocation_named".localized(name) }
        static func setAllocationNamed(_ name: String) -> String { "budget.set_allocation_named".localized(name) }
        static var totalCategoryAllocation: String { "budget.total_category_allocation".localized }
        static func fromTotal(_ amount: String) -> String { "budget.from_total".localized(amount) }
        static var tapToAllocate: String { "budget.tap_to_allocate".localized }
        static func allocationPlanEmpty(_ amount: String) -> String { "budget.allocation_plan_empty".localized(amount) }
        static func suggestedFromRecorded(_ amount: String) -> String { "budget.suggested_from_recorded".localized(amount) }
        static var useSuggestedAmount: String { "budget.use_suggested_amount".localized }
        static var setAllocationPromptTitle: String { "budget.set_allocation_prompt_title".localized }
        static var setAllocationPromptSub: String { "budget.set_allocation_prompt_sub".localized }
        static func paidOn(_ date: String) -> String { "budget.paid_on".localized(date) }
        static func dueOn(_ date: String) -> String { "budget.due_on".localized(date) }
        static var setBudget: String { "budget.set_budget".localized }
        static var setBudgetSub: String { "budget.set_budget_sub".localized }
        static var ceilingHint: String { "budget.ceiling_hint".localized }
        static var budgetNotesPlaceholder: String { "budget.budget_notes_placeholder".localized }
        static var spendingPlan: String { "budget.spending_plan".localized }
        static var spendingPlanInfo: String { "budget.spending_plan_info".localized }
        static var saveBudget: String { "budget.save_budget".localized }
        static var editAllocation: String { "budget.edit_allocation".localized }
        static var setAllocation: String { "budget.set_allocation".localized }
        static var budgetAllocation: String { "budget.budget_allocation".localized }
        static var allocationAmountField: String { "budget.allocation_amount_field".localized }
        static var optional: String { "budget.optional".localized }
        static var deleteAllocation: String { "budget.delete_allocation".localized }
        static func spentCommitmentLine(_ spent: String, _ commitment: String) -> String { "budget.spent_commitment_line".localized(spent, commitment) }
        static var summaryShort: String { "budget.summary_short".localized }
        static var recorded: String { "budget.recorded".localized }
        static var allocationRemaining: String { "budget.allocation_remaining".localized }
        static var saveAllocation: String { "budget.save_allocation".localized }
        static var incomingTotalRecorded: String { "budget.incoming_total_recorded".localized }
        static var incomingNotAffectRemaining: String { "budget.incoming_not_affect_remaining".localized }
        static var confirmed: String { "budget.confirmed".localized }
        static func pendingCount(_ count: Int) -> String { "budget.pending_count".localized(count) }
        static var noIncoming: String { "budget.no_incoming".localized }
        static var incomingEmpty: String { "budget.incoming_empty".localized }
        static var incomingEmptyAllSub: String { "budget.incoming_empty_all_sub".localized }
        static var incomingEmptyPending: String { "budget.incoming_empty_pending".localized }
        static var incomingEmptyConfirmed: String { "budget.incoming_empty_confirmed".localized }
        static var incomingEmptyRejected: String { "budget.incoming_empty_rejected".localized }
        static var total: String { "budget.total".localized }
        static var addIncoming: String { "budget.add_incoming".localized }
        static var editIncoming: String { "budget.edit_incoming".localized }
        static var sender: String { "budget.sender".localized }
        static var amount: String { "budget.amount".localized }
        static var transferDate: String { "budget.transfer_date".localized }
        static var optionalDetail: String { "budget.optional_detail".localized }
        static var receiveStatus: String { "budget.receive_status".localized }
        static var status: String { "budget.status".localized }
        static var senderPlaceholder: String { "budget.sender_placeholder".localized }
        static var amountPlaceholder: String { "budget.amount_placeholder".localized }
        static var bankPlaceholder: String { "budget.bank_placeholder".localized }
        static var descriptionPlaceholder: String { "budget.description_placeholder".localized }
        static var referencePlaceholder: String { "budget.reference_placeholder".localized }
        static var statusPending: String { "budget.status_pending".localized }
        static var statusRejected: String { "budget.status_rejected".localized }
        static var incomingStatusHintConfirmed: String { "budget.incoming_status_hint_confirmed".localized }
        static var incomingStatusHintRejected: String { "budget.incoming_status_hint_rejected".localized }
        static var incomingStatusHintPending: String { "budget.incoming_status_hint_pending".localized }
        static var saveIncoming: String { "budget.save_incoming".localized }
        static func ref(_ number: String) -> String { "budget.ref".localized(number) }
        static var unnamedSender: String { "budget.unnamed_sender".localized }
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
