<?php

namespace Database\Seeders;

use App\Models\CustomerNotification;
use App\Models\CustomerPreparationTask;
use App\Models\FamilyMember;
use App\Models\Guest;
use App\Models\User;
use App\Models\VipGuest;
use App\Models\WeddingEvent;
use App\Models\WeddingIncomingPayment;
use App\Models\WeddingPaymentSchedule;
use Illuminate\Database\Seeder;

class CustomerNotificationSeeder extends Seeder
{
    /**
     * Seed notifikasi contoh yang selaras dengan data pernikahan pengguna.
     */
    public function run(): void
    {
        CustomerNotification::query()->delete();

        User::query()->each(function (User $user): void {
            $notifications = array_merge(
                $this->systemNotifications($user),
                $this->paymentNotifications($user),
                $this->guestNotifications($user),
                $this->preparationNotifications($user),
                $this->eventNotifications($user),
            );

            if ($notifications === []) {
                $notifications = $this->fallbackNotifications($user);
            }

            foreach (array_values($notifications) as $index => $notification) {
                CustomerNotification::create([
                    ...$notification,
                    'user_id' => $user->id,
                    'created_at' => now()->subDays(count($notifications) - $index)->subHours($index * 3),
                    'updated_at' => now()->subDays(count($notifications) - $index)->subHours($index * 3),
                ]);
            }
        });
    }

    /**
     * @return list<array<string, mixed>>
     */
    private function systemNotifications(User $user): array
    {
        $notifications = [];
        $info = $user->weddingInfo;

        $notifications[] = [
            'group' => 'system',
            'title' => 'Selamat datang di Wedding App',
            'message' => 'Mulai kelola anggaran, checklist, dan daftar tamu pernikahan Anda dari satu aplikasi.',
            'icon' => 'heart.fill',
            'destination' => null,
            'tint' => 'info',
            'is_unread' => false,
        ];

        if ($info?->groom_name && $info?->bride_name) {
            $notifications[] = [
                'group' => 'system',
                'title' => 'Profil pernikahan sudah lengkap',
                'message' => "Data {$info->groom_name} & {$info->bride_name} siap ditampilkan di dashboard.",
                'icon' => 'person.2.fill',
                'destination' => 'wedding-info',
                'tint' => 'success',
                'is_unread' => false,
            ];
        } else {
            $notifications[] = [
                'group' => 'system',
                'title' => 'Lengkapi profil pernikahan',
                'message' => 'Isi nama mempelai dan tema pernikahan agar dashboard lebih personal.',
                'icon' => 'person.crop.circle.badge.plus',
                'destination' => 'wedding-info',
                'tint' => 'warning',
                'is_unread' => true,
            ];
        }

        return $notifications;
    }

