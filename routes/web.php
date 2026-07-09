<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\BantuanController;
use App\Http\Controllers\BiayaController;
use App\Http\Controllers\ChecklistController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\DokumenController;
use App\Http\Controllers\InspirationController;
use App\Http\Controllers\LegalController;
use App\Http\Controllers\MessageController;
use App\Http\Controllers\ProfilController;
use App\Http\Controllers\TamuController;
use App\Http\Controllers\UangMasukController;
use App\Http\Controllers\VendorController;
use Illuminate\Support\Facades\Route;

Route::get('/privacy-policy', [LegalController::class, 'privacyPolicy'])->name('privacy-policy');
Route::get('/terms', [LegalController::class, 'termsOfService'])->name('terms');

Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AuthController::class, 'login']);
    Route::get('/register', [AuthController::class, 'showRegister'])->name('register');
    Route::post('/register', [AuthController::class, 'register']);
});

Route::post('/logout', [AuthController::class, 'logout'])->name('logout')->middleware('auth');

Route::middleware('auth')->group(function () {
    // Dashboard
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');

    // Checklist — events, sections, tasks
    Route::get('/checklist', [ChecklistController::class, 'index'])->name('checklist');

    Route::get('/checklist/events/create', [ChecklistController::class, 'createEvent'])->name('checklist.events.create');
    Route::post('/checklist/events', [ChecklistController::class, 'storeEvent'])->name('checklist.events.store');
    Route::get('/checklist/events/{id}/edit', [ChecklistController::class, 'editEvent'])->name('checklist.events.edit');
    Route::put('/checklist/events/{id}', [ChecklistController::class, 'updateEvent'])->name('checklist.events.update');
    Route::delete('/checklist/events/{id}', [ChecklistController::class, 'destroyEvent'])->name('checklist.events.destroy');

    Route::get('/checklist/sections/create', [ChecklistController::class, 'createSection'])->name('checklist.sections.create');
    Route::post('/checklist/sections', [ChecklistController::class, 'storeSection'])->name('checklist.sections.store');
    Route::get('/checklist/sections/{id}/edit', [ChecklistController::class, 'editSection'])->name('checklist.sections.edit');
    Route::put('/checklist/sections/{id}', [ChecklistController::class, 'updateSection'])->name('checklist.sections.update');
    Route::delete('/checklist/sections/{id}', [ChecklistController::class, 'destroySection'])->name('checklist.sections.destroy');

    Route::get('/checklist/tasks/create', [ChecklistController::class, 'createTask'])->name('checklist.tasks.create');
    Route::post('/checklist/tasks', [ChecklistController::class, 'storeTask'])->name('checklist.tasks.store');
    Route::get('/checklist/tasks/{id}/edit', [ChecklistController::class, 'editTask'])->name('checklist.tasks.edit');
    Route::put('/checklist/tasks/{id}', [ChecklistController::class, 'updateTask'])->name('checklist.tasks.update');
    Route::delete('/checklist/tasks/{id}', [ChecklistController::class, 'destroyTask'])->name('checklist.tasks.destroy');
    Route::patch('/checklist/tasks/{id}/toggle', [ChecklistController::class, 'toggleTask'])->name('checklist.tasks.toggle');

    // Biaya
    Route::get('/biaya', [BiayaController::class, 'index'])->name('biaya');
    Route::get('/biaya/budget', [BiayaController::class, 'editBudget'])->name('biaya.budget');
    Route::put('/biaya/budget', [BiayaController::class, 'updateBudget'])->name('biaya.budget.update');
    Route::get('/biaya/create', [BiayaController::class, 'create'])->name('biaya.create');
    Route::post('/biaya', [BiayaController::class, 'store'])->name('biaya.store');
    Route::get('/biaya/{id}/edit', [BiayaController::class, 'edit'])->name('biaya.edit');
    Route::put('/biaya/{id}', [BiayaController::class, 'update'])->name('biaya.update');
    Route::delete('/biaya/{id}', [BiayaController::class, 'destroy'])->name('biaya.destroy');
    Route::patch('/biaya/{id}/mark-paid', [BiayaController::class, 'markPaid'])->name('biaya.markPaid');

    // Tamu
    Route::get('/tamu', [TamuController::class, 'index'])->name('tamu');
    Route::get('/tamu/create', [TamuController::class, 'create'])->name('tamu.create');
    Route::post('/tamu', [TamuController::class, 'store'])->name('tamu.store');
    Route::get('/tamu/{tab}/{id}/edit', [TamuController::class, 'edit'])->name('tamu.edit');
    Route::put('/tamu/{tab}/{id}', [TamuController::class, 'update'])->name('tamu.update');
    Route::delete('/tamu/{tab}/{id}', [TamuController::class, 'destroy'])->name('tamu.destroy');
    Route::patch('/tamu/{tab}/{id}/rsvp', [TamuController::class, 'updateRsvp'])->name('tamu.rsvp');

    // Vendor
    Route::get('/vendor', [VendorController::class, 'index'])->name('vendor');
    Route::post('/vendor/{vendor}/favorite', [VendorController::class, 'toggleFavorite'])->name('vendor.favorite');

    // Inspiration
    Route::get('/inspiration', [InspirationController::class, 'index'])->name('inspiration');
    Route::post('/inspiration/{inspiration}/save', [InspirationController::class, 'toggleSave'])->name('inspiration.save');

    // Messages
    Route::get('/messages', [MessageController::class, 'index'])->name('messages');
    Route::post('/messages/{thread}/send', [MessageController::class, 'send'])->name('messages.send');
    Route::post('/messages/{thread}/favorite', [MessageController::class, 'toggleFavorite'])->name('messages.favorite');

    // Uang Masuk
    Route::get('/uang-masuk', [UangMasukController::class, 'index'])->name('uang-masuk');
    Route::get('/uang-masuk/create', [UangMasukController::class, 'create'])->name('uang-masuk.create');
    Route::post('/uang-masuk', [UangMasukController::class, 'store'])->name('uang-masuk.store');
    Route::get('/uang-masuk/{id}/edit', [UangMasukController::class, 'edit'])->name('uang-masuk.edit');
    Route::put('/uang-masuk/{id}', [UangMasukController::class, 'update'])->name('uang-masuk.update');
    Route::delete('/uang-masuk/{id}', [UangMasukController::class, 'destroy'])->name('uang-masuk.destroy');

    // Profil
    Route::get('/profil', [ProfilController::class, 'index'])->name('profil');
    Route::put('/profil', [ProfilController::class, 'updateProfile'])->name('profil.update');
    Route::put('/profil/wedding-info', [ProfilController::class, 'updateWeddingInfo'])->name('profil.wedding');
    Route::put('/profil/password', [ProfilController::class, 'updatePassword'])->name('profil.password');

    // Dokumen
    Route::get('/dokumen', [DokumenController::class, 'index'])->name('dokumen');

    // Bantuan
    Route::get('/bantuan', [BantuanController::class, 'index'])->name('bantuan');
});
