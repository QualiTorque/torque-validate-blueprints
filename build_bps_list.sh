#!/bin/bash

FILES_TO_VALIDATE=()

if [ -n "$FILESLIST" ];
then
	IFS=","; read -a files <<< "$FILESLIST"; unset IFS
	for (( n=0; n < ${#files[*]}; n++))
	do
		path="${files[n]}"
		# highlevel dir
		FOLDER=$(dirname "$path" | cut -d/ -f 1);

		if [ $FOLDER = "blueprints" ];
		then
			# do nothing, just add to validation list 
			FILES_TO_VALIDATE+=("${path}")
			
		elif [ $FOLDER == "applications" ] || [ $FOLDER == "services" ];
		then
			# find corresponding blueprint
			resource=$(dirname $path | cut -d/ -f 2)

			while read bp;
			do
				if [[ ! " ${FILES_TO_VALIDATE[@]} " =~ " ${bp} " ]];
				then
					FILES_TO_VALIDATE+=("${bp}")
				fi
			done < <(grep -l -r blueprints/ -e "$resource:")
		else
			echo "Skipping ${path}"
		fi
	done

else
	echo "All blueprints in a repo will be validated"
	FILES_TO_VALIDATE=(blueprints/*.yaml)
fi

csv_output=$(printf ",%s" "${FILES_TO_VALIDATE[@]}")
csv_output=${csv_output:1}
echo "::set-output name=blueprints-to-validate::$(echo $csv_output)"
