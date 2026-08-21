# Smoother Playback: Sliding Window Pre-buffer

## Problem

Currently, each playback item calls `_player.setAudioSource(...)` → HTTP connect → buffer → play. This causes a **~1-3s gap** between every item (between aya repeats, between surahs, etc).

## Design

### Part 1: Shared Path Resolver (SOLID)

Create a standalone utility used by **both** the downloader and the player. No coupling between them.

#### [NEW] `lib/modules/surah/domain/utils/quran_audio_resolver.dart`

```dart
class QuranAudioResolver {
  static String? _cachedBasePath;

  /// Relative subdir within applicationSupport for a reader.
  static String readerSubDir(int readerId) => 'quran_audio/$readerId';

  /// Filename for a surah: "003.mp3"
  static String surahFileName(int surahNumber) =>
      '${surahNumber.toString().padLeft(3, '0')}.mp3';

  /// Absolute base path: {appSupport}/quran_audio
  static Future<String> basePath() async { ... }

  /// Absolute local file path (whether it exists or not).
  static Future<String> localFilePath(int readerId, int surahNumber) async { ... }

  /// Returns file:// URI if downloaded locally, else remote https:// URL.
  static Future<Uri> playbackUri(ReaderModel reader, int surahNumber) async {
    final path = await localFilePath(reader.id, surahNumber);
    if (File(path).existsSync()) return Uri.file(path);
    return Uri.parse('${reader.downloadUrl}${surahFileName(surahNumber)}');
  }
}
```

The downloader uses `readerSubDir()` + `surahFileName()` for storage.
The player uses `playbackUri()` to resolve local vs remote.

---

### Part 2: Sliding Window with `ConcatenatingAudioSource`

#### How it works — step by step

Given a plan: `[aya1, aya1, aya1, aya1, aya1, aya2, aya2, ...]` (aya repeated 5×, etc)

```
Step 0 — Before play:
  Prepare playlist = [item0, item1, item2]    ← 3 items pre-loaded
  player.setAudioSource(playlist)
  player.play()                                ← item0 starts, item1+2 are pre-buffering

Step 1 — item0 finishes:
  → item1 starts immediately (gapless, already buffered)
  → Add item3 to playlist end
  → Remove item0 from playlist start
  Playlist is now: [item1, item2, item3]       ← always ~3 items

Step 2 — item1 finishes:
  → item2 starts immediately (gapless)
  → Add item4 to playlist end
  → Remove item1 from start
  Playlist: [item2, item3, item4]

  ...repeat until plan is exhausted...

Last step — no more items to add:
  Playlist shrinks: [itemN-1, itemN]
  itemN finishes → playback complete
```

#### Key point about `just_audio`

`ConcatenatingAudioSource` **pre-buffers the next item** while the current item is playing. So when item 0 finishes, item 1 is already decoded and plays with **zero gap**.

When multiple items reference clips from the **same URL** (e.g. aya1 repeated 10×), `just_audio` caches the underlying audio file in memory — so the same HTTP request isn't made 10 times.

#### Tracking indices

When we `removeAt(0)` from a `ConcatenatingAudioSource`, `just_audio` auto-adjusts `currentIndex` downward. So the current item always ends up at index 0 after cleanup:

```
Before remove: playing index 1 of [old, current, next]
After removeAt(0): playing index 0 of [current, next]
```

This keeps the playlist at a constant small size (~3 items).

---

## Implementation Plan

### [NEW] [quran_audio_resolver.dart](file:///home/allam/Projects/tahfez/lib/modules/surah/domain/utils/quran_audio_resolver.dart)
- Shared path/URI resolver
- Used by both downloader and player

### [MODIFY] [surah_downloader_impl.dart](file:///home/allam/Projects/tahfez/lib/modules/surah/data/repos/surah_downloader_impl.dart)
- Replace inline path logic with `QuranAudioResolver` methods
- Remove `_basePath()`, `_readerDir()`, `_surahPath()`, `_readerSubDir()`, `_surahUrl()` — use resolver instead

### [MODIFY] [surah_player_just_audio_impl.dart](file:///home/allam/Projects/tahfez/lib/modules/surah/data/repos/surah_player_just_audio_impl.dart)
- Replace single `setAudioSource()` calls with `ConcatenatingAudioSource` sliding window
- Change `_PlaybackItem.surahUrl` → resolve via `QuranAudioResolver.playbackUri()` at preparation time
- Listen to `player.currentIndexStream` to advance the window
- Add `_prepareNextItems()` method that adds to the playlist and removes old items

### Changes to `_advanceToNext()` → replaced by window management

```
Old flow:
  _advanceToNext() → setAudioSource(single item) → play()

New flow:
  _startPlayback():
    1. Build full plan (same as now)
    2. Resolve URIs for first 3 items (local or remote)
    3. Create ConcatenatingAudioSource with 3 ClippingAudioSources
    4. player.setAudioSource(playlist)
    5. player.play()

  _onCurrentIndexChanged(newIndex):
    1. If newIndex moved forward:
       - Add next item from plan to playlist end
       - Remove completed item from playlist start
    2. If plan exhausted and current is last item:
       - Let it finish naturally → playback complete
```

## What this does NOT do
- ❌ Does NOT download files the user didn't request
- ❌ Does NOT change the playback plan structure
- ✅ Uses local files when available (via resolver)
- ✅ Eliminates gaps between items via `ConcatenatingAudioSource` pre-buffering
