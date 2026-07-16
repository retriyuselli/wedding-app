<?php

use App\Http\Controllers\Api\V1\AppPermissionController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\BudgetPaymentCategoryController;
use App\Http\Controllers\Api\V1\CategoryController;
use App\Http\Controllers\Api\V1\CustomerNotificationController;
use App\Http\Controllers\Api\V1\CustomerPaymentMethodController;
use App\Http\Controllers\Api\V1\CustomerPreparationSectionController;
use App\Http\Controllers\Api\V1\CustomerPreparationSubTaskController;
use App\Http\Controllers\Api\V1\CustomerPreparationTaskController;
use App\Http\Controllers\Api\V1\DeviceTokenController;
use App\Http\Controllers\Api\V1\DocumentFolderController;
use App\Http\Controllers\Api\V1\FamilyMemberController;
use App\Http\Controllers\Api\V1\GuestController;
use App\Http\Controllers\Api\V1\HelpCenterController;
use App\Http\Controllers\Api\V1\InspirationController;
use App\Http\Controllers\Api\V1\MessageController;
use App\Http\Controllers\Api\V1\PrivacySecurityController;
use App\Http\Controllers\Api\V1\RegionController;
use App\Http\Controllers\Api\V1\TrustedDeviceController;
use App\Http\Controllers\Api\V1\TwoFactorController;
use App\Http\Controllers\Api\V1\UserDataExportController;
use App\Http\Controllers\Api\V1\VendorController;
use App\Http\Controllers\Api\V1\VipGuestController;
use App\Http\Controllers\Api\V1\WeddingBudgetCategoryAllocationController;
use App\Http\Controllers\Api\V1\WeddingBudgetController;
use App\Http\Controllers\Api\V1\WeddingDocumentController;
use App\Http\Controllers\Api\V1\WeddingEventController;
use App\Http\Controllers\Api\V1\WeddingIncomingPaymentController;
use App\Http\Controllers\Api\V1\WeddingInfoController;
use App\Http\Controllers\Api\V1\WeddingPaymentScheduleController;
use App\Http\Controllers\Api\V1\WeddingQuoteController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::get('regions/provinces', [RegionController::class, 'provinces']);
    Route::get('regions/cities', [RegionController::class, 'cities']);

    Route::get('categories', [CategoryController::class, 'index']);
    Route::get('budget-payment-categories', [BudgetPaymentCategoryController::class, 'index']);

    Route::get('wedding-quotes', [WeddingQuoteController::class, 'index']);

    Route::get('vendors', [VendorController::class, 'index']);
    Route::get('vendors/{vendor}/packages', [VendorController::class, 'packages']);
    Route::get('vendors/{vendor}', [VendorController::class, 'show']);

    Route::post('auth/register', [AuthController::class, 'register']);
    Route::post('auth/login', [AuthController::class, 'login']);
    Route::post('auth/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('auth/google', [AuthController::class, 'google']);
    Route::post('auth/apple', [AuthController::class, 'apple']);
    Route::post('auth/two-factor/verify', [TwoFactorController::class, 'verifyLogin']);

    Route::get('help-center', [HelpCenterController::class, 'index']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('auth/logout', [AuthController::class, 'logout']);
        Route::get('auth/me', [AuthController::class, 'me']);
        Route::put('auth/profile', [AuthController::class, 'updateProfile']);
        Route::put('auth/password', [AuthController::class, 'changePassword']);
        Route::get('auth/sessions', [AuthController::class, 'sessions']);
        Route::delete('auth/sessions/others', [AuthController::class, 'destroyOtherSessions']);
        Route::delete('auth/sessions/{token}', [AuthController::class, 'destroySession']);
        Route::delete('auth/account', [AuthController::class, 'deleteAccount']);

        Route::get('privacy/summary', [PrivacySecurityController::class, 'summary']);
        Route::get('privacy/visibility', [PrivacySecurityController::class, 'visibility']);
        Route::put('privacy/visibility', [PrivacySecurityController::class, 'updateVisibility']);
        Route::get('privacy/app-permissions', [AppPermissionController::class, 'index']);
        Route::get('privacy/data-export', [UserDataExportController::class, 'download']);

        Route::get('privacy/two-factor', [TwoFactorController::class, 'status']);
        Route::post('privacy/two-factor/enable', [TwoFactorController::class, 'enable']);
        Route::post('privacy/two-factor/confirm', [TwoFactorController::class, 'confirm']);
        Route::post('privacy/two-factor/disable', [TwoFactorController::class, 'disable']);
        Route::post('privacy/two-factor/confirm-disable', [TwoFactorController::class, 'confirmDisable']);

        Route::get('privacy/trusted-devices', [TrustedDeviceController::class, 'index']);
        Route::post('privacy/trusted-devices', [TrustedDeviceController::class, 'store']);
        Route::put('privacy/trusted-devices/{trustedDevice}', [TrustedDeviceController::class, 'update']);
        Route::delete('privacy/trusted-devices/{trustedDevice}', [TrustedDeviceController::class, 'destroy']);

        Route::get('wedding-info', [WeddingInfoController::class, 'show']);
        Route::put('wedding-info', [WeddingInfoController::class, 'update']);
        Route::post('wedding-info/photo', [WeddingInfoController::class, 'uploadPhoto']);

        Route::get('wedding-budget/summary', [WeddingBudgetController::class, 'summary']);
        Route::get('wedding-budget', [WeddingBudgetController::class, 'show']);
        Route::put('wedding-budget', [WeddingBudgetController::class, 'update']);

        Route::apiResource('wedding-budget-category-allocations', WeddingBudgetCategoryAllocationController::class)
            ->parameters(['wedding-budget-category-allocations' => 'weddingBudgetCategoryAllocation']);

        Route::apiResource('wedding-events', WeddingEventController::class)
            ->parameters(['wedding-events' => 'weddingEvent']);

        Route::apiResource('customer-payment-methods', CustomerPaymentMethodController::class)
            ->parameters(['customer-payment-methods' => 'customerPaymentMethod']);

        Route::apiResource('wedding-payment-schedules', WeddingPaymentScheduleController::class)
            ->parameters(['wedding-payment-schedules' => 'weddingPaymentSchedule']);
        Route::patch('wedding-payment-schedules/{weddingPaymentSchedule}/mark-paid', [WeddingPaymentScheduleController::class, 'markPaid']);

        Route::apiResource('wedding-incoming-payments', WeddingIncomingPaymentController::class)
            ->parameters(['wedding-incoming-payments' => 'weddingIncomingPayment']);

        Route::apiResource('customer-preparation-sections', CustomerPreparationSectionController::class)
            ->parameters(['customer-preparation-sections' => 'customerPreparationSection']);

        Route::get('customer-preparation-tasks/summary', [CustomerPreparationTaskController::class, 'summary']);
        Route::apiResource('customer-preparation-tasks', CustomerPreparationTaskController::class)
            ->parameters(['customer-preparation-tasks' => 'customerPreparationTask']);
        Route::patch('customer-preparation-tasks/{customerPreparationTask}/toggle', [CustomerPreparationTaskController::class, 'toggle']);
        Route::patch('customer-preparation-sub-tasks/{customerPreparationSubTask}/toggle', [CustomerPreparationSubTaskController::class, 'toggle']);

        Route::apiResource('family-members', FamilyMemberController::class)
            ->parameters(['family-members' => 'familyMember']);
        Route::patch('family-members/{familyMember}/rsvp', [FamilyMemberController::class, 'updateRsvp']);
        Route::get('family-members-excel-template', [FamilyMemberController::class, 'downloadTemplate']);
        Route::post('family-members-import-excel', [FamilyMemberController::class, 'importExcel']);
        Route::delete('family-members-all', [FamilyMemberController::class, 'destroyAll']);

        Route::apiResource('vip-guests', VipGuestController::class)
            ->parameters(['vip-guests' => 'vipGuest']);
        Route::patch('vip-guests/{vipGuest}/rsvp', [VipGuestController::class, 'updateRsvp']);
        Route::get('vip-guests-excel-template', [VipGuestController::class, 'downloadTemplate']);
        Route::post('vip-guests-import-excel', [VipGuestController::class, 'importExcel']);
        Route::delete('vip-guests-all', [VipGuestController::class, 'destroyAll']);

        Route::apiResource('guests', GuestController::class);
        Route::patch('guests/{guest}/rsvp', [GuestController::class, 'updateRsvp']);
        Route::get('guests-excel-template', [GuestController::class, 'downloadTemplate']);
        Route::post('guests-import-excel', [GuestController::class, 'importExcel']);
        Route::delete('guests-all', [GuestController::class, 'destroyAll']);

        Route::apiResource('document-folders', DocumentFolderController::class)
            ->except(['show'])
            ->parameters(['document-folders' => 'documentFolder']);

        Route::get('wedding-documents/summary', [WeddingDocumentController::class, 'summary']);
        Route::get('wedding-documents/{weddingDocument}/download', [WeddingDocumentController::class, 'download']);
        Route::apiResource('wedding-documents', WeddingDocumentController::class)
            ->except(['show'])
            ->parameters(['wedding-documents' => 'weddingDocument']);

        Route::apiResource('customer-notifications', CustomerNotificationController::class)
            ->only(['index', 'show', 'destroy'])
            ->parameters(['customer-notifications' => 'customerNotification']);
        Route::patch('customer-notifications/{customerNotification}/mark-read', [CustomerNotificationController::class, 'markRead']);

        Route::post('device-tokens', [DeviceTokenController::class, 'store']);
        Route::post('device-tokens/test', [DeviceTokenController::class, 'sendTest']);
        Route::delete('device-tokens', [DeviceTokenController::class, 'destroy']);

        Route::get('messages/threads', [MessageController::class, 'threads']);
        Route::get('messages/threads/support', [MessageController::class, 'supportThread']);
        Route::get('messages/threads/{thread}', [MessageController::class, 'show']);
        Route::post('messages/threads/{thread}/send', [MessageController::class, 'send']);
        Route::delete('messages/threads/{thread}', [MessageController::class, 'destroy']);

        Route::get('inspirations', [InspirationController::class, 'index']);
        Route::post('inspirations/{inspiration}/save', [InspirationController::class, 'save']);
        Route::delete('inspirations/{inspiration}/save', [InspirationController::class, 'unsave']);
        Route::post('inspirations/{inspiration}/like', [InspirationController::class, 'like']);
        Route::delete('inspirations/{inspiration}/like', [InspirationController::class, 'unlike']);
    });
});
