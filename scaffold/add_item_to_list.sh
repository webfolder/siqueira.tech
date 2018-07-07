#!/bin/bash

LAYOUT_PATH=_layouts
TARGET_STRING_TO_REPLACE="<!-- NEW_SECTION_HERE -->"

function check_target()
{
	TARGET=$1

	for filename in _layouts/*.html; do
		NO_EXTENSION=$(basename "$filename" .html)
		WITH_EXTENSION=$(basename "$filename")
		if [[ "$TARGET" == "$NO_EXTENSION" ||
					"$TARGET" == "$WITH_EXTENSION" ]]; then
			return 0
		fi
	done
	return 1
}

function add_new_section()
{
	FILE_PATH=$1
	NAME=$2
	IMAGE=$3
  MATCH=0
	NEW_SECTION=\
"     <div class=\"image-section\">
        <a href=\"{{ site.url }}/"$NAME"_list\">
          <img src=\"{{ site.url }}/images/icons/$IMAGE.png\" width=\"300\" height=\"300\">
        </a>
        <div class=\"description\">$NAME</div>
      </div>

      <!-- NEW_SECTION_HERE -->"

  while IFS='' read -r  line
  do
          echo -e "$line" | grep -q "$TARGET_STRING_TO_REPLACE"
          if [ $? -eq 0 ]; then
            NEW_FILE=$NEW_FILE'\n'$NEW_SECTION
            MATCH=1
            continue
          fi
          if [[ -z $NEW_FILE ]]; then
            NEW_FILE=$line
            continue
          fi
          NEW_FILE=$NEW_FILE'\n'$line
  done < $FILE_PATH

  echo -e "$NEW_FILE" > $FILE_PATH

	return $MATCH
}

function add_page_file()
{
	NAME=$1

  TITLE="title: $NAME"
  PERMALINK="permalink: /$NAME""_list.html"
  FILE_PATH="_pages/$NAME""_list.md"
  NEW_FILE=""

  while IFS='' read -r  line
  do
          echo -e "$line" | grep -q "#TITLE#"
          if [ $? -eq 0 ]; then
            NEW_FILE=$NEW_FILE'\n'$TITLE
            continue
          fi

          echo -e "$line" | grep -q "#PERMALINK#"
          if [ $? -eq 0 ]; then
            NEW_FILE=$NEW_FILE'\n'$PERMALINK
            continue
          fi

          if [[ -z $NEW_FILE ]]; then
            NEW_FILE=$line
            continue
          fi
          NEW_FILE=$NEW_FILE'\n'$line
  done < "scaffold/template_list.md"

  echo -e "$NEW_FILE" > $FILE_PATH
}

for i in "$@"
do
	case $i in
			-t=*|--target=*)
			TARGET="${i#*=}"
			shift
			;;
			-n=*|--name=*)
			NAME="${i#*=}"
			shift
			;;
			-i=*|--image=*)
			IMAGE="${i#*=}"
			shift
			;;
			*)
				echo "Unknow option"
				exit
			;;
	esac
done

if [[ -z $TARGET || -z $NAME ]]; then
	echo "Target and Name are mandotory"
	exit
fi

check_target $TARGET
if [[ $? == 1 ]]; then
	echo "For some reason, we cannot find the target"
	exit
fi

# Normalize target file
TARGET="_layouts/$TARGET"
if [[ ! -f $TARGET ]]; then
	TARGET="$TARGET".html
fi

# check image
if [[ ! -f "images/icons/$IMAGE.png" ]]; then
  echo "We could not find the image, set a defult."
  IMAGE=default_image
fi

add_new_section $TARGET $NAME $IMAGE

if [[ ?$ != 1 ]]; then
  echo "No match in the target file"
  exit
fi
add_page_file $NAME
