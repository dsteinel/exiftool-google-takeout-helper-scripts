# exiftool-google-takeout-helper-scripts

Most of the stuff is taken from here:
[google-photos-takeout-scripts](https://github.com/m1rkwood/google-photos-takeout-scripts/tree/main) I only made some small adjustments to fit my needs.

## WHY?
Google takeout gives you the images with a wrong creation date. All media will have the export date as creation date. This is incorrect and needs to be changed.

## Get all data from google
Follow the instructions from google takeout

## Extract all archives
After extracting all zip files with (please verify)
```
find . -name "*.zip" | xargs -I {} tar -xvf {} -C /path/to/extract/to
```

## Install Exiftools
### Windows
### Mac

## Use Exiftools to write all data from json to image/video file
...

## Rename data if needed

## Use json and apply to image
For macOs, if you have brew installed, just install it using the brew install exiftool command. Otherwise, you can download the package here and install it manually: https://exiftool.org/install.html

This command will take the photoTakenTime { timestamp: '' } out of the .json associated to a picture and integrate it as EXIF data in the picture as DateTimeOriginal. See the "useful scripts" section below to find additional tags that you can add to this command to get more data back into your pictures.

This is my main task to also include geo data from the json and inplement it in the media. This works with all media formats I tested so far (jpg, jpeg, heic, png, mov, mp4)

```
exiftool -r -d %s -tagsfromfile "%d/%F.json" "-GPSAltitude<GeoDataAltitude" "-GPSLatitude<GeoDataLatitude" "-GPSLatitudeRef<GeoDataLatitude" "-GPSLongitude<GeoDataLongitude" "-GPSLongitudeRef<GeoDataLongitude" "-DateTimeOriginal<PhotoTakenTimeTimestamp" "-FileCreateDate<PhotoTakenTimeTimestamp" "-FileModifyDate<PhotoTakenTimeTimestamp" --ext json -overwrite_original -progress <directory_name>
```

Use this one if you only want to replace the creation date of the image:

```
exiftool -r -d %s -tagsfromfile "%d/%F.json" "-DateTimeOriginal<PhotoTakenTimeTimestamp" --ext json -overwrite_original -progress <directory_name>
```


## Change "Date modified" to "Date created" in file information
```
cd into/parent/directory/ && exiftool "-filemodifydate<datetimeoriginal" "-filecreatedate<datetimeoriginal" ./*
```
Mp4 files dont have *datetimeoriginal*, but they use *mediacreatedate* so we need to change the command to the following in order to change the modify and create date to the original create date:
```
exiftool "-filemodifydate<mediacreatedate" "-filecreatedate<mediacreatedate" ./*
```
If you only want to change the create date, then do this:
```
exiftool "-filecreatedate<mediacreatedate" ./*
```

## Fix iPhone Live Photos exported as .JPG
In my specific case, Live photos would be extracted as a .JPG and a (1).JPG instead of a .JPG and a .MOV. So I ran exiftool to correct this for files that have a filetype MOV. The script checks the filetype in the EXIF data of the file. If it's a .MOV, it will change the extension of the file to .MOV
```
exiftool -r -ext jpg -overwrite_original -filename=%f.MOV -if '$filetype eq "MOV"' -progress <directory_name>
```

### Remove all .json files
Remove all the .json in the current directory
```
find . -name "*.json" -type f -delete
```
### Remove -edited files
On some of the directories, Google used to adjust contrast/colors for every image. I chose to remove that for some folders.
Navigate to a directory and run (reminder: `.` is the current directory you're in)
```
find . -name "*-edited.jpg" -type f -delete
```