    /**
     * @return list<array<string, mixed>>
     */
    private function paymentNotifications(User $user): array
    {
        $notifications = [];

        $user->paymentSchedules()
            ->orderBy('due_date')
            ->get()
            ->each(function (WeddingPaymentSchedule $schedule) use (&$notifications): void {
                $amount = $this->formatRupiah((float) $schedule->amount);
                $dueDate = $schedule->due_date?->translatedFormat('d M Y') ?? 'segera';

                if ($schedule->status === 'overdue') {
                    $notifications[] = [
                        'group' => 'payment',
                        'title' => 'Pembayaran terlambat',
                        'message' => "{$schedule->title} ({$amount}) sudah melewati jatuh tempo {$dueDate}.",
                        'icon' => 'exclamationmark.triangle.fill',
                        'destination' => 'budget',
                        'tint' => 'danger',
                        'is_unread' => true,
                    ];

                    return;
                }

                if ($schedule->status === 'pending' && $schedule->due_date?->isBetween(now(), now()->addDays(7))) {
                    $notifications[] = [
                        'group' => 'payment',
                        'title' => 'Pembayaran akan jatuh tempo',
                        'message' => "{$schedule->title} sebesar {$amount} jatuh tempo pada {$dueDate}.",
                        'icon' => 'calendar.badge.clock',
                        'destination' => 'budget',
                        'tint' => 'warning',
                        'is_unread' => true,
                    ];
                }

                if ($schedule->status === 'paid') {
                    $notifications[] = [
                        'group' => 'payment',
                        'title' => 'Pembayaran berhasil dicatat',
                        'message' => "{$schedule->title} senilai {$amount} sudah ditandai lunas.",
                        'icon' => 'checkmark.circle.fill',
                        'destination' => 'budget',
                        'tint' => 'success',
                        'is_unread' => false,
                    ];
                }
            });

        $user->incomingPayments()
            ->latest('transfer_date')
            ->limit(3)
            ->get()
            ->each(function (WeddingIncomingPayment $payment) use (&$notifications): void {
                $amount = $this->formatRupiah((float) $payment->amount);
                $date = $payment->transfer_date?->translatedFormat('d M Y') ?? 'baru-baru ini';

                if ($payment->status === 'menunggu') {
                    $notifications[] = [
                        'group' => 'payment',
                        'title' => 'Uang masuk menunggu konfirmasi',
                        'message' => "Transfer {$amount} dari {$payment->sender_name} pada {$date} perlu diverifikasi.",
                        'icon' => 'arrow.down.circle.fill',
                        'destination' => 'budget',
                        'tint' => 'warning',
                        'is_unread' => true,
                    ];

                    return;
                }

                if ($payment->status === 'confirmed') {
                    $notifications[] = [
                        'group' => 'payment',
                        'title' => 'Uang masuk dikonfirmasi',
                        'message' => "Transfer {$amount} dari {$payment->sender_name} telah masuk ke anggaran.",
                        'icon' => 'banknote.fill',
                        'destination' => 'budget',
                        'tint' => 'success',
                        'is_unread' => false,
                    ];
                }
            });

        $budget = $user->weddingBudget;
        $totalSpent = (float) $user->paymentSchedules()->sum('amount');

        if ($budget && (float) $budget->total_budget > 0) {
            $totalBudget = (float) $budget->total_budget;
            $percentage = (int) round(($totalSpent / $totalBudget) * 100);

            if ($totalSpent > $totalBudget) {
                $notifications[] = [
                    'group' => 'payment',
                    'title' => 'Anggaran melebihi rencana',
                    'message' => "Total pengeluaran {$this->formatRupiah($totalSpent)} sudah melewati anggaran {$this->formatRupiah($totalBudget)}.",
                    'icon' => 'chart.line.uptrend.xyaxis',
                    'destination' => 'budget',
                    'tint' => 'danger',
                    'is_unread' => true,
                ];
            } elseif ($percentage >= 80) {
                $notifications[] = [
                    'group' => 'payment',
                    'title' => 'Anggaran hampir habis',
                    'message' => "Pengeluaran sudah mencapai {$percentage}% dari total anggaran {$this->formatRupiah($totalBudget)}.",
                    'icon' => 'chart.pie.fill',
                    'destination' => 'budget',
                    'tint' => 'warning',
                    'is_unread' => false,
                ];
            }
        }

        return array_slice($notifications, 0, 5);
    }

    /**
     * @return list<array<string, mixed>>
     */
    private function guestNotifications(User $user): array
    {
        $notifications = [];

        $user->guests()
            ->where('rsvp_status', 'hadir')
            ->latest('updated_at')
            ->limit(2)
            ->get()
            ->each(function (Guest $guest) use (&$notifications): void {
                $table = $guest->table_number ? " Meja {$guest->table_number}." : '';

                $notifications[] = [
                    'group' => 'guest',
                    'title' => 'Tamu mengonfirmasi kehadiran',
                    'message' => "{$guest->name} akan hadir.{$table}",
                    'icon' => 'person.crop.circle.badge.checkmark',
                    'destination' => 'guests',
                    'tint' => 'success',
                    'is_unread' => false,
                ];
            });

        $user->vipGuests()
            ->where('rsvp_status', 'hadir')
            ->latest('updated_at')
            ->limit(1)
            ->get()
            ->each(function (VipGuest $guest) use (&$notifications): void {
                $label = $guest->jabatan ? "{$guest->name} ({$guest->jabatan})" : $guest->name;

                $notifications[] = [
                    'group' => 'guest',
                    'title' => 'Tamu VIP hadir',
                    'message' => "{$label} mengonfirmasi kehadiran untuk acara pernikahan.",
                    'icon' => 'star.fill',
                    'destination' => 'guests',
                    'tint' => 'info',
                    'is_unread' => true,
                ];
            });

        $user->familyMembers()
            ->where('rsvp_status', 'hadir')
            ->latest('updated_at')
            ->limit(1)
            ->get()
            ->each(function (FamilyMember $member) use (&$notifications): void {
                $role = $member->role ? " sebagai {$member->role}" : '';

                $notifications[] = [
                    'group' => 'guest',
                    'title' => 'Keluarga inti hadir',
                    'message' => "{$member->name}{$role} mengonfirmasi kehadiran.",
                    'icon' => 'person.2.fill',
                    'destination' => 'guests',
                    'tint' => 'success',
                    'is_unread' => false,
                ];
            });

        $pendingGuests = $user->guests()->where('rsvp_status', 'menunggu')->count();

        if ($pendingGuests > 0) {
            $notifications[] = [
                'group' => 'guest',
                'title' => 'RSVP tamu belum lengkap',
                'message' => "Masih ada {$pendingGuests} tamu yang belum mengonfirmasi kehadiran.",
                'icon' => 'envelope.badge',
                'destination' => 'guests',
                'tint' => 'warning',
                'is_unread' => true,
            ];
        }

        return array_slice($notifications, 0, 4);
    }

