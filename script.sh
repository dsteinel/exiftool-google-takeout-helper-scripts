#!/bin/bash

# Colors
COLOR_MENU='\033[1;34m'      # Bold Blue for menu
COLOR_PROMPT='\033[1;32m'    # Bold Green for prompts
COLOR_ERROR='\033[1;31m'     # Bold Red for errors
COLOR_RESET='\033[0m'        # Reset to default

show_menu() {
  echo -e "${COLOR_MENU}Select a task:${COLOR_RESET}"
  echo -e "${COLOR_MENU}1) Show all EXIF data for a file${COLOR_RESET}"
  echo -e "${COLOR_MENU}2) Google Takeout: Apply JSON metadata (Time & Geo) to media${COLOR_RESET}"
  echo -e "${COLOR_MENU}3) Repair & Sync all dates (Metadata & File System)${COLOR_RESET}"
  echo -e "${COLOR_MENU}4) Change filename to date${COLOR_RESET}"
  echo -e "${COLOR_MENU}q) Quit${COLOR_RESET}"
}

read_path() {
  echo -en "${COLOR_PROMPT}Paste a folder or file path and press [ENTER]:${COLOR_RESET} "
  read INPUT_PATH
  
  # Remove quotes if present (common when dragging and dropping files)
  INPUT_PATH="${INPUT_PATH%\"}"
  INPUT_PATH="${INPUT_PATH#\"}"
  INPUT_PATH="${INPUT_PATH%\'}"
  INPUT_PATH="${INPUT_PATH#\'}"

  # Check if path exists
  if [[ ! -e "$INPUT_PATH" ]]; then
    echo -e "${COLOR_ERROR}Error: Path does not exist: $INPUT_PATH${COLOR_RESET}"
    return 1
  fi
  return 0
}

while true; do
  show_menu
  echo -en "${COLOR_PROMPT}Enter your choice:${COLOR_RESET} "
  read choice

  if [[ "$choice" == "q" ]]; then
    echo -e "${COLOR_PROMPT}Exiting...${COLOR_RESET}"
    break
  fi

  if ! read_path; then
    continue
  fi

  echo -e "${COLOR_PROMPT}Running task...${COLOR_RESET}"
  case $choice in
    1)
      exiftool -s -time:all "$INPUT_PATH"
      echo -e "${COLOR_PROMPT}Task 'Show all EXIF data' completed.${COLOR_RESET}"
      ;;
    2)
      # Google Takeout JSON integration
      exiftool -r -d %s -tagsfromfile "%d/%F.json" \
        "-GPSAltitude<GeoDataAltitude" \
        "-GPSLatitude<GeoDataLatitude" \
        "-GPSLatitudeRef<GeoDataLatitude" \
        "-GPSLongitude<GeoDataLongitude" \
        "-GPSLongitudeRef<GeoDataLongitude" \
        "-DateTimeOriginal<PhotoTakenTimeTimestamp" \
        "-CreateDate<PhotoTakenTimeTimestamp" \
        "-ModifyDate<PhotoTakenTimeTimestamp" \
        "-FileCreateDate<PhotoTakenTimeTimestamp" \
        "-FileModifyDate<PhotoTakenTimeTimestamp" \
        --ext json -overwrite_original -progress "$INPUT_PATH"
      echo -e "${COLOR_PROMPT}Task 'Google Takeout: Apply JSON metadata' completed.${COLOR_RESET}"
      ;;
    3)
      # Combined Task 3, 4, and 6: Repair and Sync everything
      # 1. Fallback: Set all metadata to FileModifyDate
      # 2. Upgrade: Overwrite with internal Create/Original dates if they exist
      # 3. Finalize: Set File System creation/mod dates to match the metadata
      exiftool -r -overwrite_original -P -api QuickTimeUTC --ext json \
        "-AllDates<FileModifyDate" \
        "-TrackCreateDate<FileModifyDate" "-TrackModifyDate<FileModifyDate" \
        "-MediaCreateDate<FileModifyDate" "-MediaModifyDate<FileModifyDate" \
        "-CreationDate<FileModifyDate" \
        "-AllDates<CreateDate" \
        "-AllDates<DateTimeOriginal" \
        "-FileModifyDate<DateTimeOriginal" "-FileCreateDate<DateTimeOriginal" \
        "-FileModifyDate<CreateDate" "-FileCreateDate<CreateDate" \
        "-FileModifyDate<MediaCreateDate" "-FileCreateDate<MediaCreateDate" \
        "$INPUT_PATH"
      echo -e "${COLOR_PROMPT}Task 'Repair & Sync all dates' completed.${COLOR_RESET}"
      ;;
    4)
      # Rename files to YYYYMMDD_HHMMSS format
      exiftool -r -P --ext json \
        '-Filename<FileModifyDate' \
        '-Filename<ModifyDate' \
        '-Filename<CreateDate' \
        '-Filename<DateTimeOriginal' \
        -d %Y%m%d_%H%M%S%%-c.%%le "$INPUT_PATH"
      echo -e "${COLOR_PROMPT}Task 'Change filename to date' completed.${COLOR_RESET}"
      ;;
    *)
      echo -e "${COLOR_ERROR}Invalid choice.${COLOR_RESET}"
      ;;
  esac

done
