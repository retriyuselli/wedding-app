<?php

namespace App\Filament\Resources\CustomerPreparationTasks\Schemas;

use App\Models\CustomerPreparationSubTask;
use App\Models\CustomerPreparationTask;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Components\Utilities\Set;
use Filament\Schemas\Schema;

class CustomerPreparationTaskForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(1)
            ->components([
                Section::make('Customer & Konteks')
                    ->description('Hubungkan tugas dengan pengantin, acara, dan bagian checklist.')
                    ->columns(2)
                    ->schema([
                        Select::make('user_id')
                            ->label('Pengantin')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->preload()
                            ->required()
                            ->live()
                            ->afterStateUpdated(function (Set $set): void {
                                $set('section_id', null);
                                $set('wedding_event_id', null);
                            })
                            ->native(false)
                            ->columnSpanFull(),
                        Select::make('section_id')
                            ->label('Bagian Checklist')
                            ->relationship(
                                name: 'section',
                                titleAttribute: 'title',
                                modifyQueryUsing: fn ($query, Get $get) => filled($get('user_id'))
                                    ? $query->where('user_id', $get('user_id'))
                                    : $query,
                            )
                            ->searchable()
                            ->preload()
                            ->native(false)
                            ->placeholder('Pilih bagian (opsional)')
                            ->helperText('Mengelompokkan tugas ke tab checklist di aplikasi mobile.'),
                        Select::make('wedding_event_id')
                            ->label('Acara Pernikahan')
                            ->relationship(
                                name: 'weddingEvent',
                                titleAttribute: 'jenis_acara',
                                modifyQueryUsing: fn ($query, Get $get) => filled($get('user_id'))
                                    ? $query->where('user_id', $get('user_id'))
                                    : $query,
                            )
                            ->searchable()
                            ->preload()
                            ->native(false)
                            ->placeholder('Pilih acara (opsional)'),
                    ]),

                Section::make('Detail Tugas')
                    ->description('Informasi utama yang ditampilkan di daftar checklist.')
                    ->columns(2)
                    ->schema([
                        TextInput::make('title')
                            ->label('Judul Tugas')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('Pesan undangan, DP venue, fitting baju, ...')
                            ->columnSpanFull(),
                        TextInput::make('label')
                            ->label('Label')
                            ->maxLength(255)
                            ->placeholder('Opsional')
                            ->helperText('Teks pendek tambahan di samping judul, jika diperlukan.')
                            ->columnSpanFull(),
                        Textarea::make('description')
                            ->label('Deskripsi')
                            ->rows(3)
                            ->placeholder('Penjelasan atau langkah-langkah tugas.')
                            ->columnSpanFull(),
                        Textarea::make('notes')
                            ->label('Catatan Internal')
                            ->rows(3)
                            ->placeholder('Catatan untuk admin atau pengantin.')
                            ->helperText('Tidak wajib diisi. Berguna untuk konteks tambahan.')
                            ->columnSpanFull(),
                    ]),

                Section::make('Status & Jadwal')
                    ->columns(3)
                    ->schema([
                        Select::make('priority')
                            ->label('Prioritas')
                            ->options(CustomerPreparationTask::$priorityOptions)
                            ->default('medium')
                            ->required()
                            ->native(false),
                        Select::make('status')
                            ->label('Status')
                            ->options(CustomerPreparationTask::$statusOptions)
                            ->required()
                            ->default('pending')
                            ->native(false),
                        DatePicker::make('due_date')
                            ->label('Jatuh Tempo')
                            ->native(false)
                            ->displayFormat('d M Y')
                            ->placeholder('Pilih tanggal'),
                    ]),

                Section::make('Sub Tugas')
                    ->description('Pecah tugas besar menjadi langkah-langkah kecil. Seret item untuk mengubah urutan.')
                    ->schema([
                        Repeater::make('subTasks')
                            ->relationship()
                            ->label('Daftar Sub Tugas')
                            ->schema([
                                TextInput::make('title')
                                    ->label('Judul')
                                    ->required()
                                    ->maxLength(255)
                                    ->columnSpanFull(),
                                Select::make('status')
                                    ->label('Status')
                                    ->options(CustomerPreparationSubTask::$statusOptions)
                                    ->default('pending')
                                    ->required()
                                    ->live()
                                    ->native(false),
                                DatePicker::make('due_date')
                                    ->label('Target')
                                    ->native(false)
                                    ->displayFormat('d M Y'),
                                DatePicker::make('completed_at')
                                    ->label('Selesai Pada')
                                    ->native(false)
                                    ->displayFormat('d M Y')
                                    ->visible(fn (Get $get): bool => $get('status') === 'done'),
                            ])
                            ->columns(2)
                            ->columnSpanFull()
                            ->orderColumn('sort_order')
                            ->collapsible()
                            ->cloneable()
                            ->itemLabel(fn (array $state): ?string => $state['title'] ?? 'Sub tugas baru')
                            ->addActionLabel('Tambah sub tugas')
                            ->defaultItems(0),
                    ]),
            ]);
    }
}
