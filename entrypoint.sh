#!/bin/bash

BP_LIST=$1
errors=0

if [ -n "$BP_LIST" ];
then
	IFS=","; read -a files <<< "$BP_LIST"; unset IFS
	for (( n=0; n < ${#files[*]}; n++))
	do
		path="${files[n]}"
		# highlevel dir
		FOLDER=$(dirname "$path" | cut -d/ -f 1);

		if [ $FOLDER = "blueprints" ];
		then
			# do nothing, just add to validation list
			[[ ! " ${FILES_TO_VALIDATE[@]} " =~ " ${path} " ]] && FILES_TO_VALIDATE+=("${path}")
		else
			echo "Skipping ${path}"
		fi
	done

else
	echo "Files list was not provided. All the blueprints files in this branch will be validated."
	FILES_TO_VALIDATE=(blueprints/*.yaml)
fi

for f in $FILES_TO_VALIDATE
do
    torque --disable-version-check bp validate $f || errors=$((errors+1))
done

if [ "$errors" -gt 0 ]; then
    echo "The total number of failed blueprints: ${errors}"
    exit 1
fi
