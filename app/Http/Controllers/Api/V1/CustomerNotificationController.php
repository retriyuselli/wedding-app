<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\CustomerNotificationResource;
use App\Models\CustomerNotification;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class CustomerNotificationController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = $request->user()->customerNotifications();

        if ($request->boolean('unread_only')) {
            $query->where('is_unread', true);
        }

        return CustomerNotificationResource::collection($query->orderByDesc('created_at')->get());
    }

    public function show(Request $request, int $customerNotification): CustomerNotificationResource
    {
        return new CustomerNotificationResource($this->findOwned($request, $customerNotification));
    }

    public function markRead(Request $request, int $customerNotification): CustomerNotificationResource
    {
        $notification = $this->findOwned($request, $customerNotification);
        $notification->update(['is_unread' => false]);

        return new CustomerNotificationResource($notification);
    }

    public function destroy(Request $request, int $customerNotification): \Illuminate\Http\Response
    {
        $this->findOwned($request, $customerNotification)->delete();

        return response()->noContent();
    }

    private function findOwned(Request $request, int $id): CustomerNotification
    {
        return CustomerNotification::where('user_id', $request->user()->id)->findOrFail($id);
    }
}