    /**
     * @return list<array<string, mixed>>
     */
    private function preparationNotifications(User $user): array
    {
        $notifications = [];

        CustomerPreparationTask::query()
            ->where('user_id', $user->id)
            ->whereIn('status', ['in_progress', 'done'])
            ->with('section')
            ->latest('updated_at')
            ->limit(3)
            ->get()
            ->each(function (CustomerPreparationTask $task) use (&$notifications): void {
                $section = $task->section?->title;
                $context = $section ? " pada bagian {$section}" : '';

                if ($task->status === 'done') {
                    $notifications[] = [
                        'group' => 'preparation',
                        'title' => 'Tugas checklist selesai',
                        'message' => "\"{$task->title}\"{$context} sudah ditandai selesai.",
                        'icon' => 'checkmark.circle.fill',
                        'destination' => 'checklist',
                        'tint' => 'success',
                        'is_unread' => false,
                    ];

                    return;
                }

                $notifications[] = [
                    'group' => 'preparation',
                    'title' => 'Tugas sedang dikerjakan',
                    'message' => "\"{$task->title}\"{$context} sedang dalam progres.",
                    'icon' => 'clock.fill',
                    'destination' => 'checklist',
                    'tint' => 'info',
                    'is_unread' => true,
                ];
            });

        $pendingTasks = CustomerPreparationTask::query()
            ->where('user_id', $user->id)
            ->where('status', 'pending')
            ->count();

        if ($pendingTasks > 0) {
            $notifications[] = [
                'group' => 'preparation',
                'title' => 'Checklist persiapan menunggu',
                'message' => "Ada {$pendingTasks} tugas persiapan yang belum dimulai.",
                'icon' => 'checklist',
                'destination' => 'checklist',
                'tint' => 'warning',
                'is_unread' => false,
            ];
        }

        return array_slice($notifications, 0, 4);
    }

    /**
     * @return list<array<string, mixed>>
     */
    private function eventNotifications(User $user): array
    {
        $notifications = [];

        $user->weddingEvents()
            ->whereNotNull('tgl_acara')
            ->orderBy('tgl_acara')
            ->get()
            ->each(function (WeddingEvent $event) use (&$notifications): void {
                if ($event->tgl_acara->isPast()) {
                    return;
                }

                $label = $event->jenis_label;
                $date = $event->tgl_acara->translatedFormat('d M Y');
                $location = $event->lokasi_acara ? " di {$event->lokasi_acara}" : '';
                $daysUntil = (int) now()->startOfDay()->diffInDays($event->tgl_acara->copy()->startOfDay());

                if ($daysUntil <= 7) {
                    $notifications[] = [
                        'group' => 'system',
                        'title' => "{$label} sebentar lagi",
                        'message' => "Acara {$label} akan digelar pada {$date}{$location}.",
                        'icon' => 'calendar',
                        'destination' => 'events',
                        'tint' => 'warning',
                        'is_unread' => true,
                    ];

                    return;
                }

                if ($daysUntil <= 30) {
                    $notifications[] = [
                        'group' => 'system',
                        'title' => "Persiapan {$label}",
                        'message' => "{$label} tinggal {$daysUntil} hari lagi ({$date}). Pastikan checklist sudah berjalan.",
                        'icon' => 'calendar.badge.clock',
                        'destination' => 'checklist',
                        'tint' => 'info',
                        'is_unread' => false,
                    ];
                }
            });

        return array_slice($notifications, 0, 3);
    }

    /**
     * @return list<array<string, mixed>>
     */
    private function fallbackNotifications(User $user): array
    {
        return [
            [
                'group' => 'system',
                'title' => 'Selamat datang di Wedding App',
                'message' => "Hai {$user->name}, mulai isi anggaran dan checklist pernikahan Anda.",
                'icon' => 'bell.fill',
                'destination' => null,
                'tint' => 'info',
                'is_unread' => true,
            ],
        ];
    }

    private function formatRupiah(float $amount): string
    {
        return 'Rp '.number_format($amount, 0, ',', '.');
    }
}
