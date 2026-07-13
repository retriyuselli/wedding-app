<?php

namespace App\Support;

/**
 * Parses Filament / TipTap RichEditor HTML into facility sections.
 *
 * Expected shape:
 *   <p><strong>Section Title</strong></p>
 *   <ol><li>Item A</li><li>Item B</li></ol>
 *   <p><strong>Next Title</strong></p>
 *   <ol>...</ol>
 */
class RichEditorFacilityParser
{
    /**
     * @return list<array{title: string, items: list<string>}>
     */
    public static function toSections(?string $html): array
    {
        if (! is_string($html) || trim($html) === '') {
            return [];
        }

        // Block regex is the most reliable for TipTap/Filament output.
        $sections = self::parseByBlocks($html);

        if ($sections === []) {
            $sections = self::parseByDom($html);
        }

        if ($sections === []) {
            $sections = self::fallbackFlatList($html);
        }

        return array_values(array_filter(
            $sections,
            fn (array $section): bool => ($section['items'] ?? []) !== []
        ));
    }

    /**
     * @return list<string>
     */
    public static function toInclusions(?string $html): array
    {
        return collect(self::toSections($html))
            ->flatMap(fn (array $section): array => $section['items'])
            ->values()
            ->all();
    }

    /**
     * @return list<array{title: string, items: list<string>}>
     */
    private static function parseByBlocks(string $html): array
    {
        $html = html_entity_decode($html, ENT_QUOTES | ENT_HTML5, 'UTF-8');

        $parts = preg_split(
            '/(<p\b[^>]*>\s*<strong\b[^>]*>.*?<\/strong>\s*<\/p>|<p\b[^>]*>\s*<b\b[^>]*>.*?<\/b>\s*<\/p>|<h[1-6][^>]*>.*?<\/h[1-6]>|<ol\b[^>]*>.*?<\/ol>|<ul\b[^>]*>.*?<\/ul>)/is',
            $html,
            -1,
            PREG_SPLIT_DELIM_CAPTURE | PREG_SPLIT_NO_EMPTY
        );

        if ($parts === false) {
            return [];
        }

        $sections = [];
        $currentTitle = '';
        $pendingParagraphItems = [];

        $flushParagraphs = function () use (&$sections, &$currentTitle, &$pendingParagraphItems): void {
            $items = array_values(array_filter(array_map(
                [self::class, 'cleanItemText'],
                $pendingParagraphItems
            )));
            $pendingParagraphItems = [];

            if ($items === []) {
                return;
            }

            $sections[] = [
                'title' => $currentTitle !== '' ? $currentTitle : 'Fasilitas',
                'items' => $items,
            ];
            $currentTitle = '';
        };

        foreach ($parts as $part) {
            $part = trim($part);
            if ($part === '' || preg_match('/^<p\b[^>]*>\s*(<br\s*\/?>)?\s*<\/p>$/is', $part)) {
                continue;
            }

            if (preg_match('/^<p\b[^>]*>\s*<(strong|b)\b[^>]*>(.*?)<\/\1>\s*<\/p>$/is', $part, $match)
                || preg_match('/^<h[1-6][^>]*>(.*?)<\/h[1-6]>$/is', $part, $match)) {
                $flushParagraphs();
                $headingHtml = $match[2] ?? $match[1];
                $currentTitle = trim(html_entity_decode(strip_tags($headingHtml)));
                continue;
            }

            if (preg_match('/^<(ol|ul)\b[^>]*>(.*?)<\/\1>$/is', $part, $match)) {
                $flushParagraphs();

                $items = [];
                if (preg_match_all('/<li\b[^>]*>(.*?)<\/li>/is', $match[2], $liMatches)) {
                    $items = collect($liMatches[1])
                        ->map(fn (string $text): string => self::cleanItemText(html_entity_decode(strip_tags($text))))
                        ->filter()
                        ->values()
                        ->all();
                }

                if ($items !== []) {
                    $sections[] = [
                        'title' => $currentTitle !== '' ? $currentTitle : 'Fasilitas',
                        'items' => $items,
                    ];
                    $currentTitle = '';
                }

                continue;
            }

            // Numbered / plain paragraphs after a heading (RichEditor without list markup).
            if (preg_match('/^<p\b[^>]*>(.*?)<\/p>$/is', $part, $match)) {
                $text = self::cleanItemText(html_entity_decode(strip_tags($match[1])));
                if ($text !== '') {
                    $pendingParagraphItems[] = $text;
                }
            }
        }

        $flushParagraphs();

        return $sections;
    }

