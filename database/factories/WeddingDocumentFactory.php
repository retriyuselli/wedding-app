<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\WeddingDocument;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<WeddingDocument>
 */
class WeddingDocumentFactory extends Factory
{
    protected $model = WeddingDocument::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $fileName = fake()->unique()->slug().'.pdf';

        return [
            'user_id' => User::factory(),
            'document_folder_id' => null,
            'file_name' => $fileName,
            'file_path' => 'wedding-documents/'.$fileName,
            'file_size' => fake()->numberBetween(1024, 200_000),
            'mime_type' => 'application/pdf',
            'category' => fake()->randomElement(array_keys(WeddingDocument::$categoryOptions)),
        ];
    }
}
