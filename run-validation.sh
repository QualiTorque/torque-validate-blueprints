#!/bin/bash

BRANCH=${GITHUB_REF##*/}
FILES_TO_VALIDATE=()

echo "Working in branch ${BRANCH}"
echo "Space: ${INPUT_SPACE}"

echo "Files from the user input ${INPUT_FILESLIST}"
VAR=$(echo "This is test" | tee /dev/tty)

[ -d "./blueprints" ] || (echo "Wrong repo. No blueprints/ directory" && exit 1);

if [ -n "$INPUT_FILESLIST" ];
then
	for path in $INPUT_FILESLIST;
	do
		# highlevel dir
		FOLDER=$(dirname $path | cut -d/ -f 1);

		if [ $FOLDER = "blueprints" ];
		then
			# do nothing, just add to validation list 
			FILES_TO_VALIDATE+=("${path}")
			
		elif [ $FOLDER == "applications" ] || [ $FOLDER == "services" ];
		then
		  	# find corresponding blueprint
			resource=$(dirname $path | cut -d/ -f 2)
			echo "Find blueprints which depend on ${resource}"

	  		while read bp;
			do
				if [[ ! " ${FILES_TO_VALIDATE[@]} " =~ " ${bp} " ]];
				then
					echo "Adding ${bp} to the list"
					FILES_TO_VALIDATE+=("${bp}")
				fi
			done < <(grep -l -r blueprints/ -e $resource)
		else
			echo "Skipping ${path}"
		fi
	done

  	echo "Final list of files to validate:"
  	echo ${FILES_TO_VALIDATE[@]}

else
	FILES_TO_VALIDATE=(blueprints/*.yaml)
fi

err=0

for ((i = 0; i < ${#FILES_TO_VALIDATE[@]}; i++));
do
	bpname=`echo ${FILES_TO_VALIDATE[$i]} | sed 's,blueprints/,,' | sed 's/.yaml//'`
	echo "Validating ${bpname}..."
	PAYLOAD=(
		  "{
			'type':'$INPUT_TYPE',
			'blueprint_name':'${bpname}',
			'source': {
				'branch': '${BRANCH}'
			}
		  }"
	)
	curl --silent -X POST "https://cloudshellcolony.com/api/spaces/${INPUT_SPACE}/validations/blueprints" \
			-H "accept: text/plain" -H "Authorization: bearer ${INPUT_COLONY_TOKEN}" \
			-H "Content-Type:  application/json" -d "$PAYLOAD"` | \ 
				python3 -c \ 	"import sys, json; \
								errors = json.load(sys.stdin)['errors']; \
								print('Valid') if not errors else print(' '.join( [err['message'] for err in errors])) or sys.exit(1)"
	[ $? -eq 0 ] || ((err++))
	
	# colony --token $INPUT_COLONY_TOKEN --space $INPUT_SPACE bp validate "${bpname}" --branch $BRANCH || ((err++))
done

echo "Number of failed blueptints: ${err}"

if (( $err > 0 ));
then
	exit 1;
fi
