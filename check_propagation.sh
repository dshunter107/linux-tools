
debug=0
print_option=0

source=$(pwd)

find $source -regextype sed -regex ".*Kconfig" > /tmp/kconfigs.txt
in_choice=0
track_distribution=0
propagation_needed=0

selects=0
prompts=0
defaults=0
depends=0

function check_propagation() {

	ln=$1;

	if [[ $ln =~ "select" ]]
	then 
		selects=$((selects+1))
		print_option=1
	fi
	if [[ $ln =~ "prompt" ]] 
	then 
		prompts=$((prompts+1))
		print_option=1
	fi
	if [[ $ln =~ default|def_bool|def_tristate ]] 
	then 
		defaults=$((defaults+1))
		print_option=1
	fi
	if [[ $ln =~ "depends" ]] 
	then 
		depends=$((depends+1))
		print_option=1
	fi
}

while read line ; do
    while read ln ; do
        if [ "$ln" = "choice" ]
        then
        	in_choice=1
		track_distribution=1
        fi
        if [ "$ln" = "endchoice" ] || [[ "$ln" =~ "help" ]]
        then
        	in_choice=0
		track_distribution=0
	fi
	if [[ $ln =~ "config " &&  $in_choice -eq 1 ]]
	then 
		track_distribution=0		
	fi
	if [ $track_distribution -eq 1 ]
	then 
		check_propagation $ln	
	fi
	if [ $print_option -eq 1 ] && [ $debug -eq 1 ] 
	then
		echo "$line" >> /tmp/propagated
		echo "line: $ln" >> /tmp/propagated
		print_option=0
	fi

    done <$line
done </tmp/kconfigs.txt

echo "select: $selects"
echo "prompts: $prompts"
echo "defaults: $defaults"
echo "depends: $depends"
