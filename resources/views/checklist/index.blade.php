@extends('layouts.app')

@section('heading', 'Checklist Persiapan')

@section('content')
<div class="flex flex-col">

    {{-- Event Tabs --}}
    <div class="sticky top-[57px] z-10 bg-white border-b border-gray-100">
        <div class="flex overflow-x-auto gap-1 px-4 py-2">
            @forelse($events as $event)
                <a href="{{ route('checklist', ['event' => $event->id]) }}"
                   class="shrink-0 rounded-full px-4 py-1.5 text-sm font-medium transition
                          {{ $current?->id === $event->id ? 'bg-rose-500 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200' }}">
                    {{ $event->jenis_label }}
                </a>
            @empty
                <span class="text-sm text-gray-400 py-1.5">Belum ada acara</span>
            @endforelse

            <a href="{{ route('checklist.events.create') }}"
               class="shrink-0 flex items-center gap-1 rounded-full border border-dashed border-gray-300 px-3 py-1.5 text-sm text-gray-400 hover:border-rose-300 hover:text-rose-400">
                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                </svg>
                Acara
            </a>
        </div>
    </div>

    <div class="p-4 space-y-4">

        {{-- Flash --}}
        @if(session('success'))
        <div class="flex items-center gap-2 rounded-xl bg-emerald-50 px-4 py-2 text-sm text-emerald-600">
            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
            </svg>
            {{ session('success') }}
        </div>
        @endif

        @if($current)

        {{-- Event Info --}}
        <div class="flex items-center justify-between rounded-xl bg-rose-50 px-4 py-3">
            <div>
                <p class="text-sm font-semibold text-rose-700">{{ $current->jenis_label }}</p>
                <p class="text-xs text-rose-500">
                    {{ $current->tgl_acara ? $current->tgl_acara->translatedFormat('d F Y') : 'Tanggal belum diset' }}
                    @if($current->lokasi_acara) · {{ $current->lokasi_acara }} @endif
                </p>
            </div>
            <a href="{{ route('checklist.events.edit', $current->id) }}" class="text-rose-400 hover:text-rose-600">
                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125" />
                </svg>
            </a>
        </div>

        {{-- Progress --}}
        @if($total > 0)
        <div class="rounded-xl bg-white border border-gray-100 p-4 shadow-sm">
            <div class="flex justify-between items-center mb-2">
                <span class="text-sm font-medium text-gray-700">Progress</span>
                <span class="text-sm font-semibold text-rose-500">{{ $doneCount }}/{{ $total }}</span>
            </div>
            <div class="h-2 w-full overflow-hidden rounded-full bg-gray-100">
                <div class="h-full rounded-full bg-rose-400" style="width: {{ round(($doneCount/$total)*100) }}%"></div>
            </div>
        </div>
        @endif

        {{-- Tasks per Section --}}
        @foreach($sections as $section)
        <div class="rounded-2xl border border-gray-100 bg-white shadow-sm overflow-hidden">
            <div class="flex items-center justify-between px-4 py-3 border-b border-gray-50">
                <h3 class="text-sm font-semibold text-gray-800">{{ $section->title }}</h3>
                <div class="flex items-center gap-2">
                    <a href="{{ route('checklist.tasks.create', ['event' => $current->id, 'section' => $section->id]) }}"
                       class="text-gray-400 hover:text-rose-500">
                        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                        </svg>
                    </a>
                    <a href="{{ route('checklist.sections.edit', $section->id) }}" class="text-gray-300 hover:text-gray-500">
                        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125" />
                        </svg>
                    </a>
                </div>
            </div>

            @forelse($section->tasks as $task)
            <div class="flex items-center gap-3 px-4 py-3 border-b border-gray-50 last:border-0 hover:bg-gray-50">
                <form method="POST" action="{{ route('checklist.tasks.toggle', $task->id) }}">
                    @csrf @method('PATCH')
                    <button type="submit"
                            class="h-5 w-5 shrink-0 rounded-full border-2 flex items-center justify-center transition
                                   {{ $task->status === 'done' ? 'border-rose-400 bg-rose-400' : 'border-gray-300 hover:border-rose-300' }}">
                        @if($task->status === 'done')
                            <svg class="h-3 w-3 text-white" fill="none" viewBox="0 0 24 24" stroke-width="3" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                            </svg>
                        @endif
                    </button>
                </form>
                <div class="flex-1 min-w-0">
                    <p class="text-sm {{ $task->status === 'done' ? 'line-through text-gray-400' : 'text-gray-800' }}">{{ $task->title }}</p>
                    @if($task->due_date)
                        <p class="text-xs {{ $task->due_date->isPast() && $task->status !== 'done' ? 'text-red-400' : 'text-gray-400' }}">
                            {{ $task->due_date->translatedFormat('d M Y') }}
                        </p>
                    @endif
                </div>
                <div class="flex items-center gap-1">
                    <a href="{{ route('checklist.tasks.edit', $task->id) }}" class="text-gray-300 hover:text-gray-500 p-1">
                        <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125" />
                        </svg>
                    </a>
                    <form method="POST" action="{{ route('checklist.tasks.destroy', $task->id) }}">
                        @csrf @method('DELETE')
                        <button type="submit" onclick="return confirm('Hapus task ini?')" class="text-gray-300 hover:text-red-400 p-1">
                            <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                            </svg>
                        </button>
                    </form>
                </div>
            </div>
            @empty
            <div class="px-4 py-3 text-center text-xs text-gray-400">Belum ada task</div>
            @endforelse
        </div>
        @endforeach

        {{-- Loose tasks --}}
        @if($looseTasks->count() > 0)
        <div class="rounded-2xl border border-gray-100 bg-white shadow-sm overflow-hidden">
            <div class="px-4 py-3 border-b border-gray-50">
                <h3 class="text-sm font-semibold text-gray-500">Lainnya</h3>
            </div>
            @foreach($looseTasks as $task)
            <div class="flex items-center gap-3 px-4 py-3 border-b border-gray-50 last:border-0 hover:bg-gray-50">
                <form method="POST" action="{{ route('checklist.tasks.toggle', $task->id) }}">
                    @csrf @method('PATCH')
                    <button type="submit"
                            class="h-5 w-5 shrink-0 rounded-full border-2 flex items-center justify-center transition
                                   {{ $task->status === 'done' ? 'border-rose-400 bg-rose-400' : 'border-gray-300' }}">
                        @if($task->status === 'done')
                            <svg class="h-3 w-3 text-white" fill="none" viewBox="0 0 24 24" stroke-width="3" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                            </svg>
                        @endif
                    </button>
                </form>
                <p class="flex-1 text-sm {{ $task->status === 'done' ? 'line-through text-gray-400' : 'text-gray-800' }}">{{ $task->title }}</p>
                <form method="POST" action="{{ route('checklist.tasks.destroy', $task->id) }}">
                    @csrf @method('DELETE')
                    <button type="submit" onclick="return confirm('Hapus task ini?')" class="text-gray-300 hover:text-red-400 p-1">
                        <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                        </svg>
                    </button>
                </form>
            </div>
            @endforeach
        </div>
        @endif

        {{-- Actions --}}
        <div class="flex gap-2">
            <a href="{{ route('checklist.tasks.create', ['event' => $current->id]) }}"
               class="flex flex-1 items-center justify-center gap-2 rounded-xl border border-dashed border-rose-200 py-3 text-sm text-rose-500 hover:bg-rose-50">
                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                </svg>
                Tambah Task
            </a>
            <a href="{{ route('checklist.sections.create', ['event' => $current->id]) }}"
               class="flex flex-1 items-center justify-center gap-2 rounded-xl border border-dashed border-gray-200 py-3 text-sm text-gray-500 hover:bg-gray-50">
                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                </svg>
                Tambah Seksi
            </a>
        </div>

        @else
        <div class="rounded-2xl border border-dashed border-gray-200 p-8 text-center">
            <p class="text-gray-400">Tambah acara terlebih dahulu</p>
        </div>
        @endif

    </div>
</div>
@endsection
