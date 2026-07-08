<?php

namespace Database\Factories;

use App\Models\MessageThread;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<MessageThread>
 */
class MessageThreadFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'name' => fake()->company(),
            'category' => fake()->randomElement(array_keys(MessageThread::$categoryOptions)),
            'avatar_url' => fake()->optional()->imageUrl(120, 120),
            'is_online' => fake()->boolean(35),
        ];
    }
}
