<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\WeddingPaymentScheduleResource;
use App\Models\WeddingPaymentSchedule;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

class WeddingPaymentScheduleController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = WeddingPaymentSchedule::where('user_id', $request->user()->id);

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        return WeddingPaymentScheduleResource::collection(
            $query->orderBy('sort_order')->orderBy('due_date')->get()
        );
    }

    public function store(Request $request): WeddingPaymentScheduleResource
    {
        $data = $this->validated($request);
        unset($data['proof']);
        $data['status'] ??= config('wedding.default_expense_status', 'pending');

        if (empty($data['category'])) {
            $data['category'] = config('wedding.default_expense_category', 'other');
        }

        if (! array_key_exists('sort_order', $data) || $data['sort_order'] === null) {
            unset($data['sort_order']);
        }

        if ($proofPath = $this->storeProofFile($request)) {
            $data['proof_url'] = $proofPath;
            $data['status'] = 'paid';
        }

        $data = $this->applyPaidTimestamp($data);

        $schedule = $request->user()->paymentSchedules()->create($data);

        return new WeddingPaymentScheduleResource($schedule);
    }

    public function show(Request $request, int $weddingPaymentSchedule): WeddingPaymentScheduleResource
    {
        return new WeddingPaymentScheduleResource($this->findOwned($request, $weddingPaymentSchedule));
    }

    public function update(Request $request, int $weddingPaymentSchedule): WeddingPaymentScheduleResource
    {
        $data = $this->validated($request);
        unset($data['proof']);

        $schedule = $this->findOwned($request, $weddingPaymentSchedule);

        if ($proofPath = $this->replaceProofFile($request, $schedule)) {
            $data['proof_url'] = $proofPath;
            $data['status'] ??= 'paid';
        }

        $data = $this->applyPaidTimestamp($data, $schedule);

        $schedule->update($data);

        return new WeddingPaymentScheduleResource($schedule);
    }

    public function destroy(Request $request, int $weddingPaymentSchedule): Response
    {
        $schedule = $this->findOwned($request, $weddingPaymentSchedule);
        $this->deleteProofFile($schedule);
        $schedule->delete();

        return response()->noContent();
    }

    public function markPaid(Request $request, int $weddingPaymentSchedule): WeddingPaymentScheduleResource
    {
        $schedule = $this->findOwned($request, $weddingPaymentSchedule);
        $schedule->update(['status' => 'paid', 'paid_at' => now()]);

        return new WeddingPaymentScheduleResource($schedule);
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request): array
    {
        $userId = $request->user()->id;

        return $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'vendor_name' => ['nullable', 'string', 'max:255'],
            'category' => ['nullable', 'string', 'in:'.implode(',', array_keys(WeddingPaymentSchedule::$categoryOptions))],
            'amount' => ['required', 'numeric', 'min:0'],
            'due_date' => ['nullable', 'date'],
            'status' => ['nullable', 'string', 'in:'.implode(',', array_keys(WeddingPaymentSchedule::$statusOptions))],
            'notes' => ['nullable', 'string', 'max:200'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'wedding_event_id' => ['nullable', 'integer', 'exists:wedding_events,id,user_id,'.$userId],
            'customer_payment_method_id' => ['nullable', 'integer', 'exists:customer_payment_methods,id,user_id,'.$userId],
            'proof' => ['nullable', 'file', 'mimes:jpg,jpeg,png,pdf', 'max:1024'],
        ]);
    }

    private function storeProofFile(Request $request): ?string
    {
        $file = $request->file('proof');

        if (! $file instanceof UploadedFile) {
            return null;
        }

        return $file->store('payment-schedules/proofs', 'public');
    }

    private function replaceProofFile(Request $request, WeddingPaymentSchedule $schedule): ?string
    {
        if (! $request->hasFile('proof')) {
            return null;
        }

        $this->deleteProofFile($schedule);

        return $this->storeProofFile($request);
    }

    private function deleteProofFile(WeddingPaymentSchedule $schedule): void
    {
        if (! $schedule->proof_url) {
            return;
        }

        if (str_starts_with($schedule->proof_url, 'http://') || str_starts_with($schedule->proof_url, 'https://')) {
            return;
        }

        Storage::disk('public')->delete($schedule->proof_url);
    }

    private function findOwned(Request $request, int $id): WeddingPaymentSchedule
    {
        return WeddingPaymentSchedule::where('user_id', $request->user()->id)->findOrFail($id);
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    private function applyPaidTimestamp(array $data, ?WeddingPaymentSchedule $existing = null): array
    {
        if (($data['status'] ?? null) === 'paid' && ! isset($data['paid_at'])) {
            $data['paid_at'] = $existing?->paid_at ?? now();
        }

        if (in_array($data['status'] ?? null, ['pending', 'overdue'], true)) {
            $data['paid_at'] = null;
        }

        return $data;
    }
}
