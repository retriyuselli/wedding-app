<?php

namespace Database\Factories;

use App\Models\Message;
use App\Models\MessageThread;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Message>
 */
class MessageFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'message_thread_id' => MessageThread::factory(),
            'user_id' => User::factory(),
            'body' => fake()->sentence(),
            'is_outgoing' => fake()->boolean(),
            'read_at' => null,
        ];
    }

    public function outgoing(): static
    {
        return $this->state(fn (): array => [
            'is_outgoing' => true,
            'read_at' => now(),
        ]);
    }

    public function incomingUnread(): static
    {
        return $this->state(fn (): array => [
            'is_outgoing' => false,
            'read_at' => null,
        ]);
    }

    public function withTopic(string $topic): static
    {
        return $this->state(fn (): array => [
            'topic' => $topic,
        ]);
    }
}