    /**
     * @return list<array{title: string, items: list<string>}>
     */
    private static function parseByDom(string $html): array
    {
        $normalized = html_entity_decode($html, ENT_QUOTES | ENT_HTML5, 'UTF-8');

        $dom = new \DOMDocument();
        $previous = libxml_use_internal_errors(true);
        $loaded = $dom->loadHTML(
            '<?xml encoding="UTF-8"><div id="root">'.$normalized.'</div>',
            LIBXML_HTML_NOIMPLIED | LIBXML_HTML_NODEFDTD
        );
        libxml_clear_errors();
        libxml_use_internal_errors($previous);

        if (! $loaded) {
            return [];
        }

        $root = $dom->getElementById('root')
            ?? $dom->getElementsByTagName('body')->item(0)
            ?? $dom->documentElement;

        if (! $root) {
            return [];
        }

        $sections = [];
        $currentTitle = '';
        $currentItems = [];

        $flush = function () use (&$sections, &$currentTitle, &$currentItems): void {
            $items = array_values(array_filter(array_map([self::class, 'cleanItemText'], $currentItems)));
            $currentItems = [];

            if ($items === []) {
                return;
            }

            $sections[] = [
                'title' => trim($currentTitle) !== '' ? trim($currentTitle) : 'Fasilitas',
                'items' => $items,
            ];
            $currentTitle = '';
        };

        foreach (iterator_to_array($root->childNodes) as $node) {
            if (! $node instanceof \DOMElement) {
                continue;
            }

            $tag = strtolower($node->tagName);

            if (in_array($tag, ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'], true)) {
                $heading = self::nodeText($node);
                if ($heading === '') {
                    continue;
                }
                $flush();
                $currentTitle = $heading;
                continue;
            }

            if ($tag === 'p') {
                $heading = self::paragraphHeading($node);
                if ($heading !== null) {
                    $flush();
                    $currentTitle = $heading;
                    continue;
                }

                $text = self::cleanItemText(self::nodeText($node));
                if ($text !== '') {
                    $currentItems[] = $text;
                }
                continue;
            }

            if (in_array($tag, ['ol', 'ul'], true)) {
                foreach ($node->childNodes as $child) {
                    if (! $child instanceof \DOMElement || strtolower($child->tagName) !== 'li') {
                        continue;
                    }
                    $text = self::cleanItemText(self::nodeText($child));
                    if ($text !== '') {
                        $currentItems[] = $text;
                    }
                }
                $flush();
            }
        }

        $flush();

        return $sections;
    }

    private static function paragraphHeading(\DOMElement $paragraph): ?string
    {
        $text = self::nodeText($paragraph);
        if ($text === '') {
            return null;
        }

        $boldText = '';
        foreach (['strong', 'b'] as $boldTag) {
            foreach ($paragraph->getElementsByTagName($boldTag) as $bold) {
                $boldText .= self::nodeText($bold).' ';
            }
        }

        $boldText = trim(preg_replace('/\s+/u', ' ', $boldText) ?? $boldText);
        if ($boldText === '') {
            return null;
        }

        similar_text(mb_strtolower($boldText), mb_strtolower($text), $percent);

        return $percent >= 80 ? $boldText : null;
    }

    private static function nodeText(\DOMNode $node): string
    {
        $text = trim(preg_replace('/\s+/u', ' ', $node->textContent ?? '') ?? '');

        return html_entity_decode($text, ENT_QUOTES | ENT_HTML5, 'UTF-8');
    }

    private static function cleanItemText(string $text): string
    {
        $text = trim(preg_replace('/\s+/u', ' ', $text) ?? $text);
        // Strip editor-typed numbers like "1. " / "2) " so the app can renumber per section.
        $text = preg_replace('/^\d+[\.\)\-:]\s*/u', '', $text) ?? $text;

        return trim($text);
    }

    /**
     * @return list<array{title: string, items: list<string>}>
     */
    private static function fallbackFlatList(string $html): array
    {
        if (preg_match_all('/<li\b[^>]*>(.*?)<\/li>/is', $html, $matches)) {
            $items = collect($matches[1])
                ->map(fn (string $text): string => self::cleanItemText(html_entity_decode(strip_tags($text))))
                ->filter()
                ->values()
                ->all();

            return $items === [] ? [] : [['title' => 'Fasilitas', 'items' => $items]];
        }

        $plain = self::cleanItemText(html_entity_decode(strip_tags($html)));

        return $plain !== '' ? [['title' => 'Fasilitas', 'items' => [$plain]]] : [];
    }
}
