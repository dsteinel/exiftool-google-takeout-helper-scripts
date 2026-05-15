# exiftool-google-takeout-helper-scripts

A collection of scripts and commands to fix incorrect creation dates and missing metadata in media exported via Google Takeout.

## 🚀 Quick Start: Using the Script

The easiest way to fix your media is to use the interactive `script.sh`.

1. **Ensure Exiftool is installed** (see [Installation](#install-exiftools)).
2. **Make the script executable**:
   ```bash
   chmod +x script.sh
   ```
3. **Run the script**:
   ```bash
   ./script.sh
   ```

### Script Tasks:
1. **Show all EXIF data**: Quickly inspect all time-related metadata for a specific file.
2. **Google Takeout: Apply JSON metadata**: The "Main Task". It takes the `.json` sidecar files provided by Google and integrates timestamps and GPS data directly into your images and videos.
3. **Repair & Sync all dates**: A powerful "Super-Fix" that:
    - Repairs zeroed-out metadata using the file system date as a fallback.
    - Synchronizes internal metadata (DateTimeOriginal, CreateDate, etc.) across photos and videos.
    - Forces the File System (Finder/Explorer) "Date Created" and "Date Modified" to match the internal metadata.
4. **Change filename to date**: Renames your files to the `YYYYMMDD_HHMMSS.ext` format based on the best available timestamp.

---

## WHY?
Google Takeout gives you images where the file system "Creation Date" is set to the date of the export, not the date the photo was taken. This makes sorting in Finder or Windows Explorer nearly impossible without fixing the metadata and file system attributes.

## Get all data from Google
Follow the instructions from Google Takeout to export your Google Photos library.

## Extract all archives
After extracting all zip files with:
```bash
find . -name "*.zip" | xargs -I {} tar -xvf {} -C /path/to/extract/to
```

## Install Exiftools
### Mac
If you have Homebrew installed:
```bash
brew install exiftool
```
Otherwise, download the package from [exiftool.org](https://exiftool.org/install.html).

### Windows
Download the executable from [exiftool.org](https://exiftool.org/install.html) and follow the installation instructions.

---

## Manual Commands (for reference)

### Use JSON and apply to image
This command takes the `photoTakenTime` from the `.json` and integrates it as EXIF data. It also includes GeoData.
```bash
exiftool -r -d %s -tagsfromfile "%d/%F.json" "-GPSAltitude<GeoDataAltitude" "-GPSLatitude<GeoDataLatitude" "-GPSLatitudeRef<GeoDataLatitude" "-GPSLongitude<GeoDataLongitude" "-GPSLongitudeRef<GeoDataLongitude" "-DateTimeOriginal<PhotoTakenTimeTimestamp" "-CreateDate<PhotoTakenTimeTimestamp" "-ModifyDate<PhotoTakenTimeTimestamp" "-FileCreateDate<PhotoTakenTimeTimestamp" "-FileModifyDate<PhotoTakenTimeTimestamp" --ext json -overwrite_original -progress <directory_name>
```

### Change filename to a date
```bash
exiftool -r -P --ext json '-Filename<FileModifyDate' '-Filename<ModifyDate' '-Filename<CreateDate' '-Filename<DateTimeOriginal' -d %Y%m%d_%H%M%S%%-c.%%le <directory_name>
```

### Fix iPhone Live Photos exported as .JPG
If Live Photos are exported as `.JPG` but are actually `.MOV` files, this command fixes the extension:
```bash
exiftool -r -ext jpg -overwrite_original -filename=%f.MOV -if '$filetype eq "MOV"' -progress <directory_name>
```

### Cleanup
**Remove all .json files:**
```bash
find . -name "*.json" -type f -delete
```

**Remove -edited files:**
```bash
find . -name "*-edited.jpg" -type f -delete
```
